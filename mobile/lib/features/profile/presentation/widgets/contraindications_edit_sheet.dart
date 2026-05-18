import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class ContraindicationsEditSheet extends StatelessWidget {
  final List<Map<String, dynamic>> allItems;
  final List<String> selected;
  final ValueChanged<List<String>>? onSave;

  const ContraindicationsEditSheet({
    super.key,
    required this.allItems,
    required this.selected,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final currentSelected = ValueNotifier<List<String>>(List.from(selected));

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
            'Противопоказания',
            style: AppTypography.h4SemiBold
                .copyWith(color: AppColors.blackColor),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<List<String>>(
            valueListenable: currentSelected,
            builder: (context, selectedList, _) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: allItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = allItems[index];
                    final slug = item['slug'] as String;
                    final name = item['name'] as String;
                    final isSelected = selectedList.contains(slug);

                    return InkWell(
                      onTap: () {
                        final list = List<String>.from(selectedList);
                        if (isSelected) {
                          list.remove(slug);
                        } else {
                          list.add(slug);
                        }
                        currentSelected.value = list;
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? null : AppColors.borderColor,
                          gradient:
                              isSelected ? AppGradients.purpleLinear : null,
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
                                name,
                                style: AppTypography.mediumTextMedium.copyWith(
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
                onSave?.call(currentSelected.value);
                Navigator.of(context).pop();
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
                    'Сохранить',
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
