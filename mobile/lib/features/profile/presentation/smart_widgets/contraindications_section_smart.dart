import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/public.dart';
import '../../../../design_system/design_system.dart';
import '../../data/profile_repository.dart';
import '../widgets/contraindications_edit_sheet.dart';
import '../widgets/contraindications_section.dart';

class ContraindicationsSectionSmart extends ConsumerWidget {
  const ContraindicationsSectionSmart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contraindications = ref.watch(
        authProvider.select((s) => s.user?.contraindications ?? []));
    final allContraindicationsAsync = ref.watch(contraindicationsProvider);

    return ContraindicationsSection(
      items: contraindications,
      onEdit: allContraindicationsAsync.hasValue
          ? () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.whiteColor,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => ContraindicationsEditSheet(
                  allItems: allContraindicationsAsync.value ?? [],
                  selected: contraindications,
                  onSave: (newList) {
                    ref
                        .read(profileRepositoryProvider)
                        .updateContraindications(newList);
                    final user = ref.read(authProvider).user;
                    if (user != null) {
                      ref
                          .read(authProvider.notifier)
                          .updateUserLocally(
                              user.copyWith(contraindications: newList));
                    }
                  },
                ),
              );
            }
          : null,
    );
  }
}
