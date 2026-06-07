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

/// "Mar" gibi kısa ay adı — kilo grafiğinin altındaki etiketler için.
String trMonthShort(DateTime dt) => _monthsShort[dt.month - 1];
