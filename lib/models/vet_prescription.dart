/// Reçetedeki tek bir ilaç satırı (ad + doz/kullanım).
class VetPrescriptionMedicine {
  const VetPrescriptionMedicine({required this.name, required this.dosage});

  final String name;

  /// Doz / kullanım talimatı (örn. "2x1, 5 gün").
  final String dosage;

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir.
  Map<String, dynamic> toJson() => {'name': name, 'dosage': dosage};

  /// Saklanan Map'ten üretir.
  factory VetPrescriptionMedicine.fromJson(Map<String, dynamic> json) =>
      VetPrescriptionMedicine(
        name: json['name'] as String? ?? '',
        dosage: json['dosage'] as String? ?? '',
      );
}

/// Bir hastaya yazılan reçete: tarih + ilaç listesi + opsiyonel not.
///
/// Veteriner hasta detayında "Reçete yaz" ile oluşturulur ve [VetStore]'da
/// hasta kimliğine göre saklanır. Şimdilik bellekte (mock).
class VetPrescription {
  const VetPrescription({
    required this.dateLabel,
    required this.medicines,
    this.note,
  });

  /// Yazıldığı tarih (örn. "14 Haziran").
  final String dateLabel;

  /// Reçetedeki ilaçlar (en az bir tane).
  final List<VetPrescriptionMedicine> medicines;

  /// Ek açıklama / hekim notu (opsiyonel).
  final String? note;

  /// Cihazda saklamak (shared_preferences) için Map'e çevirir.
  Map<String, dynamic> toJson() => {
        'dateLabel': dateLabel,
        'medicines': medicines.map((m) => m.toJson()).toList(),
        'note': note,
      };

  /// Saklanan Map'ten [VetPrescription] üretir.
  factory VetPrescription.fromJson(Map<String, dynamic> json) => VetPrescription(
        dateLabel: json['dateLabel'] as String? ?? '',
        medicines: (json['medicines'] as List? ?? const [])
            .map((e) =>
                VetPrescriptionMedicine.fromJson(e as Map<String, dynamic>))
            .toList(),
        note: json['note'] as String?,
      );
}
