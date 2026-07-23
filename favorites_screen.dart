import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forex_signals_app/core/constants/app_constants.dart';
import 'package:forex_signals_app/core/theme/app_theme.dart';
import 'package:forex_signals_app/providers/auth_provider.dart';
import 'package:forex_signals_app/providers/signal_provider.dart';
import 'package:forex_signals_app/screens/signals/signal_detail_screen.dart';
import 'package:forex_signals_app/services/user_service.dart';
import 'package:forex_signals_app/widgets/error_view.dart';
import 'package:forex_signals_app/widgets/loading_indicator.dart';
import 'package:forex_signals_app/widgets/signal_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final UserService _userService = UserService();
  bool _savingFavorites = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SignalProvider>().loadFavorites());
  }

  Future<void> _toggleFavorite(String pair) async {
    final auth = context.read<AuthProvider>();
    final current = List<String>.from(auth.currentUser?.favoritePairs ?? []);
    if (current.contains(pair)) {
      current.remove(pair);
    } else {
      current.add(pair);
    }

    setState(() => _savingFavorites = true);
    try {
      await _userService.updateProfile(favoritePairs: current);
      auth.updateFavorites(current);
      context.read<SignalProvider>().loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update favorites: $e')));
      }
    } finally {
      if (mounted) setState(() => _savingFavorites = false);
    }
  }

  void _showPairPicker() {
    final auth = context.read<AuthProvider>();
    final favorites = auth.currentUser?.favoritePairs ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Manage Favorite Pairs', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.supportedPairs.map((pair) {
                    final isFav = favorites.contains(pair);
                    return FilterChip(
                      label: Text(pair),
                      selected: isFav,
                      onSelected: (_) => _toggleFavorite(pair),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final signalProvider = context.watch<SignalProvider>();
    final favorites = auth.currentUser?.favoritePairs ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: _savingFavorites
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.tune_rounded),
            onPressed: _savingFavorites ? null : _showPairPicker,
          ),
        ],
      ),
      body: favorites.isEmpty
          ? EmptyView(
              message: 'You haven\'t added any favorite pairs yet.\nTap the filter icon to add some.',
              icon: Icons.star_border_rounded,
            )
          : Builder(builder: (_) {
              if (signalProvider.favoritesState == LoadState.loading) {
                return const ShimmerList();
              }
              if (signalProvider.favoritesState == LoadState.error) {
                return ErrorView(
                  message: signalProvider.errorMessage ?? 'Failed to load favorite signals',
                  onRetry: () => context.read<SignalProvider>().loadFavorites(),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Wrap(
                      spacing: 6,
                      children: favorites.map((p) => Chip(label: Text(p, style: const TextStyle(fontSize: 11.5)))).toList(),
                    ),
                  ),
                  Expanded(
                    child: signalProvider.favoriteSignals.isEmpty
                        ? const EmptyView(message: 'No recent signals for your favorite pairs yet.', icon: Icons.insights_rounded)
                        : RefreshIndicator(
                            onRefresh: () => context.read<SignalProvider>().loadFavorites(),
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                              itemCount: signalProvider.favoriteSignals.length,
                              itemBuilder: (_, i) {
                                final signal = signalProvider.favoriteSignals[i];
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
                          ),
                  ),
                ],
              );
            }),
    );
  }
}
