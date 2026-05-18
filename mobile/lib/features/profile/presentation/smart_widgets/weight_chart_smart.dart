import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/weight_record.dart';
import '../../weight_history_provider.dart';
import '../widgets/weight_chart.dart';

class WeightChartSmart extends ConsumerStatefulWidget {
  const WeightChartSmart({super.key});

  @override
  ConsumerState<WeightChartSmart> createState() => _WeightChartSmartState();
}

class _WeightChartSmartState extends ConsumerState<WeightChartSmart> {
  WeightPeriod _period = WeightPeriod.month;

  @override
  Widget build(BuildContext context) {
    final recordsAsync =
        ref.watch(weightHistoryProvider(_period));

    return Column(
      children: [
        recordsAsync.when(
          data: (records) => WeightChart(records: records, period: _period),
          loading: () => WeightChart.loading(period: _period),
          error: (_, __) => WeightChart.loading(period: _period),
        ),
        const SizedBox(height: 8),
        Row(
          children: WeightPeriod.values.map((p) {
            final isSelected = p == _period;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => setState(() => _period = p),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppGradients.blueLinear : null,
                      color: isSelected ? null : AppColors.borderColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        switch (p) {
                          WeightPeriod.week => 'Неделя',
                          WeightPeriod.month => 'Месяц',
                          WeightPeriod.all => 'Всё время',
                        },
                        style: AppTypography.smallTextMedium.copyWith(
                          color: isSelected
                              ? AppColors.whiteColor
                              : AppColors.gray1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
