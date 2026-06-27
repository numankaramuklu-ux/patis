import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../state/message_store.dart';
import '../theme/app_colors.dart';
import 'chat_screen.dart';

/// Sohbet listesi ekranı (Mesajlar).
///
/// Ana Sayfa'daki "Mesajlar" kutusundan açılır. Her satır bir sohbeti; karşı
/// tarafın adını, rolünü, son mesajı ve okunmamış rozetini gösterir. Satıra
/// dokununca [ChatScreen] açılır. Veriler [MessageStore]'dan canlı gelir.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  /// Sıfırdan sohbet başlatır: bir ad sorar, [MessageStore]'da sohbeti açar
  /// (gerekirse oluşturur) ve [ChatScreen]'e yönlendirir.
  Future<void> _startNewChat(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni sohbet'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Kişi veya işletme adı'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Başlat'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    final store = context.read<MessageStore>();
    final id = store.openThread(peerName: name.trim(), peerRole: 'Kişi');
    final thread = store.threads.firstWhere((t) => t.id == id);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(thread: thread)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<MessageStore>();
    final threads = store.threads;

    return Scaffold(
      appBar: AppBar(title: const Text('Mesajlar')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewChat(context),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Yeni sohbet'),
      ),
      body: SafeArea(
        top: false,
        child: threads.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 56,
                      color: AppColors.forest.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz mesajın yok.\nBir gezdirici veya bakıcıyla iletişime geç 🐾',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.text.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: threads.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 84,
                  color: AppColors.text.withValues(alpha: 0.08),
                ),
                itemBuilder: (_, i) {
                  final thread = threads[i];
                  return _ThreadTile(
                    thread: thread,
                    lastBody: store.lastBody(thread.id),
                    unread: store.unreadOf(thread.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(thread: thread),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Sohbet listesindeki tek bir satır.
class _ThreadTile extends StatelessWidget {
  const _ThreadTile({
    required this.thread,
    required this.lastBody,
    required this.unread,
    required this.onTap,
  });

  final ChatThread thread;
  final String lastBody;
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = AppColors.forest;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Text(
          thread.peerName.characters.first,
          style: theme.textTheme.titleLarge?.copyWith(color: accent),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              thread.peerName,
              style: theme.textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            thread.peerRole,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.text.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          lastBody.isEmpty ? 'Sohbeti başlat' : lastBody,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.text.withValues(alpha: 0.6),
            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
      trailing: unread > 0
          ? Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: AppColors.terracotta,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unread',
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            )
          : null,
    );
  }
}
