import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/shared_preferences_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../sports/domain/entities/sport.dart';
import '../../../sports/presentation/bloc/sports_bloc.dart';
import '../bloc/purchases_bloc.dart';
import '../widgets/paywall_bottom_sheet.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  late final SportsBloc _sportsBloc;
  late final PurchasesBloc _purchasesBloc;
  late final SharedPreferencesStorage _prefs;

  @override
  void initState() {
    super.initState();
    _sportsBloc = getIt<SportsBloc>()..add(const SportsLoadRequested());
    _purchasesBloc = getIt<PurchasesBloc>();
    _prefs = getIt<SharedPreferencesStorage>();
  }

  @override
  void dispose() {
    _sportsBloc.close();
    _purchasesBloc.close();
    super.dispose();
  }

  Set<String> _purchasedSportIds() {
    final cached = _prefs.purchasedSports;
    if (cached.isNotEmpty) return {...cached};
    return {};
  }

  bool _isPurchased(Sport sport) {
    if (sport.price == 0) return true;
    return _purchasedSportIds().contains(sport.id);
  }

  void _onRestore() {
    _purchasesBloc.add(const RestoreRequested());
  }

  void _onBuySport(BuildContext context, Sport sport) {
    PaywallBottomSheet.show(
      context: context,
      sportId: sport.id,
      sportTitle: sport.title,
      priceCents: sport.price,
      onPurchaseSuccess: (purchasedSportId) {
        setState(() {});
        if (sport.price == 0) {
          context.push('/sports/$purchasedSportId');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _sportsBloc),
        BlocProvider.value(value: _purchasesBloc),
      ],
      child: BlocListener<PurchasesBloc, PurchasesState>(
        listener: (context, state) {
          if (state is EntitlementsLoaded) {
            setState(() {});
          }
          if (state is PurchaseFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Store'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.restore),
                tooltip: 'Restore purchases',
                onPressed: _onRestore,
              ),
            ],
          ),
          body: BlocBuilder<SportsBloc, SportsState>(
            bloc: _sportsBloc,
            builder: (context, state) {
              if (state is SportsLoading || state is SportsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is SportsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            _sportsBloc.add(const SportsLoadRequested()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (state is SportsLoaded) {
                if (state.sports.isEmpty) {
                  return const Center(child: Text('No sports available yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.sports.length,
                  itemBuilder: (context, index) {
                    final sport = state.sports[index];
                    return _SportPurchaseCard(
                      sport: sport,
                      isPurchased: _isPurchased(sport),
                      onBuy: () => _onBuySport(context, sport),
                      onTap: _isPurchased(sport)
                          ? () => context.push('/sports/${sport.id}')
                          : null,
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _SportPurchaseCard extends StatelessWidget {
  final Sport sport;
  final bool isPurchased;
  final VoidCallback onBuy;
  final VoidCallback? onTap;

  const _SportPurchaseCard({
    required this.sport,
    required this.isPurchased,
    required this.onBuy,
    this.onTap,
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
                child: sport.thumbnailUrl.isEmpty
                    ? Container(
                        width: 64,
                        height: 64,
                        color: AppColors.divider,
                        child: const Icon(Icons.sports, color: AppColors.textHint),
                      )
                    : Image.network(
                        sport.thumbnailUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 64,
                          height: 64,
                          color: AppColors.divider,
                          child: const Icon(Icons.sports, color: AppColors.textHint),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sport.title,
                            style: AppTypography.subtitle1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPurchased) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 12,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Purchased',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sport.description,
                      style: AppTypography.body2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${sport.lawCount} laws',
                          style: AppTypography.caption,
                        ),
                        const Spacer(),
                        if (!isPurchased) ...[
                          Text(
                            _priceLabel,
                            style: AppTypography.subtitle2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: onBuy,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                textStyle: AppTypography.button,
                              ),
                              child: const Text('Buy'),
                            ),
                          ),
                        ] else ...[
                          if (sport.price > 0)
                            Text(
                              _priceLabel,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
