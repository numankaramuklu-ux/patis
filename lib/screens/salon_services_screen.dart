import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/salon_service.dart';
import '../state/salon_store.dart';
import '../theme/app_colors.dart';
import '../widgets/new_salon_service_sheet.dart';

/// Pet salonunun "Hizmetlerim / Fiyat listesi" ekranı.
///
/// Salonun sunduğu hizmetleri (ad, süre, ücret) listeler. Kuaför yeni hizmet
/// ekleyebilir (FAB), bir karta dokununca düzenleyebilir, sola kaydırınca
/// silebilir. Veriler [SalonStore]'dan canlı gelir ve diske yazılır.
class SalonServicesScreen extends StatelessWidget {
  const SalonServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<SalonStore>();
    final services = store.services;

    return Scaffold(
      appBar: AppBar(title: const Text('Hizmetler & Fiyat listesi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NewSalonServiceSheet.show(context),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.add),
        label: const Text('Hizmet ekle'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            // Özet: hizmet sayısı + ortalama ücret.
            _StatsCard(
              count: services.length,
              averagePrice: store.averageServicePrice,
            ),
            const SizedBox(height: 20),
            if (services.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.content_cut,
                          size: 56,
                          color: AppColors.forest.withValues(alpha: 0.35)),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz hizmet eklemedin.\nSağ alttan ilk hizmetini ekle 🐾',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final service in services) ...[
                _ServiceCard(
                  service: service,
                  onTap: () =>
                      NewSalonServiceSheet.show(context, existing: service),
                  onDelete: () => store.deleteService(service.id),
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

/// Üstteki özet kart (forest zeminli): hizmet sayısı ve ortalama ücret.
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.count, required this.averagePrice});

  final int count;
  final int averagePrice;

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
          _Stat(value: '$count', label: 'hizmet'),
          Container(
            width: 1,
            height: 34,
            color: AppColors.cream.withValues(alpha: 0.2),
          ),
          _Stat(value: '$averagePrice₺', label: 'ortalama ücret'),
        ],
      ),
    );
  }
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

/// Tek bir hizmet kartı. Dokununca düzenler; sola kaydırınca (onay sonrası)
/// siler.
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.onTap,
    required this.onDelete,
  });

  final SalonService service;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(service.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.terracotta,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.cream),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        onDelete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${service.name} silindi')),
        );
      },
      child: Material(
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.content_cut, color: AppColors.gold),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 14,
                              color: AppColors.text.withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            '${service.durationMin} dk',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.text.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      if (service.note != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.text.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${service.price}₺',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Silmeden önce onay sorar (kaza ile kaydırmayı önler).
  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hizmeti sil'),
        content: Text('"${service.name}" silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
