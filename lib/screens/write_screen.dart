import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';
import '../utils/preset_images.dart';
import '../l10n/app_localizations.dart';
import '../widgets/top_banner.dart';
import '../repositories/journal_repository.dart';
import '../widgets/mood_selector.dart';
import '../widgets/image_picker_section.dart';
import '../theme/app_colors.dart';
import '../services/haptic_service.dart';
import 'dart:io';
import 'package:intl/intl.dart';

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
  late List<String> _selectedImages;
  late DateTime _entryDate;
  final _repository = JournalRepository();

  void _showIncompleteDialog(List<String> missingFields) {
    HapticService.heavyImpact();

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
              HapticService.selectionClick();
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
    _selectedImages = widget.entry?.imageUrls.isNotEmpty == true
        ? List<String>.from(widget.entry!.imageUrls)
        : [];

    // Cek draft HANYA kalau mode new (bukan edit)
    if (widget.entry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForDraft();
      });
    }
    if (widget.entry != null) {
      try {
        _entryDate = DateTime.parse(widget.entry!.date);
      } catch (_) {
        _entryDate = DateTime.now();
      }
    } else {
      _entryDate = DateTime.now();
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
    await settingsBox.put('draft_images', _selectedImages);
    await settingsBox.put('draft_has_data', true);
  }

  Future<void> _clearDraft() async {
    final settingsBox = Hive.box('settingsBox');
    await settingsBox.delete('draft_title');
    await settingsBox.delete('draft_content');
    await settingsBox.delete('draft_mood');
    await settingsBox.delete('draft_images');
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

  // Fungsi untuk memfilter gambar yang sudah tidak ada di storage
  List<String> _validateAndFilterImages(List<dynamic> savedImages) {
    final List<String> validImages = [];

    for (var img in savedImages) {
      final imagePath = img as String;

      // Jika gambar dari internet (http) atau asset bawaan aplikasi,
      // anggap valid.
      if (imagePath.startsWith('http') || imagePath.startsWith('assets/')) {
        validImages.add(imagePath);
      }
      // Jika gambar dari storage HP, cek apakah file-nya masih ada
      else {
        final file = File(imagePath);
        if (file.existsSync()) {
          validImages.add(imagePath);
        } else {
          debugPrint('Draft image tidak ditemukan, dibuang: $imagePath');
        }
      }
    }
    return validImages;
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
              HapticService.selectionClick();
              // === TAMBAHKAN KODE INI ===
              // Bersihkan cache memori Flutter agar tidak menampilkan gambar hantu
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              // ============================
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
              HapticService.selectionClick();
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

                // Ambil data gambar dari draft
                final savedImages = settingsBox.get(
                  'draft_images',
                  defaultValue: <String>[],
                );

                // Jalankan validasi
                final validImages = _validateAndFilterImages(savedImages);

                // Jika setelah divalidasi ternyata kosong, pakai gambar default
                _selectedImages = validImages.isNotEmpty
                    ? validImages
                    : [PresetImages.getDefault()];
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
              HapticService.selectionClick();
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              HapticService.selectionClick();
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
              HapticService.selectionClick();
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

  Future<void> _pickDateTime() async {
    HapticService.selectionClick();

    // 1. Pilih Tanggal
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.textPrimary,
              onPrimary: AppColors.bgDark,
              surface: AppColors.cardDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;
    if (!mounted) return;

    // 2. Pilih Waktu
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_entryDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.cardDark,
              hourMinuteColor: AppColors.textPrimary.withValues(alpha: 0.1),
              hourMinuteTextColor: AppColors.textPrimary,
              dialBackgroundColor: AppColors.bgDark,
              dialHandColor: AppColors.textPrimary,
              dialTextColor: AppColors.textSecondary,
              entryModeIconColor: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // 3. Gabungkan dan Simpan ke State
    setState(() {
      _entryDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
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
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 67.0,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === 1. IMAGE PICKER SECTION (sudah punya padding internal) ===
                  ImagePickerSection(
                    selectedImages: _selectedImages,
                    onImagesChanged: (newList) {
                      setState(() {
                        _selectedImages = newList;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // === 2. MOOD SELECTOR ===
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context)!.howFeeling,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  MoodSelector(
                    selectedMood: _selectedMood,
                    currentMood: widget.entry?.mood,
                    onMoodSelected: (mood) {
                      setState(() {
                        _selectedMood = mood;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // === SECTION: TANGGAL & WAKTU ===
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.journalDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _pickDateTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  DateFormat(
                                    'dd MMM yyyy, HH:mm',
                                    Localizations.localeOf(context).toString(),
                                  ).format(_entryDate),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.systemBlue,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: AppColors.systemBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 27),
                  // === 3. JUDUL ===
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _titleController,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.words,
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
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  // === DIVIDER ===
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      color: AppColors.dividerDark.withValues(alpha: 0.5),
                    ),
                  ),

                  // === 4. ISI JURNAL ===
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary.withValues(alpha: 0.85),
                          height: 1.7,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.contentHint,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // === FLOATING HEADER (Back + Pill Judul + Save) ===
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tombol Back (Kiri)
                  _buildCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () {
                      HapticService.selectionClick();
                      if (_hasUnsavedContent()) {
                        _showCloseConfirmDialog();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),

                  // Pill Judul (Tengah)
                  Expanded(
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

                  // Tombol Save/Update (Kanan)
                  _buildCircleButton(
                    label: isEditing
                        ? AppLocalizations.of(context)!.update
                        : AppLocalizations.of(context)!.save,
                    labelColor: AppColors.systemBlue,
                    onTap: () async {
                      HapticService.mediumImpact();

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

                      if (missingFields.isNotEmpty) {
                        _showIncompleteDialog(missingFields);
                        return;
                      }

                      // === SIMPAN ===
                      final today = _entryDate.toIso8601String();

                      if (isEditing) {
                        widget.entry!.title = _titleController.text;
                        widget.entry!.content = _contentController.text;
                        widget.entry!.mood = _selectedMood;
                        widget.entry!.imageUrls = _selectedImages;
                        widget.entry!.date = today;
                        widget.entry!.lastEdited = DateTime.now();
                        await _repository.updateJournal(widget.entry!);
                      } else {
                        final newEntry = JournalEntry(
                          title: _titleController.text,
                          content: _contentController.text,
                          date: today,
                          mood: _selectedMood,
                          imageUrls: _selectedImages,
                          lastEdited: DateTime.now(),
                        );
                        await _repository.addJournal(newEntry);
                      }

                      await _clearDraft();
                      if (!context.mounted) return;
                      HapticService.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                ],
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
        HapticService.selectionClick();
        onTap();
      },
      child: Container(
        padding: isLabeled
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.all(16),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Icon(icon, color: AppColors.textPrimary, size: 19),
      ),
    );
  }
}
