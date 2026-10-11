import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../utils/preset_images.dart';
import '../l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/top_banner.dart';
import '../repositories/journal_repository.dart';
import '../widgets/mood_selector.dart';
import '../widgets/image_picker_section.dart';
import '../theme/app_colors.dart';

class WriteScreen extends StatefulWidget {
  final JournalEntry? entry;

  const WriteScreen({super.key, this.entry});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> with WidgetsBindingObserver {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _selectedMood = 'Calm';
  late String _selectedImage;
  final _repository = JournalRepository();

  void _showIncompleteDialog(List<String> missingFields) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.systemYellow,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.incompleteTitle,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.incompleteDesc,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ...missingFields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.systemRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        field,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.ok,
              style: const TextStyle(
                color: AppColors.systemBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(
      text: widget.entry?.content ?? '',
    );
    _selectedMood = widget.entry?.mood ?? 'Calm';
    _selectedImage = widget.entry?.imageUrl ?? PresetImages.getDefault();

    // Cek draft HANYA kalau mode new (bukan edit)
    if (widget.entry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForDraft();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (widget.entry == null && _hasUnsavedContent()) {
        _saveDraft();
      }
    }
  }

  bool _hasUnsavedContent() {
    return _titleController.text.trim().isNotEmpty ||
        _contentController.text.trim().isNotEmpty;
  }

  Future<void> _saveDraft() async {
    final settingsBox = Hive.box('settingsBox');
    await settingsBox.put('draft_title', _titleController.text);
    await settingsBox.put('draft_content', _contentController.text);
    await settingsBox.put('draft_mood', _selectedMood);
    await settingsBox.put('draft_image', _selectedImage);
    await settingsBox.put('draft_has_data', true);
  }

  Future<void> _clearDraft() async {
    final settingsBox = Hive.box('settingsBox');
    await settingsBox.delete('draft_title');
    await settingsBox.delete('draft_content');
    await settingsBox.delete('draft_mood');
    await settingsBox.delete('draft_image');
    await settingsBox.put('draft_has_data', false);
  }

  Future<void> _checkForDraft() async {
    final settingsBox = Hive.box('settingsBox');
    final hasDraft = settingsBox.get('draft_has_data', defaultValue: false);

    if (!hasDraft) return;
    if (!mounted) return;

    final title = settingsBox.get('draft_title', defaultValue: '');
    final content = settingsBox.get('draft_content', defaultValue: '');

    if (title.trim().isEmpty && content.trim().isEmpty) {
      await _clearDraft();
      return;
    }

    _showDraftDialog();
  }

  void _showDraftDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.edit_note, color: AppColors.systemBlue, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.draftFoundTitle,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.draftFoundDesc,
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              HapticFeedback.selectionClick();
              await _clearDraft();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.discardDraft,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.selectionClick();
              final settingsBox = Hive.box('settingsBox');
              setState(() {
                _titleController.text = settingsBox.get(
                  'draft_title',
                  defaultValue: '',
                );
                _contentController.text = settingsBox.get(
                  'draft_content',
                  defaultValue: '',
                );
                _selectedMood = settingsBox.get(
                  'draft_mood',
                  defaultValue: 'Calm',
                );
                _selectedImage = settingsBox.get(
                  'draft_image',
                  defaultValue: PresetImages.getDefault(),
                );
              });
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.continueDraft,
              style: const TextStyle(
                color: AppColors.systemBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCloseConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.draftFoundTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.draftFoundDesc,
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.selectionClick();
              await _clearDraft();
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.discardDraft,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.selectionClick();
              await _saveDraft();
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
              TopBanner.show(
                context,
                message: AppLocalizations.of(context)!.draftSaved,
                type: BannerType.info,
              );
            },
            child: Text(
              AppLocalizations.of(context)!.save,
              style: const TextStyle(
                color: AppColors.systemBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        HapticFeedback.mediumImpact();
        setState(() {
          _selectedImage = pickedFile.path;
        });
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      TopBanner.show(
        context,
        message: 'Gagal memilih gambar',
        type: BannerType.error,
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        HapticFeedback.mediumImpact();
        setState(() {
          _selectedImage = pickedFile.path;
        });
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal membuka kamera'),
          backgroundColor: AppColors.cardDark,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 90, left: 20, right: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            // === KONTEN UTAMA ===
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === PILIHAN GAMBAR ===
                    // === KATEGORI 1: PRESET GAMBAR ===
                    ImagePickerSection(
                      selectedImage: _selectedImage,
                      onPickFromGallery: _pickImageFromGallery,
                      onPickFromCamera: _pickImageFromCamera,
                      onImageSelected: (image) {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // === MOOD SELECTOR ===
                    Text(
                      AppLocalizations.of(context)!.howFeeling,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MoodSelector(
                      selectedMood: _selectedMood,
                      onMoodSelected: (mood) {
                        setState(() {
                          _selectedMood = mood;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // === JUDUL ===
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.titleHint,
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // === ISI JURNAL ===
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary.withValues(alpha: 0.8),
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.contentHint,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // === TOMBOL CLOSE (KIRI ATAS) ===
            Positioned(
              top: 16,
              left: 16,
              child: _buildCircleButton(
                icon: Icons.close,
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (_hasUnsavedContent()) {
                    _showCloseConfirmDialog();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),

            // === TOMBOL SAVE/UPDATE (KANAN ATAS) ===
            Positioned(
              top: 16,
              right: 16,
              child: _buildCircleButton(
                label: isEditing
                    ? AppLocalizations.of(context)!.update
                    : AppLocalizations.of(context)!.save,
                labelColor: AppColors.systemBlue,
                onTap: () async {
                  HapticFeedback.mediumImpact();

                  // === VALIDASI ===
                  final missingFields = <String>[];

                  if (_titleController.text.trim().isEmpty) {
                    missingFields.add(
                      AppLocalizations.of(context)!.missingTitle,
                    );
                  }
                  if (_contentController.text.trim().isEmpty) {
                    missingFields.add(
                      AppLocalizations.of(context)!.missingContent,
                    );
                  }
                  // Kalau bukan edit dan belum pilih foto dari galeri
                  // (foto preset selalu ada, jadi kita cek apakah user pakai default)
                  // Kita tidak cek foto karena preset selalu ada

                  if (missingFields.isNotEmpty) {
                    _showIncompleteDialog(missingFields);
                    return;
                  }

                  // === SIMPAN ===
                  final today = DateFormat(
                    'MMM d, yyyy HH:mm',
                  ).format(DateTime.now());

                  if (isEditing) {
                    widget.entry!.title = _titleController.text;
                    widget.entry!.content = _contentController.text;
                    widget.entry!.mood = _selectedMood;
                    widget.entry!.imageUrl = _selectedImage;
                    widget.entry!.lastEdited = DateTime.now();
                    await _repository.updateJournal(widget.entry!);
                  } else {
                    final newEntry = JournalEntry(
                      title: _titleController.text,
                      content: _contentController.text,
                      date: today,
                      mood: _selectedMood,
                      imageUrl: _selectedImage,
                      lastEdited: DateTime.now(),
                    );
                    await _repository.addJournal(newEntry);
                  }

                  await _clearDraft();
                  if (!context.mounted) return;
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ),
            // === JUDUL MELAYANG DI TENGAH ATAS (PILL) ===
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    isEditing
                        ? AppLocalizations.of(context)!.editEntry
                        : AppLocalizations.of(context)!.newEntry,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    IconData? icon,
    String? label,
    required VoidCallback onTap,
    Color? labelColor,
    bool isPrimary = false,
  }) {
    final isLabeled = label != null;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: isLabeled
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
            : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.textPrimary
              : AppColors.cardDark.withValues(alpha: 0.9),
          shape: isLabeled ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: isLabeled ? BorderRadius.circular(20) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isLabeled
            ? Text(
                label,
                style: TextStyle(
                  color: labelColor ?? AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}
