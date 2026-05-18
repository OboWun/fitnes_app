import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/equipment_item.dart';

class AddEquipmentSheet extends StatelessWidget {
  final List<EquipmentItem> availableEquipment;
  final ValueChanged<List<EquipmentItem>>? onAdd;

  const AddEquipmentSheet({
    super.key,
    required this.availableEquipment,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final selected = ValueNotifier<List<String>>([]);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Добавить инвентарь',
            style:
                AppTypography.h4SemiBold.copyWith(color: AppColors.blackColor),
          ),
          const SizedBox(height: 16),
          if (availableEquipment.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Весь инвентарь уже добавлен',
                  style: AppTypography.mediumTextRegular
                      .copyWith(color: AppColors.gray2),
                ),
              ),
            )
          else
            ValueListenableBuilder<List<String>>(
              valueListenable: selected,
              builder: (_, selectedList, __) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: availableEquipment.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = availableEquipment[index];
                      final isSelected =
                          selectedList.contains(item.slug);

                      return InkWell(
                        onTap: () {
                          final list = List<String>.from(selectedList);
                          if (isSelected) {
                            list.remove(item.slug);
                          } else {
                            list.add(item.slug);
                          }
                          selected.value = list;
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? null : AppColors.borderColor,
                            gradient:
                                isSelected ? AppGradients.blueLinear : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: isSelected
                                    ? AppColors.whiteColor
                                    : AppColors.gray2,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style:
                                      AppTypography.mediumTextMedium.copyWith(
                                    color: isSelected
                                        ? AppColors.whiteColor
                                        : AppColors.blackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () {
                final selectedItems = availableEquipment
                    .where((e) => selected.value.contains(e.slug))
                    .toList();
                onAdd?.call(selectedItems);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppGradients.blueLinear,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.blue,
                ),
                child: Center(
                  child: Text(
                    'Добавить',
                    style: AppTypography.largeTextSemiBold
                        .copyWith(color: AppColors.whiteColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
