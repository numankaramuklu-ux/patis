import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_notification.dart';
import '../models/dog_walk.dart';
import '../models/pet_walker.dart';
import '../state/auth_store.dart';
import '../state/message_store.dart';
import '../state/notification_store.dart';
import '../state/passport_store.dart';
import '../state/pet_walker_store.dart';
import '../state/review_store.dart';
import '../state/walk_store.dart';
import '../theme/app_colors.dart';
import '../utils/tr_date.dart';
import '../widgets/review_section.dart';
import 'chat_screen.dart';

/// Tek bir köpek gezdiricisinin detay ekranı.
///
/// Profil başlığı, bilgi kutuları, tanıtım ve aksiyonlar. Altta "Yürüyüş iste"
/// (gün + saat + süre seçtirir) ve "İletişim" (telefon varsa) aksiyonları.
/// Talep, gezdiricinin [WalkStore]'una "bekliyor" olarak düşer ve bir bildirim
/// oluşturur — böylece walker panelinde otomatik "Onay bekleyenler"e gelir.
class WalkerDetailScreen extends StatelessWidget {
  const WalkerDetailScreen({super.key, required this.walker});

  final PetWalker walker;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openContact(BuildContext context) {
    final phone = walker.phone;
    if (phone == null || phone.isEmpty) {
      _snack(context, 'Bu gezdirici için iletişim bilgisi yok');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ContactSheet(walker: walker),
    );
  }

