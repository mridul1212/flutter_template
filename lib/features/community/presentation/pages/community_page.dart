import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/community/presentation/cubit/community_cubit.dart';
import 'package:flutter_template/features/community/presentation/pages/chat_room_page.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<CommunityCubit>().loadRooms());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Chat'),
        actions: [
          IconButton(icon: const Icon(Icons.group_add_outlined), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<CommunityCubit, CommunityState>(
        builder: (context, state) {
          if (state.load == CommunityLoad.loading && state.rooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.load == CommunityLoad.failure && state.rooms.isEmpty) {
            return Center(
              child: FilledButton.tonal(
                onPressed: () => context.read<CommunityCubit>().loadRooms(),
                child: Text(t.retry),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.rooms.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final room = state.rooms[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.brandPrimary.withValues(alpha: 0.15),
                  child: Text(room.name.characters.first, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${room.subtitle}\n${room.lastMessage}', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(room.lastTime, style: Theme.of(context).textTheme.bodySmall),
                    if (room.unread > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(12)),
                        child: Text('${room.unread}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CommunityCubit>(),
                        child: ChatRoomPage(roomId: room.id, roomName: room.name),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('New group'),
      ),
    );
  }
}
