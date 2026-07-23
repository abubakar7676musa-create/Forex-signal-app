import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forex_signals_app/core/constants/app_constants.dart';
import 'package:forex_signals_app/core/theme/app_theme.dart';
import 'package:forex_signals_app/providers/signal_provider.dart';
import 'package:forex_signals_app/screens/signals/signal_detail_screen.dart';
import 'package:forex_signals_app/widgets/error_view.dart';
import 'package:forex_signals_app/widgets/loading_indicator.dart';
import 'package:forex_signals_app/widgets/signal_card.dart';

class SignalHistoryScreen extends StatefulWidget {
  const SignalHistoryScreen({super.key});

  @override
  State<SignalHistoryScreen> createState() => _SignalHistoryScreenState();
}

class _SignalHistoryScreenState extends State<SignalHistoryScreen> {
  String? _selectedPair;
  String? _selectedDirection;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SignalProvider>().loadHistory());
  }

  void _applyFilters() {
    context.read<SignalProvider>().loadHistory(pair: _selectedPair, direction: _selectedDirection);
  }

  @override
  Widget build(BuildContext context) {
    final signalProvider = context.watch<SignalProvider>();
    final filteredPairs = AppConstants.supportedPairs
        .where((p) => p.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Signal History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search currency pair (e.g. EUR/USD)',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() => _searchController.clear()),
                      )
                    : null,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredPairs.length,
                itemBuilder: (_, i) {
                  final pair = filteredPairs[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(pair, style: const TextStyle(fontSize: 12.5)),
                      selected: _selectedPair == pair,
                      onSelected: (selected) {
                        setState(() => _selectedPair = selected ? pair : null);
                        _applyFilters();
                      },
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _DirectionFilterChip(
                  label: 'All',
                  selected: _selectedDirection == null,
                  onTap: () {
                    setState(() => _selectedDirection = null);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                _DirectionFilterChip(
                  label: 'Buy',
                  color: AppColors.buy,
                  selected: _selectedDirection == 'BUY',
                  onTap: () {
                    setState(() => _selectedDirection = 'BUY');
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                _DirectionFilterChip(
                  label: 'Sell',
                  color: AppColors.sell,
                  selected: _selectedDirection == 'SELL',
                  onTap: () {
                    setState(() => _selectedDirection = 'SELL');
                    _applyFilters();
                  },
                ),
                if (_selectedPair != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(_selectedPair!, style: const TextStyle(fontSize: 12)),
                    onDeleted: () {
                      setState(() => _selectedPair = null);
                      _applyFilters();
                    },
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Builder(builder: (_) {
              if (signalProvider.historyState == LoadState.loading) {
                return const ShimmerList();
              }
              if (signalProvider.historyState == LoadState.error) {
                return ErrorView(
                  message: signalProvider.errorMessage ?? 'Failed to load signal history',
                  onRetry: _applyFilters,
                );
              }
              if (signalProvider.historySignals.isEmpty) {
                return const EmptyView(message: 'No signals found for this filter.', icon: Icons.history_rounded);
              }
              return RefreshIndicator(
                onRefresh: () async => _applyFilters(),
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: signalProvider.historySignals.length,
                  itemBuilder: (_, i) {
                    final signal = signalProvider.historySignals[i];
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
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DirectionFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _DirectionFilterChip({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: chipColor.withOpacity(0.2),
      labelStyle: TextStyle(color: selected ? chipColor : AppColors.textSecondary, fontSize: 13),
      onSelected: (_) => onTap(),
    );
  }
}