  /// Gün + saat + süre seçtirir; seçilince talebi gezdiricinin yürüyüş
  /// listesine "bekliyor" olarak ekler ve bir bildirim oluşturur.
  Future<void> _requestWalk(BuildContext context) async {
    final walkStore = context.read<WalkStore>();
    final notificationStore = context.read<NotificationStore>();
    final pet = context.read<PassportStore>().pet;
    final ownerName = context.read<AuthStore>().name ?? 'Bir müşteri';

    final result = await _WalkRequestSheet.show(context, walker);
    if (result == null || !context.mounted) return;

    final walk = DogWalk(
      id: 'req${DateTime.now().millisecondsSinceEpoch}',
      ownerName: ownerName,
      petName: pet.name,
      breed: pet.breed,
      date: result.date,
      time: result.time,
      durationMin: result.durationMin,
      price: walker.pricePerWalk,
      note: result.note,
      status: WalkStatus.bekliyor,
    );
    walkStore.add(walk);
    notificationStore.add(
      AppNotification(
        kind: NotificationKind.booking,
        title: 'Yeni yürüyüş talebi',
        body: '$ownerName, ${pet.name} için ${walk.dayLabel} ${result.time} '
            'yürüyüş talebinde bulundu.',
        timeAgo: 'Az önce',
      ),
    );

    _snack(
      context,
      '${formatTrDayMonth(result.date)}, ${result.time} '
      '(${result.durationMin} dk • ₺${walker.pricePerWalk}) yürüyüş talebin '
      'gönderildi 🐾',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<PetWalkerStore>();
    final isFav = store.isFavorite(walker.id);
    final reviewStore = context.watch<ReviewStore>();
    final reviewCount = reviewStore.countFor(walker.id);
    // Yorum varsa canlı ortalamayı, yoksa ilandaki başlangıç puanını göster.
    final avgRating = reviewCount > 0
        ? reviewStore.averageFor(walker.id).toStringAsFixed(1)
        : '${walker.rating}';
    const accent = AppColors.forest;

    return Scaffold(
      appBar: AppBar(
        title: Text(walker.name),
        actions: [
          IconButton(
            onPressed: () => store.toggleFavorite(walker.id),
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            color: isFav ? AppColors.terracotta : null,
            tooltip: isFav ? 'Favorilerden çıkar' : 'Favorilere ekle',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // ---- Başlık ----
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      image: walker.photoPath != null
                          ? DecorationImage(
                              image: FileImage(File(walker.photoPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: walker.photoPath != null
                        ? null
                        : Text(
                            walker.name.characters.first,
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: accent,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(walker.name, style: theme.textTheme.headlineSmall),
                      if (walker.verified) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: accent, size: 22),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.text.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        walker.district,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- Bilgi kutuları ----
            Row(
              children: [
                _InfoBox(
                  icon: Icons.star_rounded,
                  value: avgRating,
                  label: 'puan',
                ),
                const SizedBox(width: 12),
                _InfoBox(
                  icon: Icons.directions_walk,
                  value: '₺${walker.pricePerWalk}',
                  label: 'yürüyüş',
                ),
                const SizedBox(width: 12),
                _InfoBox(
                  icon: Icons.reviews_outlined,
                  value: '$reviewCount',
                  label: 'yorum',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---- Tanıtım ----
            Text('Hakkında', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.text.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                walker.summary,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
              ),
            ),
            const SizedBox(height: 24),

            // ---- Yorumlar ----
            ReviewSection(targetId: walker.id, targetName: walker.name),
            const SizedBox(height: 24),

            // ---- Aksiyonlar ----
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openContact(context),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('İletişim'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: const BorderSide(color: accent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _requestWalk(context),
                    icon: const Icon(Icons.directions_walk),
                    label: const Text('Yürüyüş iste'),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: AppColors.cream,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Yürüyüş talebi sonucu: seçilen gün, saat, süre ve isteğe bağlı not.
class _WalkRequest {
  const _WalkRequest({
    required this.date,
    required this.time,
    required this.durationMin,
    this.note,
  });

  final DateTime date;
  final String time;
  final int durationMin;
  final String? note;
}

/// Gün + saat + süre seçtiren ve isteğe bağlı not alan alt panel.
class _WalkRequestSheet extends StatefulWidget {
  const _WalkRequestSheet({required this.walker});

  final PetWalker walker;

  static Future<_WalkRequest?> show(BuildContext context, PetWalker walker) {
    return showModalBottomSheet<_WalkRequest>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _WalkRequestSheet(walker: walker),
    );
  }

  @override
  State<_WalkRequestSheet> createState() => _WalkRequestSheetState();
}

class _WalkRequestSheetState extends State<_WalkRequestSheet> {
  DateTime? _date;
  TimeOfDay? _time;
  int _durationMin = 30;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String get _timeLabel {
    final t = _time;
    if (t == null) return 'Saat seç';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      helpText: '${widget.walker.name} için gün seç',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Yürüyüş saati',
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return;
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      _WalkRequest(
        date: date,
        time: '$h:$m',
        durationMin: _durationMin,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = AppColors.forest;
    final ready = _date != null && _time != null;
    final dateLabel = _date == null ? 'Gün seç' : formatTrDayMonth(_date!);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.text.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Yürüyüş talebi', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${widget.walker.name} • ₺${widget.walker.pricePerWalk}/yürüyüş',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),

            // Gün + saat seçiciler.
            Row(
              children: [
                Expanded(
                  child: _PickerButton(
                    icon: Icons.calendar_today_outlined,
                    label: dateLabel,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerButton(
                    icon: Icons.schedule,
                    label: _timeLabel,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Süre seçimi.
            Text('Süre', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 30, label: Text('30 dk')),
                ButtonSegment(value: 45, label: Text('45 dk')),
                ButtonSegment(value: 60, label: Text('60 dk')),
              ],
              selected: {_durationMin},
              showSelectedIcon: false,
              onSelectionChanged: (s) =>
                  setState(() => _durationMin = s.first),
            ),
            const SizedBox(height: 20),

            // İsteğe bağlı not.
            TextField(
              controller: _noteController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Not (isteğe bağlı)',
                hintText: 'Örn. Diğer köpeklerden çekiniyor',
                prefixIcon: Icon(Icons.sticky_note_2_outlined),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: ready ? _submit : null,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Talep gönder'),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
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

/// Gün/saat seçimi için dışı çizili buton.
class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.forest,
        side: BorderSide(color: AppColors.forest.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: theme.textTheme.bodyMedium,
      ),
    );
  }
}

/// Detaydaki tek bir bilgi kutusu (ikon + değer + etiket).
class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
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

/// İletişim alt paneli: gezdirici adı/telefonu + Ara ve Mesaj butonları.
class _ContactSheet extends StatelessWidget {
  const _ContactSheet({required this.walker});

  final PetWalker walker;

  Future<void> _launch(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await launchUrl(uri);
    if (ok) {
      navigator.pop();
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('İşlem başlatılamadı')),
      );
    }
  }

  /// Uygulama içi sohbeti açar (gerekirse oluşturur).
  void _openChat(BuildContext context) {
    final store = context.read<MessageStore>();
    final id = store.openThread(
      peerName: walker.name,
      peerRole: 'Pet walker',
    );
    final thread =
        store.threads.firstWhere((t) => t.id == id);
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(thread: thread)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = AppColors.forest;
    final phone = walker.phone ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('İletişim', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 20, color: accent),
              const SizedBox(width: 10),
              Text(walker.name, style: theme.textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 20, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  phone,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: phone));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Numara kopyalandı')),
                  );
                },
                icon: const Icon(Icons.copy_outlined, size: 20),
                color: accent,
                tooltip: 'Numarayı kopyala',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      _launch(context, Uri(scheme: 'tel', path: phone)),
                  icon: const Icon(Icons.call),
                  label: const Text('Ara'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: AppColors.cream,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openChat(context),
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Mesaj'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent,
                    side: BorderSide(color: accent.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
