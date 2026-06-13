import 'package:flutter/material.dart';

import '../models/salon_client.dart';
import '../theme/app_colors.dart';

/// Tek bir salon müşterisinin detay ekranı.
///
/// Müşteri kartına dokununca açılır: hayvan/sahip bilgisi, iletişim, ziyaret
/// istatistikleri, tercih edilen hizmetler, salon notu ve geçmiş ziyaretler.
class SalonClientDetailScreen extends StatelessWidget {
  const SalonClientDetailScreen({super.key, required this.client});

  final SalonClient client;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(client.petName)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // ---- Üst başlık: avatar + ad + tür/cins ----
            Center(
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pets,
                        color: AppColors.terracotta, size: 44),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(client.petName,
                          style: theme.textTheme.headlineSmall),
                      if (client.tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            client.tag!,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${client.species} • ${client.breed}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- İstatistikler ----
            Row(
              children: [
                _StatBox(
                  value: '${client.totalVisits}',
                  label: 'ziyaret',
                  icon: Icons.event_available_outlined,
                ),
                const SizedBox(width: 12),
                _StatBox(
                  value: '${client.totalSpent}₺',
                  label: 'toplam',
                  icon: Icons.payments_outlined,
                ),
                const SizedBox(width: 12),
                _StatBox(
                  value: client.lastVisitLabel,
                  label: 'son ziyaret',
                  icon: Icons.history,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---- İletişim ----
            _SectionTitle('İletişim'),
            const SizedBox(height: 10),
            _ContactCard(
              ownerName: client.ownerName,
              phone: client.phone,
              onCall: () => _snack(context, '${client.ownerName} aranıyor…'),
              onMessage: () => _snack(context, 'Mesaj gönderiliyor…'),
            ),
            const SizedBox(height: 24),

            // ---- Tercih edilen hizmetler ----
            _SectionTitle('Tercih edilen hizmetler'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in client.preferredServices)
                  Chip(
                    label: Text(s),
                    backgroundColor: AppColors.forest.withValues(alpha: 0.08),
                    side: BorderSide(
                        color: AppColors.forest.withValues(alpha: 0.2)),
                    labelStyle: const TextStyle(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),

            // ---- Salon notu ----
            if (client.note != null) ...[
              const SizedBox(height: 24),
              _SectionTitle('Salon notu'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sticky_note_2_outlined,
                        color: AppColors.gold, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(client.note!,
                          style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ],

            // ---- Ziyaret geçmişi ----
            const SizedBox(height: 24),
            _SectionTitle('Ziyaret geçmişi'),
            const SizedBox(height: 10),
            for (final visit in client.history) ...[
              _VisitRow(visit: visit),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),

            // ---- Yeni randevu ----
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    _snack(context, '${client.petName} için randevu oluştur'),
                icon: const Icon(Icons.add),
                label: const Text('Randevu oluştur'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.cream,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bölüm başlığı (detay ekranı içinde).
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}

/// İstatistik kutusu (ziyaret, toplam, son ziyaret).
class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.forest, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.text.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sahibin iletişim kartı (ara / mesaj butonlarıyla).
class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.ownerName,
    required this.phone,
    required this.onCall,
    required this.onMessage,
  });

  final String ownerName;
  final String phone;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ownerName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: onMessage,
            icon: const Icon(Icons.chat_bubble_outline),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.gold.withValues(alpha: 0.18),
              foregroundColor: AppColors.gold,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onCall,
            icon: const Icon(Icons.phone),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.forest,
              foregroundColor: AppColors.cream,
            ),
          ),
        ],
      ),
    );
  }
}

/// Geçmiş ziyaret satırı (tarih + hizmet + ücret).
class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.visit});

  final SalonVisit visit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: Color(0xFF5B8C7B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visit.service,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                Text(
                  visit.dateLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${visit.price}₺',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.forest,
            ),
          ),
        ],
      ),
    );
  }
}
