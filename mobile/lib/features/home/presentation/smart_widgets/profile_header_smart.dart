import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/public.dart';
import '../widgets/profile_header.dart';

class ProfileHeaderSmart extends ConsumerWidget {
  const ProfileHeaderSmart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.select((s) => s.user));

    if (user == null) return const ProfileHeader.loading();

    return ProfileHeader(
      name: user.name ?? 'Атлет',
      gender: user.gender,
      onTap: () => context.push('/profile'),
    );
  }
}
