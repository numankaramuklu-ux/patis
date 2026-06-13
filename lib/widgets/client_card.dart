import 'package:flutter/material.dart';

import '../models/client_record.dart';
import '../theme/app_colors.dart';

/// Müşteri/hasta listesinde tek bir kaydı gösteren kart.
///
/// Soldaki yuvarlak avatar (hayvan ikonu), ortada hayvan adı + sahip/cins ve
/// son ziyaret bilgisi, sağda (varsa) durum etiketi ve telefon butonu. Veriyi
/// dışarıdan [ClientRecord] olarak alır; "son ziyaret" önekini ekran verir
/// (kuaförde "Son bakım", veterinerde "Son ziyaret").
class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
    required this.client,
    required this.lastVisitPrefix,
    required this.accent,
    this.onCall,
  });

  final ClientRecord client;

  /// Son ziyaret satırının başına eklenen metin (örn. "Son bakım").
  final String lastVisitPrefix;

  /// Avatar ve etiketin vurgu rengi (role göre değişir).
  final Color accent;

  /// Telefon butonuna basılınca çalışır (isteğe bağlı).
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.pets, color: accent, size: 26),
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
                      _Tag(label: client.tag!, color: accent),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Sahibi: ${client.ownerName} • ${client.petBreed}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$lastVisitPrefix: ${client.lastVisitLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          // Telefon kısayolu.
          IconButton(
            onPressed: onCall,
            icon: Icon(Icons.phone_outlined, color: accent),
            tooltip: 'Ara',
          ),
        ],
      ),
    );
  }
}

/// Kayıt durumunu gösteren küçük renkli etiket (örn. "Aşı zamanı").
class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
