import 'package:flutter/material.dart';

import '../models/client_record.dart';
import '../models/user_role.dart';
import '../theme/app_colors.dart';
import '../widgets/client_card.dart';

/// İşletme rollerinin 1. sekmesi: kuaför için "Müşteriler", veteriner için
/// "Hastalar" listesi.
///
/// Tek ekranı role göre uyarlıyoruz; başlık, "son ziyaret" öneki ve mock liste
/// role göre değişir. Veriler şimdilik sahte; ileride Firebase'den gelecek.
class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key, required this.role});

  final UserRole role;

  bool get _isVet => role == UserRole.veteriner;

  /// Veterinerde yeşil, kuaförde terracotta vurgu.
  Color get _accent => _isVet ? AppColors.forest : AppColors.terracotta;

  String get _title => _isVet ? 'Hastalar' : 'Müşteriler';

  String get _subtitle => _isVet
      ? 'Kliniğine kayıtlı hastalar'
      : 'Salonuna kayıtlı müşteriler';

  String get _lastVisitPrefix => _isVet ? 'Son ziyaret' : 'Son bakım';

  /// Role göre mock kayıt listesi.
  List<ClientRecord> get _clients => _isVet ? _vetPatients : _groomerClients;

  static const _vetPatients = [
    ClientRecord(
      petName: 'Boncuk',
      petBreed: 'Tekir',
      ownerName: 'Zeynep A.',
      lastVisitLabel: '2 Haziran',
      tag: 'Aşı zamanı',
    ),
    ClientRecord(
      petName: 'Max',
      petBreed: 'Golden Retriever',
      ownerName: 'Can D.',
      lastVisitLabel: '28 Mayıs',
    ),
    ClientRecord(
      petName: 'Limon',
      petBreed: 'Muhabbet kuşu',
      ownerName: 'Elif T.',
      lastVisitLabel: '15 Mayıs',
      tag: 'Kontrol',
    ),
    ClientRecord(
      petName: 'Zeytin',
      petBreed: 'British Shorthair',
      ownerName: 'Burak S.',
      lastVisitLabel: '10 Mayıs',
    ),
    ClientRecord(
      petName: 'Karamel',
      petBreed: 'Pomeranian',
      ownerName: 'Derya K.',
      lastVisitLabel: '1 Mayıs',
      tag: 'Kısırlaştırma',
    ),
  ];

  static const _groomerClients = [
    ClientRecord(
      petName: 'Pamuk',
      petBreed: 'British Shorthair',
      ownerName: 'Ayşe Y.',
      lastVisitLabel: '5 Haziran',
      tag: 'Düzenli',
    ),
    ClientRecord(
      petName: 'Lokum',
      petBreed: 'Maltese',
      ownerName: 'Selin A.',
      lastVisitLabel: '1 Haziran',
      tag: 'VIP',
    ),
    ClientRecord(
      petName: 'Duman',
      petBreed: 'Pomeranian',
      ownerName: 'Onur B.',
      lastVisitLabel: '25 Mayıs',
    ),
    ClientRecord(
      petName: 'Şila',
      petBreed: 'Poodle',
      ownerName: 'Gizem D.',
      lastVisitLabel: '20 Mayıs',
      tag: 'Düzenli',
    ),
    ClientRecord(
      petName: 'Zeytin',
      petBreed: 'Golden Retriever',
      ownerName: 'Kaan M.',
      lastVisitLabel: '12 Mayıs',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clients = _clients;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(_title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              '$_subtitle • ${clients.length} kayıt',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            for (final client in clients) ...[
              ClientCard(
                client: client,
                lastVisitPrefix: _lastVisitPrefix,
                accent: _accent,
                onCall: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${client.ownerName} aranıyor…')),
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
