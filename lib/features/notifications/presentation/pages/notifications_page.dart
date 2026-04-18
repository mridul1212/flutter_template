import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:flutter_template/features/notifications/presentation/cubit/notification_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().refreshStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listenWhen: (p, c) =>
            (c.message != null && c.message != p.message) ||
            (c.errorMessage != null && c.errorMessage != p.errorMessage),
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          if (state.message != null) {
            messenger.showSnackBar(SnackBar(content: Text(state.message!)));
            context.read<NotificationCubit>().clearTransient();
          }
          if (state.errorMessage != null) {
            messenger.showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<NotificationCubit>().clearTransient();
          }
        },
        builder: (context, state) {
          if (state.initializing) {
            return const Center(child: CircularProgressIndicator());
          }
          final text = Theme.of(context).textTheme;
          final scheme = Theme.of(context).colorScheme;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Local notifications', style: text.titleMedium),
              const SizedBox(height: 8),
              Text(
                'This stack uses flutter_local_notifications with a domain repository. '
                'Add Firebase Messaging later and forward remote payloads into the same channel.',
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.35),
              ),
              const SizedBox(height: 24),
              _StatusCard(state: state),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: state.busy ? null : () => context.read<NotificationCubit>().requestPermission(),
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Request permission'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: state.busy ? null : () => context.read<NotificationCubit>().sendTestNotification(),
                icon: const Icon(Icons.send_outlined),
                label: const Text('Send test notification'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});

  final NotificationState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    String systemLine;
    if (state.systemNotificationsEnabled == null) {
      systemLine = 'System channel: unknown (often iOS — use permission result).';
    } else {
      systemLine = 'OS notifications enabled: ${state.systemNotificationsEnabled!}';
    }
    final perm = state.permissionGranted;
    final permLine = perm == null ? 'Runtime permission: not requested yet.' : 'Last permission result: $perm';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(systemLine, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(permLine, style: Theme.of(context).textTheme.bodyMedium),
            if (state.busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (state.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(state.errorMessage!, style: TextStyle(color: scheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}
