import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/shared_preferences_storage.dart';
import '../../../purchases/presentation/bloc/purchases_bloc.dart';
import '../../../purchases/presentation/widgets/paywall_bottom_sheet.dart';
import '../bloc/law_bloc.dart';
import '../widgets/law_tile.dart';

class LawListPage extends StatelessWidget {
  final String sportId;

  const LawListPage({super.key, required this.sportId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LawBloc(getIt())..add(LawsLoadRequested(sportId)),
      child: BlocProvider<PurchasesBloc>(
        create: (_) => PurchasesBloc(
          getIt(),
          getIt<SharedPreferencesStorage>(),
        ),
        child: Scaffold(
          appBar: AppBar(title: const Text('Laws')),
          body: BlocBuilder<LawBloc, LawState>(
            builder: (context, state) {
              if (state is LawsLoading || state is LawsInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is LawsError) {
                return Center(child: Text(state.message));
              } else if (state is LawsLoaded) {
                final prefs = getIt<SharedPreferencesStorage>();
                final purchased = prefs.purchasedSports;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.laws.length,
                  itemBuilder: (context, index) {
                    final law = state.laws[index];
                    final isLocked =
                        !law.isFree && !purchased.contains(sportId);
                    return LawTile(
                      law: law,
                      isLocked: isLocked,
                      onTap: isLocked
                          ? () => _showPaywall(context, law: law)
                          : () => context.push(
                                '/sports/$sportId/laws/${law.id}',
                              ),
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

  void _showPaywall(BuildContext context, {required dynamic law}) {
    PaywallBottomSheet.show(
      context: context,
      sportId: sportId,
      sportTitle: law.sportTitle as String,
      priceCents: 0,
      onPurchaseSuccess: (_) {
        context.read<LawBloc>().add(LawsLoadRequested(sportId));
      },
    );
  }
}
