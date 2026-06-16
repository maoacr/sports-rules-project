import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/shared_preferences_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/purchases_bloc.dart';

/// Modal bottom sheet that lets the user buy access to a sport or restore
/// previous purchases.
///
/// The widget does NOT own purchase state — it dispatches events to
/// [PurchasesBloc] provided by an ancestor [BlocProvider]. The parent
/// page is expected to wrap the sheet in the same bloc, or to read
/// [SharedPreferencesStorage] for entitlement state.
class PaywallBottomSheet extends StatefulWidget {
  /// Sport identifier — also used as the RevenueCat entitlement id.
  final String sportId;

  /// Display title shown in the sheet header.
  final String sportTitle;

  /// Price in cents (matches the [Sport.price] convention).
  final int priceCents;

  /// Product identifier in the app store (e.g. `football_full_unlock`).
  /// If null, [sportId] is used as the product id.
  final String? productId;

  /// Invoked after a successful purchase or restore that grants the
  /// current [sportId].
  final ValueChanged<String> onPurchaseSuccess;

  const PaywallBottomSheet({
    super.key,
    required this.sportId,
    required this.sportTitle,
    required this.priceCents,
    this.productId,
    required this.onPurchaseSuccess,
  });

  /// Convenience helper that shows this sheet via [showModalBottomSheet].
  static Future<void> show({
    required BuildContext context,
    required String sportId,
    required String sportTitle,
    required int priceCents,
    String? productId,
    required ValueChanged<String> onPurchaseSuccess,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<PurchasesBloc>(),
        child: PaywallBottomSheet(
          sportId: sportId,
          sportTitle: sportTitle,
          priceCents: priceCents,
          productId: productId,
          onPurchaseSuccess: onPurchaseSuccess,
        ),
      ),
    );
  }

  @override
  State<PaywallBottomSheet> createState() => _PaywallBottomSheetState();
}

class _PaywallBottomSheetState extends State<PaywallBottomSheet> {
  bool _busy = false;

  String get _priceLabel {
    if (widget.priceCents <= 0) return 'Free';
    final dollars = widget.priceCents / 100.0;
    return '\$${dollars.toStringAsFixed(2)}';
  }

  String get _productId => widget.productId ?? widget.sportId;

  void _onBuyPressed() {
    if (_busy) return;
    setState(() => _busy = true);
    context.read<PurchasesBloc>().add(
          PurchaseRequested(
            sportId: widget.sportId,
            productId: _productId,
          ),
        );
  }

  void _onRestorePressed() {
    if (_busy) return;
    setState(() => _busy = true);
    context.read<PurchasesBloc>().add(const RestoreRequested());
  }

  void _close() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<PurchasesBloc, PurchasesState>(
      listener: (context, state) {
        if (state is PurchaseLoading) {
          setState(() => _busy = true);
          return;
        }

        // Always clear the busy flag for terminal states.
        if (state is PurchaseSuccess) {
          setState(() => _busy = false);
          // Only fire the success callback if it matches this sport.
          if (state.sportId == widget.sportId) {
            widget.onPurchaseSuccess(state.sportId);
            _close();
          }
          return;
        }

        if (state is PurchaseFailure) {
          setState(() => _busy = false);
          _showError(state.message);
          return;
        }

        if (state is EntitlementsLoaded) {
          setState(() => _busy = false);
          // Local cache holds the canonical list of purchased sport ids.
          final prefs = getIt<SharedPreferencesStorage>();
          final purchased = prefs.purchasedSports;
          if (purchased.contains(widget.sportId)) {
            widget.onPurchaseSuccess(widget.sportId);
            _close();
          } else {
            _showError('No previous purchases found.');
          }
        }
      },
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle.
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title row.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.sportTitle,
                      style: theme.textTheme.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _priceLabel,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Unlock all chapters and dive deep into the rules.',
                style: AppTypography.body1,
              ),
              const SizedBox(height: 16),

              // Features list.
              const _Feature(icon: Icons.menu_book, text: 'Full rulebook access'),
              const _Feature(icon: Icons.bookmark, text: 'Bookmark your favorite rules'),
              const _Feature(icon: Icons.offline_bolt, text: 'Read offline, anytime'),
              const SizedBox(height: 24),

              // Buy button.
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _onBuyPressed,
                  icon: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.lock_open),
                  label: Text(
                    widget.priceCents > 0 ? 'Buy for $_priceLabel' : 'Unlock for free',
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Restore + close.
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _busy ? null : _onRestorePressed,
                      child: const Text('Restore purchases'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: _busy ? null : _close,
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Feature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.body1)),
        ],
      ),
    );
  }
}
