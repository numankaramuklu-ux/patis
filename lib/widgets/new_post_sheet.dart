import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/community_post.dart';
import '../state/community_store.dart';
import '../state/passport_store.dart';
import '../theme/app_colors.dart';

/// "Yeni gönderi" oluşturma formu (alttan açılan panel).
///
/// Kaydedilince gönderiyi [CommunityStore]'a ekler ve paneli kapatır.
/// Diğer formlarla aynı deseni izler.
class NewPostSheet extends StatefulWidget {
  const NewPostSheet({super.key});

  /// Paneli açan kısa yardımcı. Topluluk ekranı bunu çağırır.
  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NewPostSheet(),
    );
  }

  @override
  State<NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<NewPostSheet> {
  final _contentController = TextEditingController();

  // Etiketlenecek dost (kendi hayvanlarından). null = etiketsiz.
  String? _petTag;

  // Seçilen fotoğrafın cihazdaki yolu. null = fotoğrafsız gönderi.
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    // Varsayılan olarak aktif hayvanı etiketle.
    _petTag = context.read<PassportStore>().pet.name;
  }

  /// Galeriden bir fotoğraf seçtirir ve önizleme için saklar.
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// Formu doğrular ve geçerliyse gönderiyi depoya ekler.
  void _save() {
    final content = _contentController.text.trim();

    // Fotoğraf varsa metin zorunlu değil; ikisi de boşsa uyar.
    if (content.isEmpty && _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir şeyler yaz ya da fotoğraf ekle')),
      );
      return;
    }

    final store = context.read<CommunityStore>();
    // Avatar rengini paletten sırayla seç (mevcut gönderi sayısına göre).
    final color =
        communityAvatarColors[store.posts.length % communityAvatarColors.length];

    store.add(
      CommunityPost(
        author: 'Sen',
        timeAgo: 'Az önce',
        content: content,
        avatarColor: color,
        petTag: _petTag,
        imagePath: _imagePath,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
          Text('Yeni gönderi', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _contentController,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Ne paylaşmak istersin?',
              hintText: 'Dostunla ilgili bir an, soru ya da tavsiye...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          // Fotoğraf seçici (isteğe bağlı). Seçilince önizleme gösterilir.
          if (_imagePath == null)
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Fotoğraf ekle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forest,
                side: const BorderSide(color: AppColors.forest),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.file(
                      File(_imagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(() => _imagePath = null),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Hangi dostu etiketleyelim? (kendi hayvanlarından)
          DropdownButtonFormField<String?>(
            initialValue: _petTag,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Dostu etiketle (isteğe bağlı)',
              prefixIcon: Icon(Icons.pets),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Etiketsiz'),
              ),
              for (final p in context.read<PassportStore>().pets)
                DropdownMenuItem<String?>(
                  value: p.pet.name,
                  child: Text(p.pet.name),
                ),
            ],
            onChanged: (value) => setState(() => _petTag = value),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: AppColors.cream,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Paylaş'),
            ),
          ),
        ],
      ),
    );
  }
}
