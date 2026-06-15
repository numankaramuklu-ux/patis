import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Randevunun türü. Her tür kendi ikonunu, etiketini ve rengini taşır.
///
/// Bu "gelişmiş enum" (enhanced enum) yapısıdır: normal enum gibi sınırlı bir
/// seçenek listesidir ama her seçeneğe ekstra veri (ikon/etiket/renk)
/// bağlayabiliyoruz. Böylece kartta tür başına ayrı `if` yazmak yerine
/// doğrudan `appointment.type.icon` diyebiliyoruz.
enum AppointmentType {
  veteriner(
    label: 'Veteriner',
    icon: Icons.medical_services_outlined,
    color: AppColors.forest,
  ),
  kuafor(
    label: 'Kuaför',
    icon: Icons.content_cut,
    color: AppColors.terracotta,
  );

  const AppointmentType({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Bir randevuyu (veteriner, kuaför vb.) temsil eden veri sınıfı.
class Appointment {
  const Appointment({
    required this.title,
    required this.place,
    required this.dateLabel,
    this.type = AppointmentType.veteriner,
    this.petId,
  });

  /// Randevunun konusu (örn. "Aşı kontrolü").
  final String title;

  /// Yer / klinik adı (örn. "Patiş Veteriner Kliniği").
  final String place;

  /// Tarih etiketi (örn. "12 Haziran, 14:30").
  final String dateLabel;

  /// Randevu türü — kartın ikon ve rengini belirler.
  ///
  /// Vermezsen varsayılan olarak [AppointmentType.veteriner] kabul edilir;
  /// böylece eski kullanım yerleri (Ana Sayfa) bozulmadan çalışmaya devam eder.
  final AppointmentType type;

  /// Bu randevunun hangi evcil hayvana ait olduğu ([PetProfile.id]). Çoklu
  /// hayvan desteğiyle eklendi; eski/sahipsiz kayıtlarda null olabilir.
  final String? petId;

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir.
  /// Tür, enum adı (örn. "kuafor") olarak yazılır.
  Map<String, dynamic> toJson() => {
        'title': title,
        'place': place,
        'dateLabel': dateLabel,
        'type': type.name,
        'petId': petId,
      };

  /// Saklanan Map'ten [Appointment] üretir. Bilinmeyen/eksik tür varsayılana
  /// (veteriner) düşer.
  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        title: json['title'] as String? ?? '',
        place: json['place'] as String? ?? '',
        dateLabel: json['dateLabel'] as String? ?? '',
        type: AppointmentType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => AppointmentType.veteriner,
        ),
        petId: json['petId'] as String?,
      );
}
