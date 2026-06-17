import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/law.dart';
import 'locked_chapter_badge.dart';

/// ListTile for a Law row. Shows the law number, title, article count,
/// and a lock icon when the law is paid and the sport is not yet
/// purchased.
class LawTile extends StatelessWidget {
  final Law law;
  final bool isLocked;
  final VoidCallback onTap;

  const LawTile({
    super.key,
    required this.law,
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
          child: Text('${law.number}'),
        ),
        title: Text(
          law.title,
          style: AppTypography.subtitle1,
        ),
        subtitle: Text(
          '${law.articlesCount} articles',
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
