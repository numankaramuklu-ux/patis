/// Reçetedeki tek bir ilaç satırı (ad + doz/kullanım).
class VetPrescriptionMedicine {
  const VetPrescriptionMedicine({required this.name, required this.dosage});

  final String name;

  /// Doz / kullanım talimatı (örn. "2x1, 5 gün").
  final String dosage;
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
}
