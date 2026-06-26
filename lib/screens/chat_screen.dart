import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../state/message_store.dart';
import '../theme/app_colors.dart';

/// İki kişi arasındaki sohbet ekranı.
///
/// Mesajlar [MessageStore]'dan canlı gelir; alttaki kutudan gönderilen mesaj
/// hemen listeye eklenir ve kalıcılaşır. Ekran açılınca karşıdan gelen mesajlar
/// okundu işaretlenir.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.thread});

  final ChatThread thread;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Sohbet açılınca okunmamışları okundu yap (rozet sıfırlanır).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageStore>().markThreadRead(widget.thread.id);
      _jumpToBottom();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<MessageStore>().send(widget.thread.id, text);
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = context.watch<MessageStore>();
    final messages = store.messagesOf(widget.thread.id);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.thread.peerName, style: theme.textTheme.titleMedium),
            Text(
              widget.thread.peerRole,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'Henüz mesaj yok.\nİlk mesajı sen gönder 🐾',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => _Bubble(message: messages[i]),
                    ),
            ),
            _Composer(controller: _controller, onSend: _send),
          ],
        ),
      ),
    );
  }
}

/// Tek bir mesaj balonu. Benden gidenler sağda (forest), gelenler solda (card).
class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mine = message.fromMe;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.74,
        ),
        decoration: BoxDecoration(
          color: mine ? AppColors.forest : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
          border: mine
              ? null
              : Border.all(color: AppColors.text.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.body,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: mine ? AppColors.cream : AppColors.text,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message.timeLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: (mine ? AppColors.cream : AppColors.text)
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alttaki mesaj yazma kutusu + gönder düğmesi.
class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border(
          top: BorderSide(color: AppColors.text.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Mesaj yaz…',
                filled: true,
                fillColor: AppColors.card,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.forest,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSend,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.send, color: AppColors.cream, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
