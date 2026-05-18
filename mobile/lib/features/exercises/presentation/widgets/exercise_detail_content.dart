import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/contraindication_severity.dart';
import '../../domain/exercise_detail.dart';
import '../../domain/exercise_short.dart';
import 'similar_exercises_carousel.dart';

class ExerciseDetailContent extends StatelessWidget {
  final ExerciseDetail? _detail;
  final ValueChanged<ExerciseShort>? _onSimilarTap;

  const ExerciseDetailContent({
    super.key,
    required ExerciseDetail detail,
    ValueChanged<ExerciseShort>? onSimilarTap,
  })  : _detail = detail,
        _onSimilarTap = onSimilarTap;

  const ExerciseDetailContent.loading({super.key})
      : _detail = null,
        _onSimilarTap = null;

  @override
  Widget build(BuildContext context) {
    if (_detail == null) return const _DetailLoading();
    return _DetailData(
      detail: _detail!,
      onSimilarTap: _onSimilarTap,
    );
  }
}

class _DetailData extends StatelessWidget {
  final ExerciseDetail detail;
  final ValueChanged<ExerciseShort>? onSimilarTap;

  const _DetailData({required this.detail, this.onSimilarTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.imageUrl != null)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 200,
                height: 200,
                child: CachedNetworkImage(
                  imageUrl: detail.imageUrl!,
                  fit: BoxFit.cover,
                  memCacheWidth: 200,
                  memCacheHeight: 200,
                  filterQuality: FilterQuality.low,
                  placeholder: (_, __) => Container(
                    color: AppColors.gray3,
                    child: const Icon(
                      Icons.fitness_center,
                      size: 48,
                      color: AppColors.gray2,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.gray3,
                    child: const Icon(
                      Icons.fitness_center,
                      size: 48,
                      color: AppColors.gray2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        if (detail.difficulty != null)
          _InfoRow(label: 'Сложность', value: _difficultyLabel(detail.difficulty!)),
        if (detail.exerciseType != null)
          _InfoRow(label: 'Тип', value: _typeLabel(detail.exerciseType!)),
        if (detail.movementPattern != null)
          _InfoRow(label: 'Движение', value: detail.movementPattern!),
        if (detail.equipments.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Инвентарь',
            style: AppTypography.mediumTextSemiBold
                .copyWith(color: AppColors.blackColor),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detail.equipments
                .map((e) => _TagChip(label: e.name))
                .toList(),
          ),
        ],
        if (detail.targetMuscles.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Целевые мышцы',
            style: AppTypography.mediumTextSemiBold
                .copyWith(color: AppColors.blackColor),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detail.targetMuscles
                .map((m) => _TagChip(label: m.name))
                .toList(),
          ),
        ],
        if (detail.secondaryMuscles.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Вспомогательные мышцы',
            style: AppTypography.mediumTextSemiBold
                .copyWith(color: AppColors.blackColor),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detail.secondaryMuscles
                .map((m) => _TagChip(label: m.name, isSecondary: true))
                .toList(),
          ),
        ],
        if (detail.description != null &&
            detail.description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Описание',
            style: AppTypography.mediumTextSemiBold
                .copyWith(color: AppColors.blackColor),
          ),
          const SizedBox(height: 8),
          Text(
            detail.description!,
            style: AppTypography.mediumTextRegular
                .copyWith(color: AppColors.gray1),
          ),
        ],
        if (detail.instructions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Инструкции',
            style: AppTypography.mediumTextSemiBold
                .copyWith(color: AppColors.blackColor),
          ),
          const SizedBox(height: 8),
          ...detail.instructions.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: AppGradients.blueLinear,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: AppTypography.smallTextSemiBold
                                .copyWith(color: AppColors.whiteColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: AppTypography.mediumTextRegular
                              .copyWith(color: AppColors.blackColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
        if (detail.userContraindications.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Противопоказания',
            style: AppTypography.mediumTextSemiBold
                .copyWith(color: AppColors.blackColor),
          ),
          const SizedBox(height: 8),
          ...detail.userContraindications.map(
            (c) {
              final severity =
                  ContraindicationSeverity.fromString(c.severity);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ContraindicationRow(
                  slug: c.slug,
                  name: c.name,
                  severity: severity,
                ),
              );
            },
          ),
        ],
        if (detail.similarExercises.isNotEmpty) ...[
          const SizedBox(height: 24),
          SimilarExercisesCarousel(
            exercises: detail.similarExercises,
            onTap: onSimilarTap,
          ),
        ],
      ],
    );
  }

  String _difficultyLabel(String difficulty) {
    return switch (difficulty) {
      'beginner' => 'Новичок',
      'intermediate' => 'Средний',
      'advanced' => 'Продвинутый',
      _ => difficulty,
    };
  }

  String _typeLabel(String type) {
    return switch (type) {
      'strength' => 'Сила',
      'hypertrophy' => 'Гипертрофия',
      'endurance' => 'Выносливость',
      'mobility' => 'Мобильность',
      'stability' => 'Стабильность',
      'cardio' => 'Кардио',
      'plyometric' => 'Плиометрика',
      'rehab' => 'Реабилитация',
      'stretching' => 'Растяжка',
      _ => type,
    };
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.mediumTextRegular
                  .copyWith(color: AppColors.gray1),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.mediumTextSemiBold
                  .copyWith(color: AppColors.blackColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isSecondary;

  const _TagChip({required this.label, this.isSecondary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: isSecondary
            ? AppGradients.purpleLinear
            : AppGradients.blueLinear,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.smallTextMedium
            .copyWith(color: AppColors.whiteColor),
      ),
    );
  }
}

class _ContraindicationRow extends StatelessWidget {
  final String slug;
  final String? name;
  final ContraindicationSeverity? severity;

  const _ContraindicationRow({
    required this.slug,
    this.name,
    this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (severity) {
      ContraindicationSeverity.lowWeight => (
          const Color(0xFFFFA726),
          Icons.warning_amber_rounded
        ),
      ContraindicationSeverity.notRecommended => (
          const Color(0xFFFF7043),
          Icons.warning_rounded
        ),
      ContraindicationSeverity.forbidden => (
          const Color(0xFFE53935),
          Icons.block
        ),
      null => (AppColors.gray2, Icons.info_outline),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  severity?.label ?? name ?? slug,
                  style: AppTypography.mediumTextSemiBold
                      .copyWith(color: color),
                ),
                if (name != null)
                  Text(
                    slug,
                    style: AppTypography.smallTextRegular
                        .copyWith(color: AppColors.gray1),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ShimmerCard(
              width: 200, height: 200, borderRadius: BorderRadius.zero),
        ),
        SizedBox(height: 16),
        ShimmerCard(height: 16),
        SizedBox(height: 8),
        ShimmerCard(height: 16, width: 150),
        SizedBox(height: 16),
        ShimmerCard(height: 12),
        SizedBox(height: 4),
        ShimmerCard(height: 12),
        SizedBox(height: 4),
        ShimmerCard(height: 12, width: 200),
        SizedBox(height: 24),
        ShimmerCard(height: 16, width: 160),
        SizedBox(height: 12),
        ShimmerCard(height: 64, width: 140),
      ],
    );
  }
}
