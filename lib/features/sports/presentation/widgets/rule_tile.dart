import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/sport.dart';

/// ListTile for a single rule row in a chapter.
class RuleTile extends StatelessWidget {
  final Rule rule;
  final VoidCallback onTap;

  const RuleTile({
    super.key,
    required this.rule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          child: Text('${rule.order}'),
        ),
        title: Text(
          rule.title,
          style: AppTypography.subtitle1,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          rule.content,
          style: AppTypography.body2,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
