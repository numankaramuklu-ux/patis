import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/salon_client.dart';
import '../state/salon_store.dart';
import '../theme/app_colors.dart';
import 'salon_client_detail_screen.dart';

/// Pet salonunun Müşteriler ekranı (kuaför rolünün 1. sekmesi).
///
/// Üstte özet istatistikler ve arama kutusu; altında müşteri kartları. Karta
/// dokununca müşterinin detay ekranı açılır. Veriler [SalonStore]'dan gelir.
class SalonClientsScreen extends StatefulWidget {
  const SalonClientsScreen({super.key});

  @override
  State<SalonClientsScreen> createState() => _SalonClientsScreenState();
}

class _SalonClientsScreenState extends State<SalonClientsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clients = context.watch<SalonStore>().clients;

    // Hayvan veya sahip adına göre filtrele (küçük/büyük harf duyarsız).
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? clients
        : clients
            .where((c) =>
                c.petName.toLowerCase().contains(q) ||
                c.ownerName.toLowerCase().contains(q))
            .toList();

    // Özet istatistikler (tüm müşteriler üzerinden).
    final total = clients.length;
    final regulars = clients.where((c) => c.tag != null).length;
    final totalRevenue =
        clients.fold<int>(0, (sum, c) => sum + c.totalSpent);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Müşteriler', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            // Özet istatistik kartı.
            _StatsCard(
              total: total,
              regulars: regulars,
              revenue: totalRevenue,
            ),
            const SizedBox(height: 16),
            // Arama kutusu.
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Müşteri veya hayvan ara',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    '"$_query" için müşteri bulunamadı',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              for (final client in filtered) ...[
                _SalonClientCard(
                  client: client,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SalonClientDetailScreen(client: client),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

/// Üstteki özet istatistik kartı (forest zeminli): toplam müşteri, düzenli,
/// toplam ciro.
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.total,
    required this.regulars,
    required this.revenue,
  });

  final int total;
  final int regulars;
  final int revenue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _Stat(value: '$total', label: 'müşteri'),
          _divider(),
          _Stat(value: '$regulars', label: 'düzenli'),
          _divider(),
          _Stat(value: '${(revenue / 1000).toStringAsFixed(1)}k₺', label: 'toplam ciro'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 34,
        color: AppColors.cream.withValues(alpha: 0.2),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.cream.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Müşteri listesindeki tek bir kart (detay ekranına götürür).
class _SalonClientCard extends StatelessWidget {
  const _SalonClientCard({required this.client, required this.onTap});

  final SalonClient client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pets,
                    color: AppColors.terracotta, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            client.petName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (client.tag != null) ...[
                          const SizedBox(width: 8),
                          _Tag(label: client.tag!),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sahibi: ${client.ownerName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${client.totalVisits} ziyaret • Son: ${client.lastVisitLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.text),
            ],
          ),
        ),
      ),
    );
  }
}

/// Müşteri durum etiketi (örn. "VIP").
class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
