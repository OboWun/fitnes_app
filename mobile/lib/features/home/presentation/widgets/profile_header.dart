import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

class ProfileHeader extends StatelessWidget {
  final String? _name;
  final String? _gender;
  final VoidCallback? _onTap;

  const ProfileHeader({
    super.key,
    required String name,
    String? gender,
    VoidCallback? onTap,
  })  : _name = name,
        _gender = gender,
        _onTap = onTap;

  const ProfileHeader.loading({super.key})
      : _name = null,
        _gender = null,
        _onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_name == null) return const _ProfileHeaderLoading();
    return _ProfileHeaderData(
      name: _name,
      gender: _gender,
      onTap: _onTap,
    );
  }
}

class _ProfileHeaderData extends StatelessWidget {
  final String name;
  final String? gender;
  final VoidCallback? onTap;

  const _ProfileHeaderData({
    required this.name,
    this.gender,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Привет, $name!',
                  style: AppTypography.h3Bold.copyWith(
                    color: AppColors.blackColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Готов к тренировке?',
                  style: AppTypography.mediumTextRegular.copyWith(
                    color: AppColors.gray1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gender == 'female'
                  ? AppGradients.purpleLinear
                  : AppGradients.blueLinear,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              gender == 'female' ? Icons.female : Icons.male,
              color: AppColors.whiteColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderLoading extends StatelessWidget {
  const _ProfileHeaderLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerCard(
                height: 24,
                width: 160,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 6),
              ShimmerCard(
                height: 16,
                width: 120,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
        ShimmerCard(
          width: 48,
          height: 48,
          borderRadius: BorderRadius.circular(16),
        ),
      ],
    );
  }
}
