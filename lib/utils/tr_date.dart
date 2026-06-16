// Türkçe tarih biçimlendirme yardımcıları.
//
// Birden çok formda aynı ay isimlerini tekrar yazmamak için tek yerde
// topladık. İleride `intl` paketine geçince bu dosyayı değiştirmek yeterli olur.

const _months = <String>[
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

const _monthsShort = <String>[
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
  'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

/// "10 Mart 2026" biçiminde tam tarih (yıllı).
String formatTrDate(DateTime dt) => '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

/// "10 Mart" biçiminde gün + ay (yılsız) — takvim ve gün başlıkları için.
String formatTrDayMonth(DateTime dt) => '${dt.day} ${_months[dt.month - 1]}';

/// "Haziran 2026" biçiminde ay + yıl — takvim başlığı için.
String formatTrMonthYear(DateTime dt) => '${_months[dt.month - 1]} ${dt.year}';

/// "Mar" gibi kısa ay adı — kilo grafiğinin altındaki etiketler için.
String trMonthShort(DateTime dt) => _monthsShort[dt.month - 1];

/// "10 Ağustos", "2 Haz 2027" gibi Türkçe tarih etiketlerini [DateTime]'a
/// çevirir. Tam ("Ağustos") ve kısa ("Ağu") ay adlarını anlar. Yıl
/// belirtilmemişse bugünden itibaren ilk geçiş yılını seçer (gün/ay geçmişte
/// kalmışsa gelecek yıl) — böylece "yaklaşan" sıralaması doğru çıkar.
/// Ayrıştırılamazsa null döner. [now] testler için dışarıdan verilebilir.
DateTime? parseTrDate(String label, {DateTime? now}) {
  final parts = label.trim().split(RegExp(r'\s+'));
  if (parts.length < 2) return null;

  final day = int.tryParse(parts[0]);
  if (day == null) return null;

  final monthName = parts[1].toLowerCase();
  var month = _months.indexWhere((m) => m.toLowerCase() == monthName);
  if (month == -1) {
    month = _monthsShort.indexWhere((m) => m.toLowerCase() == monthName);
  }
  if (month == -1) return null;
  month += 1; // indeks 0 tabanlı → ay 1 tabanlı

  // Yıl açıkça verilmişse onu kullan.
  if (parts.length >= 3) {
    final year = int.tryParse(parts[2]);
    if (year != null) return DateTime(year, month, day);
  }

  // Yıl yoksa: bu yıl geçmediyse bu yıl, geçtiyse gelecek yıl.
  final today = now ?? DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  var candidate = DateTime(today.year, month, day);
  if (candidate.isBefore(todayDate)) {
    candidate = DateTime(today.year + 1, month, day);
  }
  return candidate;
}
