import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/network/api_endpoints.dart';
import 'package:flutter_template/features/home/presentation/cubit/dashboard_cubit.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  Widget _buildBody(BuildContext context, DashboardState state, ColorScheme scheme) {
    switch (state.loadState) {
      case DashboardLoad.initial:
      case DashboardLoad.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(),
          ),
        );
      case DashboardLoad.failure:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(state.error ?? 'Unknown error', style: TextStyle(color: scheme.error)),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => context.read<DashboardCubit>().loadSample(),
              child: const Text('Retry'),
            ),
          ],
        );
      case DashboardLoad.success:
        final post = state.post;
        if (post == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('GET /posts/1', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              post.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              post.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 8),
            Text(
              'userId: ${post.userId}  ·  id: ${post.id}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return RepaintBoundary(
          child: RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().loadSample(),
            child: ListView(
              padding: const EdgeInsets.all(24),
              cacheExtent: 250,
              children: [
              Text('Network demo', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Base URL: ${ApiEndpoints.baseUrl}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              _buildBody(context, state, scheme),
              const SizedBox(height: 28),
              Text('Exercise all verbs', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(
                'Runs GET, POST, PUT, PATCH, DELETE in order against the dummy API. '
                'Per-request headers can be merged in ApiClient calls (see PostsRemoteDataSource).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: state.smokeBusy ? null : () => context.read<DashboardCubit>().runHttpVerbsDemo(),
                icon: state.smokeBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_sync_rounded),
                label: Text(state.smokeBusy ? 'Running…' : 'Run POST / PUT / PATCH / DELETE'),
              ),
              if (state.smokeMessage != null) ...[
                const SizedBox(height: 12),
                SelectableText(
                  state.smokeMessage!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              ],
            ),
          ),
        );
      },
    );
  }
}
