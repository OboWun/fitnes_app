import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/trainer_chat_card.dart';

class TrainerChatCardSmart extends StatelessWidget {
  const TrainerChatCardSmart({super.key});

  @override
  Widget build(BuildContext context) {
    return TrainerChatCard(
      onTap: () => context.push('/workout-dialog'),
    );
  }
}
