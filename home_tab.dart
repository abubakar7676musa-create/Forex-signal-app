import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forex_signals_app/core/theme/app_theme.dart';
import 'package:forex_signals_app/providers/auth_provider.dart';
import 'package:forex_signals_app/providers/price_provider.dart';
import 'package:forex_signals_app/providers/signal_provider.dart';
import 'package:forex_signals_app/screens/signals/signal_detail_screen.dart';
import 'package:forex_signals_app/widgets/error_view.dart';
import 'package:forex_signals_app/widgets/loading_indicator.dart';
import 'package:forex_signals_app/widgets/price_ticker_item.dart';
import 'package:forex_signals_app/widgets/signal_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final priceProvider = context.read<PriceProvider>();
      final signalProvider = context.read<SignalProvider>();
      priceProvider.loadPrices();
      priceProvider.startPolling();
      signalProvider.loadLatest();
      signalProvider.startPolling();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<PriceProvider>().loadPrices(),
      context.read<SignalProvider>().loadLatest(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final priceProvider = context.watch<PriceProvider>();
    final signalProvider = context.watch<SignalProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome${user?.fullName != null ? ', ${user!.fullName!.split(' ').first}' : ''} 👋',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'AI-generated signals updated in real time',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 20, bottom: 10),
                  child: Text('Live Prices', style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 92,
                  child: priceProvider.isLoading && priceProvider.prices.isEmpty
                      ? const LoadingIndicator()
                      : priceProvider.errorMessage != null && priceProvider.prices.isEmpty
                          ? ErrorView(message: priceProvider.errorMessage!, onRetry: priceProvider.loadPrices)
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: priceProvider.prices.length,
                              itemBuilder: (_, i) => PriceTickerItem(price: priceProvider.prices[i]),
                            ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, left: 20, bottom: 10, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('AI Signals', style: Theme.of(context).textTheme.titleMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.buy.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 7, color: AppColors.buy),
                            SizedBox(width: 5),
                            Text('Live', style: TextStyle(color: AppColors.buy, fontSize: 11.5, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (signalProvider.latestState == LoadState.loading && signalProvider.latestSignals.isEmpty)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: ShimmerList(count: 3)))
              else if (signalProvider.latestState == LoadState.error && signalProvider.latestSignals.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 240,
                    child: ErrorView(
                      message: signalProvider.errorMessage ?? 'Failed to load signals',
                      onRetry: signalProvider.loadLatest,
                    ),
                  ),
                )
              else if (signalProvider.latestSignals.isEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: EmptyView(message: 'No active signals right now.\nThe AI is watching the market.', icon: Icons.insights_rounded),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final signal = signalProvider.latestSignals[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SignalCard(
                            signal: signal,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => SignalDetailScreen(signal: signal)),
                            ),
                          ),
                        );
                      },
                      childCount: signalProvider.latestSignals.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
