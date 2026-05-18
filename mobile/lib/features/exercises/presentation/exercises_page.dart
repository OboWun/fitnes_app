import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../design_system/design_system.dart';
import '../../dictionaries/equipment_provider.dart';
import '../../dictionaries/domain/equipment_item.dart';
import '../../profile/domain/equipment_preset.dart';
import '../../profile/profile_provider.dart';
import '../data/exercise_repository.dart';
import '../domain/equipment_ref.dart';
import '../domain/exercise_filter.dart';
import '../domain/exercise_short.dart';
import '../exercise_provider.dart';
import 'widgets/exercise_filter_bar.dart';
import 'widgets/exercise_filter_sheet.dart';
import 'widgets/exercise_list_item.dart';

class ExercisesPage extends ConsumerStatefulWidget {
  final String? equipment;
  final String? search;
  final String? muscles;

  const ExercisesPage({super.key, this.equipment, this.search, this.muscles});

  @override
  ConsumerState<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends ConsumerState<ExercisesPage> {
  late final PagingController<int, ExerciseShort> _pagingController;
  final _searchController = TextEditingController();
  final _searchQuery = ValueNotifier<String>('');
  bool _showSearch = false;
  ExerciseFilter _filter = const ExerciseFilter();

  @override
  void initState() {
    super.initState();
    _filter = ExerciseFilter(
      isPersonal: true,
      equipments: widget.equipment != null
          ? widget.equipment!.split(',').where((e) => e.isNotEmpty).toList()
          : [],
      targetMuscles: widget.muscles != null
          ? widget.muscles!.split(',').where((e) => e.isNotEmpty).toList()
          : [],
      search: widget.search,
    );
    if (widget.search != null && widget.search!.isNotEmpty) {
      _searchController.text = widget.search!;
      _searchQuery.value = widget.search!;
      _showSearch = true;
    }
    _pagingController = PagingController<int, ExerciseShort>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: _fetchPage,
    );
  }

  Future<List<ExerciseShort>> _fetchPage(int pageKey) async {
    final repo = ref.read(exerciseRepositoryProvider);
    final result = await repo.getExercises(
      page: pageKey,
      limit: _filter.limit,
      search: _filter.search,
      equipments:
          _filter.equipments.isNotEmpty ? _filter.equipments : null,
      targetMuscles: _filter.targetMuscles.isNotEmpty
          ? _filter.targetMuscles
          : null,
      isPersonal: _filter.isPersonal,
    );
    return result.data;
  }

  void _updateFilter(ExerciseFilter newFilter) {
    setState(() => _filter = newFilter);
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allEquipmentAsync = ref.watch(allEquipmentProvider);
    final allMusclesAsync = ref.watch(allMusclesProvider);
    final allPresetsAsync = ref.watch(allEquipmentPresetsProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: const Text('Упражнения'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchQuery.value = '';
                _searchController.clear();
                _updateFilter(_filter.copyWith(search: null, page: 1));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Поиск упражнений...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.gray2),
                  suffixIcon: ValueListenableBuilder<String>(
                    valueListenable: _searchQuery,
                    builder: (_, query, __) {
                      if (query.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchQuery.value = '';
                          _searchController.clear();
                          _updateFilter(
                              _filter.copyWith(search: null, page: 1));
                        },
                      );
                    },
                  ),
                ),
                onChanged: (value) => _searchQuery.value = value,
                onSubmitted: (value) =>
                    _updateFilter(_filter.copyWith(search: value, page: 1)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ExerciseFilterBar(
                value: _filter,
                onChanged: _updateFilter,
                equipmentNames: {
                  for (final e
                      in allEquipmentAsync.valueOrNull ?? [])
                    e.slug: e.name,
                },
                muscleNames: {
                  for (final m in allMusclesAsync.valueOrNull ?? [])
                    m.slug: m.name,
                },
                onFilterTap: () => _showFilterSheet(
                  allEquipmentAsync,
                  allMusclesAsync,
                  allPresetsAsync,
                ),
              ),
            ),
          ),
          Expanded(
            child: PagingListener(
              controller: _pagingController,
              builder: (context, state, fetchNextPage) =>
                  PagedListView<int, ExerciseShort>(
                state: state,
                fetchNextPage: fetchNextPage,
                addAutomaticKeepAlives: false,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                builderDelegate: PagedChildBuilderDelegate<ExerciseShort>(
                  itemBuilder: (context, item, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ExerciseListItem(
                      exercise: item,
                      onTap: () =>
                          context.push('/exercises/${item.slug}'),
                    ),
                  ),
                  firstPageProgressIndicatorBuilder: (context) =>
                      const _FirstPageLoading(),
                  newPageProgressIndicatorBuilder: (context) =>
                      const _NewPageLoading(),
                  noItemsFoundIndicatorBuilder: (context) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Text(
                        'Упражнений не найдено',
                        style: AppTypography.mediumTextRegular
                            .copyWith(color: AppColors.gray2),
                      ),
                    ),
                  ),
                  firstPageErrorIndicatorBuilder: (context) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ошибка загрузки',
                          style: AppTypography.mediumTextRegular
                              .copyWith(color: AppColors.gray2),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _pagingController.refresh(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppGradients.blueLinear,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Повторить',
                              style: AppTypography.mediumTextSemiBold
                                  .copyWith(color: AppColors.whiteColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(
    AsyncValue<List<EquipmentItem>> equipmentAsync,
    AsyncValue<List<MuscleItem>> musclesAsync,
    AsyncValue<List<EquipmentPreset>> presetsAsync,
  ) {
    final equipments = equipmentAsync.valueOrNull ?? [];
    final muscles = musclesAsync.valueOrNull ?? [];
    final presets = presetsAsync.valueOrNull ?? [];

    final equipmentRefs = equipments
        .map((e) => EquipmentRef(slug: e.slug, name: e.name))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ExerciseFilterSheet(
        currentFilter: _filter,
        availableEquipments: equipmentRefs,
        availableMuscles: muscles,
        availablePresets: presets,
        onApply: _updateFilter,
      ),
    );
  }
}

class _FirstPageLoading extends StatelessWidget {
  const _FirstPageLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: ExerciseListItem.loading(),
        ),
      ),
    );
  }
}

class _NewPageLoading extends StatelessWidget {
  const _NewPageLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Center(child: ExerciseListItem.loading()),
    );
  }
}
