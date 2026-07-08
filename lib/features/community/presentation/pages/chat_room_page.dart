import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/community/presentation/cubit/community_cubit.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key, required this.roomId, required this.roomName});

  final String roomId;
  final String roomName;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityCubit>().openRoom(widget.roomId);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    context.read<CommunityCubit>().closeRoom();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text;
    if (text.trim().isEmpty) return;
    context.read<CommunityCubit>().send(text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomName)),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CommunityCubit, CommunityState>(
              builder: (context, state) {
                if (state.load == CommunityLoad.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.messages.length,
                  itemBuilder: (context, i) {
                    final m = state.messages[i];
                    return Align(
                      alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: m.isMe ? AppColors.brandPrimary.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!m.isMe) Text(m.sender, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            Text(m.text),
                            const SizedBox(height: 4),
                            Text(m.time, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Type a message…',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: _send, icon: const Icon(Icons.send_rounded)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
