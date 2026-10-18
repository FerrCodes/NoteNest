import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_colors.dart';
import '../utils/slide_route.dart';
import 'reflect_screen.dart';
import '../services/haptic_service.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Langsung fokuskan ke keyboard saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveNameAndContinue() async {
    final name = _nameController.text.trim();

    // Validasi: Nama tidak boleh kosong
    if (name.isEmpty) {
      HapticService.heavyImpact();
      return;
    }

    HapticService.mediumImpact();
    final settingsBox = Hive.box('settingsBox');

    // Simpan nama dan tandai bahwa user sudah mengisi nama
    await settingsBox.put('userName', name);
    await settingsBox.put('hasSetName', true);

    if (!mounted) return;
    Navigator.pushReplacement(context, SlideRoute(page: const ReflectScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Jarak dari atas layar
                const SizedBox(height: 100),

                // Judul (Pakai DMSerifDisplay biar cantik)
                const Text(
                  'Halo! Siapa\nnamamu?',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    color: AppColors.textPrimary,
                    fontFamily: 'DMSerifDisplay',
                  ),
                ),
                const SizedBox(height: 16),

                // Deskripsi
                Text(
                  'Sebagai alasan untuk menampilkan nama tersebut di header beranda.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Input Field
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _nameController,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masukan namamu...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _saveNameAndContinue(),
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Continue (DENGAN VALUE LISTENABLE BUILDER)
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
                  builder: (context, value, child) {
                    final isNameEmpty = value.text.trim().isEmpty;

                    return SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: isNameEmpty ? null : _saveNameAndContinue,
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 200,
                          ), // Animasi transisi warna
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            // Ubah warna: Abu-abu gelap jika kosong, Putih jika ada teks
                            color: isNameEmpty
                                ? AppColors.textSecondary.withValues(alpha: 0.2)
                                : AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Mulai Menulis',
                              style: TextStyle(
                                // Ubah warna teks: Abu-abu jika kosong, Hitam jika ada teks
                                color: isNameEmpty
                                    ? AppColors.textSecondary.withValues(
                                        alpha: 0.4,
                                      )
                                    : AppColors.bgDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
