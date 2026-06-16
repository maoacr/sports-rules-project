import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/sport.dart';
import 'locked_chapter_badge.dart';

/// ListTile for a chapter row. Shows the chapter number, title, rule count,
/// and a lock icon when the chapter is paid and the sport is not yet
/// purchased.
class ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final bool isLocked;
  final VoidCallback onTap;

  const ChapterTile({
    super.key,
    required this.chapter,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLocked ? AppColors.locked : AppColors.unlocked,
          foregroundColor: Colors.white,
          child: Text('${chapter.number}'),
        ),
        title: Text(
          chapter.title,
          style: AppTypography.subtitle1,
        ),
        subtitle: Text(
          '${chapter.rulesCount} rules',
          style: AppTypography.body2,
        ),
        trailing: isLocked
            ? const LockedChapterBadge()
            : const Icon(
                Icons.check_circle,
                color: AppColors.unlocked,
              ),
        onTap: onTap,
      ),
    );
  }
}
