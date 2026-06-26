/// Uygulama içi mesajlaşmadaki tek bir mesaj.
///
/// [fromMe] true ise mesajı bu cihazdaki kullanıcı gönderdi (sağda, dolu balon);
/// false ise karşı taraftan geldi (solda, açık balon). Mesajlar [MessageStore]'da
/// thread (sohbet) kimliğine göre gruplanır ve `shared_preferences` ile kalıcıdır.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.body,
    required this.fromMe,
    required this.sentAt,
    this.read = false,
  });

  /// Benzersiz mesaj kimliği.
  final String id;

  /// Ait olduğu sohbetin kimliği.
  final String threadId;

  /// Mesaj metni.
  final String body;

  /// Bu kullanıcı mı gönderdi? (true = sağ/dolu balon)
  final bool fromMe;

  /// Gönderim zamanı.
  final DateTime sentAt;

  /// Karşıdan gelen mesaj okundu mu? (okunmamış rozeti için).
  final bool read;

  ChatMessage copyWith({bool? read}) => ChatMessage(
        id: id,
        threadId: threadId,
        body: body,
        fromMe: fromMe,
        sentAt: sentAt,
        read: read ?? this.read,
      );

  /// "14:30" biçiminde saat etiketi.
  String get timeLabel {
    final h = sentAt.hour.toString().padLeft(2, '0');
    final m = sentAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'threadId': threadId,
        'body': body,
        'fromMe': fromMe,
        'sentAt': sentAt.toIso8601String(),
        'read': read,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String? ?? '',
        threadId: json['threadId'] as String? ?? '',
        body: json['body'] as String? ?? '',
        fromMe: json['fromMe'] as bool? ?? false,
        sentAt: DateTime.tryParse(json['sentAt'] as String? ?? '') ??
            DateTime.now(),
        read: json['read'] as bool? ?? false,
      );
}

/// Bir sohbet başlığı (karşı taraf bilgisi). Mesajlar ayrı tutulur.
class ChatThread {
  const ChatThread({
    required this.id,
    required this.peerName,
    required this.peerRole,
  });

  /// Benzersiz sohbet kimliği (genelde karşı tarafın kimliği/adı türevi).
  final String id;

  /// Karşı tarafın adı (örn. "Elif K.").
  final String peerName;

  /// Karşı tarafın rolü etiketi (örn. "Pet walker", "Pet sitter").
  final String peerRole;

  Map<String, dynamic> toJson() => {
        'id': id,
        'peerName': peerName,
        'peerRole': peerRole,
      };

  factory ChatThread.fromJson(Map<String, dynamic> json) => ChatThread(
        id: json['id'] as String? ?? '',
        peerName: json['peerName'] as String? ?? '',
        peerRole: json['peerRole'] as String? ?? '',
      );
}
