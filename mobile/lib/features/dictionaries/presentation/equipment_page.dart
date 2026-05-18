import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../equipment_provider.dart';
import 'widgets/equipment_grid.dart';
import 'widgets/equipment_search_bar.dart';
import 'widgets/preset_grid.dart';

class EquipmentPage extends ConsumerStatefulWidget {
  const EquipmentPage({super.key});

  @override
  ConsumerState<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends ConsumerState<EquipmentPage> {
  final _searchQuery = ValueNotifier<String>('');
  final _showPresets = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _searchQuery.dispose();
    _showPresets.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipmentAsync = ref.watch(allEquipmentProvider);
    final presetsAsync = ref.watch(allPresetsProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(title: const Text('Инвентарь')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            ValueListenableBuilder<String>(
              valueListenable: _searchQuery,
              builder: (_, query, __) {
                if (!_showPresets.value) {
                  return EquipmentSearchBar(
                    value: query,
                    onChanged: (v) => _searchQuery.value = v,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: _showPresets,
              builder: (_, showPresets, __) {
                return Row(
                  children: [
                    Expanded(
                      child: _ToggleChip(
                        label: 'Инвентарь',
                        isSelected: !showPresets,
                        onTap: () => _showPresets.value = false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ToggleChip(
                        label: 'Пресеты',
                        isSelected: showPresets,
                        onTap: () => _showPresets.value = true,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: _showPresets,
                builder: (_, showPresets, __) {
                  if (showPresets) {
                    return presetsAsync.when(
                      data: (presets) => SingleChildScrollView(
                        child: PresetGrid(
                          presets: presets,
                          onTap: (preset) => context
                              .push('/equipment/presets/${preset.id}'),
                        ),
                      ),
                      loading: () => const SingleChildScrollView(
                        child: PresetGrid.loading(),
                      ),
                      error: (_, __) => const Center(
                          child: Text('Ошибка загрузки')),
                    );
                  }

                  return equipmentAsync.when(
                    data: (allItems) {
                      return ValueListenableBuilder<String>(
                        valueListenable: _searchQuery,
                        builder: (_, query, __) {
                          final filtered = query.isEmpty
                              ? allItems
                              : allItems
                                  .where((e) => e.name.toLowerCase()
                                      .contains(query.toLowerCase()))
                                  .toList();
                          return SingleChildScrollView(
                            child: EquipmentGrid(
                              items: filtered,
                              onTap: (item) => context
                                  .push('/equipment/${item.slug}'),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const SingleChildScrollView(
                      child: EquipmentGrid.loading(),
                    ),
                    error: (_, __) =>
                        const Center(child: Text('Ошибка загрузки')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.blueLinear : null,
          color: isSelected ? null : AppColors.borderColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? AppShadows.blue : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.mediumTextSemiBold.copyWith(
              color:
                  isSelected ? AppColors.whiteColor : AppColors.gray1,
            ),
          ),
        ),
      ),
    );
  }
}
