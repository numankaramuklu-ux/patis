import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';

/// Uygulama içi mesajlaşmanın deposu.
///
/// Sohbetleri ([ChatThread]) ve tüm mesajları ([ChatMessage]) tutar; her ikisi
/// de `shared_preferences` ile kalıcıdır. Karşı taraf gerçek bir kullanıcı
/// olmadığından (backend yok) gelen mesajlar mock seed'le simüle edilir;
/// ileride Firebase'e taşınabilir.
class MessageStore extends ChangeNotifier {
  MessageStore() {
    _load();
  }

  static const _kThreads = 'chat_threads';
  static const _kMessages = 'chat_messages';

  final List<ChatThread> _threads = List.of(_seedThreads());
  final List<ChatMessage> _messages = List.of(_seedMessages());

  static List<ChatThread> _seedThreads() => const [
        ChatThread(id: 't_elifk', peerName: 'Elif K.', peerRole: 'Pet walker'),
      ];

  static List<ChatMessage> _seedMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'm1',
        threadId: 't_elifk',
        body: 'Merhaba! Pamuk için yürüyüş talebinizi aldım 🐾',
        fromMe: false,
        sentAt: now.subtract(const Duration(minutes: 40)),
      ),
      ChatMessage(
        id: 'm2',
        threadId: 't_elifk',
        body: 'Saat 09:00 sizin için uygun mu?',
        fromMe: false,
        sentAt: now.subtract(const Duration(minutes: 39)),
      ),
    ];
  }

  /// Son mesaja göre sıralı sohbetler (en yeni en üstte).
  List<ChatThread> get threads {
    final list = List<ChatThread>.from(_threads)
      ..sort((a, b) {
        final ta = _lastAt(a.id);
        final tb = _lastAt(b.id);
        return tb.compareTo(ta);
      });
    return List.unmodifiable(list);
  }

  /// Bir sohbetin mesajları (eskiden yeniye sıralı).
  List<ChatMessage> messagesOf(String threadId) {
    final list = _messages.where((m) => m.threadId == threadId).toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return List.unmodifiable(list);
  }

  /// Bir sohbetteki son mesaj metni (liste önizlemesi için).
  String lastBody(String threadId) {
    final msgs = messagesOf(threadId);
    return msgs.isEmpty ? '' : msgs.last.body;
  }

  /// Bir sohbetin son mesaj zamanı (sıralama için; mesaj yoksa epoch).
  DateTime _lastAt(String threadId) {
    final msgs = messagesOf(threadId);
    return msgs.isEmpty
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : msgs.last.sentAt;
  }

  /// Bir sohbetteki okunmamış (karşıdan gelen) mesaj sayısı.
  int unreadOf(String threadId) => _messages
      .where((m) => m.threadId == threadId && !m.fromMe && !m.read)
      .length;

  /// Tüm sohbetlerdeki toplam okunmamış mesaj sayısı (rozet için).
  int get totalUnread =>
      _messages.where((m) => !m.fromMe && !m.read).length;

  /// Karşı tarafa göre var olan sohbeti döndürür; yoksa oluşturur. Sohbet
  /// kimliğini verir, böylece çağıran [ChatScreen]'i açabilir.
  String openThread({required String peerName, required String peerRole}) {
    final id = 't_${peerName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}';
    final exists = _threads.any((t) => t.id == id);
    if (!exists) {
      _threads.add(
        ChatThread(id: id, peerName: peerName, peerRole: peerRole),
      );
      notifyListeners();
      _persistThreads();
    }
    return id;
  }

  /// Bu kullanıcı adına bir mesaj gönderir.
  void send(String threadId, String body) {
    final text = body.trim();
    if (text.isEmpty) return;
    _messages.add(
      ChatMessage(
        id: 'm${DateTime.now().millisecondsSinceEpoch}',
        threadId: threadId,
        body: text,
        fromMe: true,
        sentAt: DateTime.now(),
        read: true,
      ),
    );
    notifyListeners();
    _persistMessages();
  }

  /// Bir sohbetteki karşıdan gelen tüm mesajları okundu işaretler.
  void markThreadRead(String threadId) {
    var changed = false;
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m.threadId == threadId && !m.fromMe && !m.read) {
        _messages[i] = m.copyWith(read: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      _persistMessages();
    }
  }

  // ---- Kalıcılık ----

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final threadsRaw = prefs.getString(_kThreads);
    if (threadsRaw != null) {
      final decoded = (jsonDecode(threadsRaw) as List)
          .map((e) => ChatThread.fromJson(e as Map<String, dynamic>))
          .toList();
      _threads
        ..clear()
        ..addAll(decoded);
    }

    final messagesRaw = prefs.getString(_kMessages);
    if (messagesRaw != null) {
      final decoded = (jsonDecode(messagesRaw) as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      _messages
        ..clear()
        ..addAll(decoded);
    }

    if (threadsRaw != null || messagesRaw != null) notifyListeners();
  }

  Future<void> _persistThreads() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kThreads,
      jsonEncode(_threads.map((t) => t.toJson()).toList()),
    );
  }

  Future<void> _persistMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kMessages,
      jsonEncode(_messages.map((m) => m.toJson()).toList()),
    );
  }
}
