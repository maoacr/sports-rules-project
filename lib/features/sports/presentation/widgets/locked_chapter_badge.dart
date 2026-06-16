import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Small lock icon used by [ChapterTile] (and reusable elsewhere) to signal
/// that a chapter is paid and the user has not yet unlocked it.
class LockedChapterBadge extends StatelessWidget {
  /// Optional override for the icon size.
  final double size;

  /// Optional override for the icon color. Defaults to [AppColors.locked].
  final Color? color;

  const LockedChapterBadge({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.lock,
      color: color ?? AppColors.locked,
      size: size,
    );
  }
}
