import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class DialogCompleteCard extends StatelessWidget {
  final String planType;
  final Map<String, dynamic> params;
  final VoidCallback? onCreate;
  final bool isCreating;

  const DialogCompleteCard({
    super.key,
    required this.planType,
    required this.params,
    this.onCreate,
    this.isCreating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekly = planType == 'weekly';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.blueLinear,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.blue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.whiteColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isWeekly
                      ? 'Параметры готовы!'
                      : 'Параметры тренировки готовы!',
                  style: AppTypography.largeTextSemiBold.copyWith(
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildParams(params),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: InkWell(
              onTap: isCreating ? null : onCreate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.blackColor,
                        ),
                      )
                    : Text(
                        isWeekly ? 'Создать план' : 'Создать тренировку',
                        style: AppTypography.largeTextSemiBold.copyWith(
                          color: AppColors.blackColor,
                        ),
                      ),
              ),
            ),
          ),
          if (!isCreating)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  'Это может занять несколько секунд',
                  style: AppTypography.captionRegular.copyWith(
                    color: AppColors.whiteColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildParams(Map<String, dynamic> params) {
    final entries = <Widget>[];

    final goal = params['goal'] as String?;
    if (goal != null) entries.add(_row('Цель', _goalLabel(goal)));

    final level = params['experienceLevel'] as String?;
    if (level != null) entries.add(_row('Уровень', _levelLabel(level)));

    final duration = params['sessionDurationMin'];
    if (duration != null) {
      entries.add(_row('Длительность', '$duration мин'));
    }

    final activity = params['activityLevel'] as String?;
    if (activity != null) entries.add(_row('Активность', _activityLabel(activity)));

    final split = params['splitType'] as String?;
    if (split != null) entries.add(_row('Сплит', _splitLabel(split)));

    final cardio = params['cardioPreference'] as String?;
    if (cardio != null) entries.add(_row('Кардио', _cardioLabel(cardio)));

    final endurance = params['enduranceType'] as String?;
    if (endurance != null) entries.add(_row('Выносливость', _enduranceLabel(endurance)));

    final targetWeight = params['targetWeightKg'];
    if (targetWeight != null) entries.add(_row('Целевой вес', '$targetWeight кг'));

    if (planType == 'generate') {
      final focus = params['focusMuscles'];
      if (focus is List && focus.isNotEmpty) {
        entries.add(_row('Акцент', _musclesLabel(focus.cast<String>())));
      }
    }

    if (isWeekly) {
      final count = params['trainingCountPerWeek'];
      if (count != null) {
        entries.add(_row('Тренировок в неделю', '$count'));
      }
      final days = params['availableDays'];
      if (days is List && days.isNotEmpty) {
        entries.add(_row('Дни', _daysLabel(days.cast<String>())));
      }
    }

    return entries;
  }

  bool get isWeekly => planType == 'weekly';

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.smallTextRegular.copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.8),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.smallTextSemiBold.copyWith(
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _goalLabel(String goal) => switch (goal) {
        'strength' => 'Сила',
        'hypertrophy' => 'Рост мышц',
        'glute_growth' => 'Накачать ягодицы',
        'recomposition' => 'Рельеф',
        'endurance' => 'Выносливость',
        'weight_loss' => 'Похудение',
        'general_health' => 'Общее здоровье',
        'rehab' => 'Реабилитация',
        'mobility' => 'Мобильность',
        _ => goal,
      };

  String _levelLabel(String level) => switch (level) {
        'beginner' => 'Новичок',
        'intermediate' => 'Средний',
        'advanced' => 'Продвинутый',
        _ => level,
      };

  String _activityLabel(String a) => switch (a) {
        'sedentary' => 'Сидячий',
        'light' => 'Лёгкий',
        'moderate' => 'Умеренный',
        'active' => 'Активный',
        _ => a,
      };

  String _splitLabel(String s) => switch (s) {
        'auto' => 'Авто',
        'full_body' => 'Фулбоди',
        'upper_lower' => 'Верх/Низ',
        'ppl' => 'PPL',
        _ => s,
      };

  String _cardioLabel(String c) => switch (c) {
        'any' => 'Любое',
        'running' => 'Бег',
        'cycling' => 'Велосипед',
        'rowing' => 'Гребля',
        'jump_rope' => 'Скакалка',
        'swimming' => 'Плавание',
        _ => c,
      };

  String _enduranceLabel(String e) => switch (e) {
        'muscular' => 'Мышечная',
        'cardio' => 'Кардио',
        'mixed' => 'Смешанная',
        _ => e,
      };

  String _daysLabel(List<String> days) {
    const m = {
      'monday': 'Пн', 'tuesday': 'Вт', 'wednesday': 'Ср',
      'thursday': 'Чт', 'friday': 'Пт', 'saturday': 'Сб', 'sunday': 'Вс',
    };
    return days.map((d) => m[d] ?? d).join(', ');
  }

  String _musclesLabel(List<String> muscles) {
    const m = {
      'chest': 'Грудь', 'back': 'Спина', 'legs': 'Ноги',
      'shoulders': 'Плечи', 'arms': 'Руки', 'core': 'Кор',
    };
    return muscles.map((s) => m[s] ?? s).join(', ');
  }
}
