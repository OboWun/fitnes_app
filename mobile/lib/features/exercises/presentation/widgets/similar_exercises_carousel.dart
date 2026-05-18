import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/contraindication_severity.dart';
import '../../domain/exercise_short.dart';

class SimilarExercisesCarousel extends StatelessWidget {
  final List<ExerciseShort>? _exercises;
  final ValueChanged<ExerciseShort>? _onTap;

  const SimilarExercisesCarousel({
    super.key,
    required List<ExerciseShort> exercises,
    ValueChanged<ExerciseShort>? onTap,
  })  : _exercises = exercises,
        _onTap = onTap;

  const SimilarExercisesCarousel.loading({super.key})
      : _exercises = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_exercises == null) return const _SimilarLoading();
    if (_exercises!.isEmpty) return const SizedBox.shrink();
    return _SimilarData(exercises: _exercises!, onTap: _onTap);
  }
}

class _SimilarData extends StatelessWidget {
  final List<ExerciseShort> exercises;
  final ValueChanged<ExerciseShort>? onTap;

  const _SimilarData({required this.exercises, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Похожие упражнения',
          style: AppTypography.mediumTextSemiBold
              .copyWith(color: AppColors.blackColor),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            addAutomaticKeepAlives: false,
            itemCount: exercises.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return _SimilarCard(
                exercise: exercise,
                onTap: onTap != null ? () => onTap!(exercise) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SimilarCard extends StatelessWidget {
  final ExerciseShort exercise;
  final VoidCallback? onTap;

  const _SimilarCard({required this.exercise, this.onTap});

  @override
  Widget build(BuildContext context) {
    final severity =
        ContraindicationSeverity.fromString(exercise.contraindication);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: exercise.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: exercise.imageUrl!,
                            fit: BoxFit.cover,
                            memCacheWidth: 140,
                            memCacheHeight: 64,
                            filterQuality: FilterQuality.low,
                            placeholder: (_, __) => Container(
                              color: AppColors.gray3,
                              child: const Icon(
                                Icons.fitness_center,
                                color: AppColors.gray2,
                                size: 20,
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.gray3,
                              child: const Icon(
                                Icons.fitness_center,
                                color: AppColors.gray2,
                                size: 20,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.gray3,
                            child: const Icon(
                              Icons.fitness_center,
                              color: AppColors.gray2,
                              size: 20,
                            ),
                          ),
                  ),
                ),
                if (severity != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _MiniBadge(severity: severity),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              exercise.name,
              style: AppTypography.smallTextSemiBold
                  .copyWith(color: AppColors.blackColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final ContraindicationSeverity severity;

  const _MiniBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = switch (severity) {
      ContraindicationSeverity.lowWeight => const Color(0xFFFFA726),
      ContraindicationSeverity.notRecommended => const Color(0xFFFF7043),
      ContraindicationSeverity.forbidden => const Color(0xFFE53935),
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.warning_amber, color: Colors.white, size: 12),
    );
  }
}

class _SimilarLoading extends StatelessWidget {
  const _SimilarLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Похожие упражнения',
          style: AppTypography.mediumTextSemiBold
              .copyWith(color: AppColors.blackColor),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            addAutomaticKeepAlives: false,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => Container(
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerCard(
                    width: double.infinity,
                    height: 64,
                    borderRadius: BorderRadius.zero,
                  ),
                  SizedBox(height: 8),
                  ShimmerCard(height: 12),
                  SizedBox(height: 4),
                  ShimmerCard(width: 80, height: 12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
