import 'package:flutter/material.dart';
import 'package:flutter_template/features/mondop/data/models/mondop_models.dart';
import 'package:flutter_template/features/mondop/presentation/widgets/mondop_map_projection.dart';
import 'package:flutter_template/features/mondop/presentation/widgets/mondop_offline_map_painter.dart';

/// Offline map — no API key, no internet tiles. Dummy Bangladesh lat/lng only.
class MondopOfflineMap extends StatefulWidget {
  const MondopOfflineMap({
    super.key,
    required this.mondops,
    required this.userPosition,
    this.selectedId,
    this.onMondopTap,
  });

  final List<MondopWithDistance> mondops;
  final MapPosition? userPosition;
  final String? selectedId;
  final ValueChanged<MondopItem>? onMondopTap;

  @override
  State<MondopOfflineMap> createState() => _MondopOfflineMapState();
}

class _MondopOfflineMapState extends State<MondopOfflineMap> {
  final _transform = TransformationController();

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final projection = MondopMapProjection(
          mondops: widget.mondops,
          userPosition: widget.userPosition,
          size: size,
        );

        return InteractiveViewer(
          transformationController: _transform,
          minScale: 0.85,
          maxScale: 2.5,
          child: GestureDetector(
            onTapUp: (d) {
              final hit = projection.hitTest(d.localPosition);
              if (hit != null) widget.onMondopTap?.call(hit);
            },
            child: CustomPaint(
              size: size,
              painter: MondopOfflineMapPainter(
                projection: projection,
                selectedId: widget.selectedId,
                scheme: scheme,
              ),
            ),
          ),
        );
      },
    );
  }
}
