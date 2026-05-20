import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../home/home_provider.dart';
import '../../training_plans/data/training_plan_repository.dart';
import '../../training_plans/plan_list_provider.dart';
import '../../workout_milp/data/workout_milp_repository.dart';
import '../../workout_templates/template_list_provider.dart';
import '../data/chat_repository.dart';
import '../domain/chat_message.dart';
import '../domain/chat_session.dart';
import 'widgets/chat_input_field.dart';
import 'widgets/choice_options.dart';
import 'widgets/coach_message_bubble.dart';
import 'widgets/dialog_complete_card.dart';
import 'widgets/number_input.dart';
import 'widgets/preset_options.dart';
import 'widgets/system_message_bubble.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/user_message_bubble.dart';

part '_widgets.dart';

class WorkoutDialogPage extends ConsumerStatefulWidget {
  const WorkoutDialogPage({super.key});

  @override
  ConsumerState<WorkoutDialogPage> createState() => _WorkoutDialogPageState();
}

class _WorkoutDialogPageState extends ConsumerState<WorkoutDialogPage> {
  final _scrollController = ScrollController();
  final _selectedMultiValues = <String>{};

  ChatSession? _session;
  List<ChatMessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isCreating = false;
  bool _isSwitchingMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSession());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ChatMessageModel? get _lastAssistantStep {
    for (int i = _messages.length - 1; i >= 0; i--) {
      final m = _messages[i];
      if (m.role == ChatRole.assistant && m.isDialogStep) return m;
    }
    return null;
  }

  ChatMessageModel? get _completeMessage {
    for (int i = _messages.length - 1; i >= 0; i--) {
      final m = _messages[i];
      if (m.role == ChatRole.assistant && m.isDialogComplete) return m;
    }
    return null;
  }

  bool get _isComplete => _isWorkoutMode && _completeMessage != null;

  bool get _isWorkoutMode => _session?.mode == ChatMode.workout;

  Future<void> _initSession() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final sessions = await repo.getSessions();
      final workoutSessions =
          sessions.where((s) => s.mode == ChatMode.workout).toList();

      if (workoutSessions.isNotEmpty) {
        final last = workoutSessions.first;
        final result = await repo.getSession(last.id);
        if (mounted) {
          setState(() {
            _session = result.session;
            _messages = result.messages;
            _isLoading = false;
          });
          _scrollToBottom();
          return;
        }
      }

      await _createNewSession();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Ошибка: $e');
      }
    }
  }

  Future<void> _createNewSession() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final session = await repo.createSession(mode: ChatMode.workout);
      final full = await repo.getSession(session.id);
      if (mounted) {
        setState(() {
          _session = full.session;
          _messages = full.messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Ошибка: $e');
      }
    }
  }

  Future<void> _switchMode(ChatMode newMode) async {
    if (_session == null || _session!.mode == newMode) return;
    setState(() => _isSwitchingMode = true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.switchMode(_session!.id, newMode);
      final full = await repo.getSession(_session!.id);
      if (mounted) {
        setState(() {
          _session = full.session;
          _messages = full.messages;
          _isSwitchingMode = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSwitchingMode = false);
        _showError('Ошибка: $e');
      }
    }
  }

  Future<void> _startNewGeneration() async {
    if (_session == null) return;
    setState(() => _isCreating = true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.deleteSession(_session!.id);
      final session = await repo.createSession(mode: ChatMode.workout);
      final full = await repo.getSession(session.id);
      if (mounted) {
        setState(() {
          _session = full.session;
          _messages = full.messages;
          _isCreating = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        _showError('Ошибка: $e');
      }
    }
  }

  Future<void> _onClose() async {
    if (_isComplete) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (ctx) => _CloseConfirmDialog(),
    );
    if (shouldClose == true && mounted) Navigator.of(context).pop();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  Future<void> _onSingleSelect(String value) async {
    if (_session == null) return;
    setState(() => _isSending = true);
    _scrollToBottom();
    await _sendMessage(value);
  }

  void _onMultiToggle(String value) {
    setState(() {
      if (_selectedMultiValues.contains(value)) {
        _selectedMultiValues.remove(value);
      } else {
        _selectedMultiValues.add(value);
      }
    });
  }

  Future<void> _onMultiSubmit() async {
    if (_selectedMultiValues.isEmpty || _session == null) return;
    final answer = _selectedMultiValues.join(',');
    setState(() {
      _isSending = true;
      _selectedMultiValues.clear();
    });
    _scrollToBottom();
    await _sendMessage(answer);
  }

  Future<void> _onChatSubmit(String text) async {
    if (text.trim().isEmpty || _session == null) return;
    setState(() => _isSending = true);
    _scrollToBottom();
    await _sendMessage(text.trim());
  }

  Future<void> _sendMessage(String content) async {
    try {
      final repo = ref.read(chatRepositoryProvider);
      final result = await repo.sendMessage(_session!.id, content);

      if (_isWorkoutMode) {
        final full = await repo.getSession(_session!.id);
        if (mounted) {
          setState(() {
            _messages = full.messages;
            _isSending = false;
          });
          _scrollToBottom();
        }
        return;
      }

      if (mounted) {
        setState(() {
          _messages.add(ChatMessageModel(
            id: result.userMessageId,
            sessionId: _session!.id,
            role: ChatRole.user,
            content: content,
          ));
          _messages.add(ChatMessageModel(
            id: result.assistantMessageId,
            sessionId: _session!.id,
            role: ChatRole.assistant,
            content: result.content,
          ));
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) _showError('Ошибка: $e');
    }
  }

  Future<void> _onCreateFromDialog() async {
    final complete = _completeMessage;
    if (complete == null) return;
    setState(() => _isCreating = true);

    try {
      final params = complete.dialogParams ?? {};
      final planType = complete.planType ?? 'generate';
      final repo = ref.read(workoutMilpRepositoryProvider);

      if (planType == 'generate') {
        final result = await repo.generate(params);
        final templateId = result['templateId'] as String;

        if (mounted) {
          ref.read(templateListProvider.notifier).refresh();
          context.push('/workouts/$templateId');
        }
      } else {
        final result = await repo.weeklyPlan(params);
        final planId = result['planId'] as String;

        if (mounted) {
          ref.read(planListProvider.notifier).refresh();

          final shouldActivate = await _showActivateDialog();
          if (shouldActivate == true) {
            try {
              final planRepo = ref.read(trainingPlanRepositoryProvider);
              await planRepo.activate(planId);
              ref.read(planListProvider.notifier).refresh();
              ref.read(homeProvider.notifier).refresh();
            } catch (e) {
              if (mounted) _showError('Ошибка активации: $e');
            }
          }

          context.push('/training-plans/$planId');
        }
      }
    } catch (e) {
      if (mounted) _showError('Ошибка: $e');
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<bool?> _showActivateDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => _ActivatePlanDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: _AppBar(
        isWorkout: _isWorkoutMode,
        isSwitchingMode: _isSwitchingMode,
        session: _session,
        onClose: _onClose,
        onToggleMode: () => _switchMode(
          _isWorkoutMode ? ChatMode.chat : ChatMode.workout,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blackColor),
            )
          : Column(
              children: [
                Expanded(
                  child: _MessageList(
                    messages: _messages,
                    isSending: _isSending,
                    isComplete: _isComplete,
                    completeMessage: _completeMessage,
                    isCreating: _isCreating,
                    onCreateFromDialog: _onCreateFromDialog,
                    onNewGeneration: _isComplete && _isWorkoutMode
                        ? _startNewGeneration
                        : null,
                    scrollController: _scrollController,
                  ),
                ),
                if (!_isSending && (!_isComplete || !_isWorkoutMode))
                  _buildFooter(),
              ],
            ),
    );
  }

  Widget _buildFooter() {
    if (_isWorkoutMode) return _buildWorkoutFooter();
    return _ChatFooter(onSubmitted: _onChatSubmit, isEnabled: !_isSending);
  }

  Widget _buildWorkoutFooter() {
    final step = _lastAssistantStep;
    if (step == null) {
      return _ChatFooter(onSubmitted: _onChatSubmit, isEnabled: !_isSending);
    }

    final inputType = step.dialogInputType ?? DialogInputType.singleChoice;

    if (step.dialogStep == 'equipment_preset') {
      return _FooterContainer(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        child: PresetOptions(
          options: step.dialogOptions,
          onSelect: _onSingleSelect,
        ),
      );
    }

    if (inputType == DialogInputType.number) {
      return _FooterContainer(
        child: NumberInput(hint: null, onSubmit: _onSingleSelect),
      );
    }

    return _FooterContainer(
      child: ChoiceOptions(
        options: step.dialogOptions,
        inputType: inputType,
        selectedValues: _selectedMultiValues,
        onSingleSelect: _onSingleSelect,
        onMultiToggle: _onMultiToggle,
        onMultiSubmit: _onMultiSubmit,
      ),
    );
  }
}
