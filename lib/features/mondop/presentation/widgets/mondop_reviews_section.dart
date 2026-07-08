import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/core/utils/validators.dart';
import 'package:flutter_template/features/mondop/data/models/mondop_models.dart';
import 'package:flutter_template/features/mondop/presentation/cubit/mondop_detail_cubit.dart';
import 'package:flutter_template/shared/widgets/app_text_field.dart';

class MondopReviewsSection extends StatelessWidget {
  const MondopReviewsSection({super.key, required this.summary, required this.mondopId});

  final MondopReviewSummary summary;
  final String mondopId;

  void _showReviewForm(BuildContext context) {
    var rating = 5;
    final commentCtrl = TextEditingController();
    String? commentErr;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) {
          return Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Write a review', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      onPressed: () => setModal(() => rating = i + 1),
                      icon: Icon(i < rating ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.brandTertiary),
                    ),
                  ),
                ),
                AppTextField(controller: commentCtrl, label: 'Your review', maxLines: 3, errorText: commentErr),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final err = Validators.reviewComment(commentCtrl.text);
                    setModal(() => commentErr = err);
                    if (err != null) return;
                    context.read<MondopDetailCubit>().submitReview(rating: rating, comment: commentCtrl.text);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Submit review'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.brandTertiary),
                Text(' ${summary.averageRating.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text(' (${summary.reviewCount} reviews)', style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                TextButton(onPressed: () => _showReviewForm(context), child: const Text('Add review')),
              ],
            ),
            const SizedBox(height: 12),
            ...summary.items.take(5).map(
                  (r) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text(r.user.characters.first)),
                    title: Text(r.user, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(r.comment),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < r.rating ? AppColors.brandTertiary : Colors.grey.shade300)),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
