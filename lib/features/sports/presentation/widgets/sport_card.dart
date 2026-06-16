import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/sport.dart';

/// Card widget for the sport list on the home page.
class SportCard extends StatelessWidget {
  final Sport sport;
  final VoidCallback onTap;

  const SportCard({
    super.key,
    required this.sport,
    required this.onTap,
  });

  String get _priceLabel {
    if (sport.price <= 0) return 'Free';
    final dollars = sport.price / 100.0;
    return '\$${dollars.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: sport.thumbnailUrl.isEmpty
                      ? _Placeholder()
                      : CachedNetworkImage(
                          imageUrl: sport.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: AppColors.divider,
                            highlightColor: AppColors.surface,
                            child: Container(color: AppColors.divider),
                          ),
                          errorWidget: (_, __, ___) => const _Placeholder(),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sport.title,
                      style: AppTypography.subtitle1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sport.description,
                      style: AppTypography.body2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${sport.chapterCount} chapters',
                          style: AppTypography.caption,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _priceLabel,
                          style: AppTypography.caption.copyWith(
                            color: sport.price > 0
                                ? AppColors.primary
                                : AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.divider,
      child: const Icon(
        Icons.sports_soccer,
        size: 32,
        color: AppColors.textHint,
      ),
    );
  }
}
