// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'NoteNest';

  @override
  String get reflect => 'Refleksi';

  @override
  String get searchHint => 'Cari jurnal';

  @override
  String get filterAll => 'Semua';

  @override
  String get filterFavorite => 'Favorit';

  @override
  String get filterCalm => 'Tenang';

  @override
  String get filterGrateful => 'Bersyukur';

  @override
  String get filterPeaceful => 'Damai';

  @override
  String get filterFocused => 'Fokus';

  @override
  String get quoteMorning =>
      '\"Setiap pagi membawa potensi baru. Mulailah hari ini dengan niat yang baik.\"';

  @override
  String get quoteAfternoon =>
      '\"Rasa syukur mengubah apa yang kita miliki menjadi cukup.\"';

  @override
  String get quoteEvening =>
      '\"Perubahan kecil dalam cara pandang dapat membuka pintu menuju ketenangan batin yang mendalam.\"';

  @override
  String get quoteNight =>
      '\"Ketenangan malam adalah tempat jiwa menemukan istirahatnya.\"';

  @override
  String get todaysEntry => 'Jurnal Hari Ini';

  @override
  String get noJournalsTitle => 'Belum ada jurnal';

  @override
  String get noJournalsDesc =>
      'Buat baru dan mulai menulis\nmomen pertamamu hari ini.';

  @override
  String get noResultsTitle => 'Tidak ada hasil';

  @override
  String get noResultsDesc => 'Coba kata kunci lain atau ubah filter mood.';

  @override
  String get noFavoritesTitle => 'Belum ada favorit';

  @override
  String get noFavoritesDesc =>
      'Tap ikon bookmark di jurnal\nuntuk menandainya sebagai favorit.';

  @override
  String get deleteConfirmTitle => 'Hapus Jurnal?';

  @override
  String get deleteConfirmDesc =>
      'Jurnal ini akan dihapus permanen dan tidak bisa dikembalikan.';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get deleteAllTitle => 'Ingin Hapus Semua Jurnal?';

  @override
  String get deleteAllDesc => 'Semua jurnal akan dihapus permanen.';

  @override
  String get deleteAll => 'Hapus Semua';

  @override
  String get journalDeleted => 'Jurnal berhasil dihapus';

  @override
  String get allJournalsDeleted => 'Semua jurnal berhasil dihapus';

  @override
  String get newEntry => 'Jurnal Baru';

  @override
  String get editEntry => 'Edit Jurnal';

  @override
  String get save => 'Simpan';

  @override
  String get update => 'Perbarui';

  @override
  String get titleHint => 'Judul';

  @override
  String get contentHint => 'Mulai tulis pikiranmu...';

  @override
  String get selectImage => 'Preset Gambar';

  @override
  String get howFeeling => 'Bagaimana perasaanmu?';

  @override
  String get settings => 'Pengaturan';

  @override
  String get data => 'Data';

  @override
  String get exportJournals => 'Ekspor Jurnal';

  @override
  String get exportJournalsDesc => 'Simpan semua jurnal ke file teks';

  @override
  String get deleteAllJournals => 'Hapus Semua Jurnal';

  @override
  String get deleteAllJournalsDesc => 'Hapus permanen semua data jurnal';

  @override
  String get about => 'Tentang';

  @override
  String get aboutDesc =>
      'Aplikasi jurnal minimalis untuk mencatat momen harian, refleksi diri, dan melacak mood.';

  @override
  String get copyright =>
      'Aplikasi ini sedang dalam pengembangan, jika menemukan bug segera beritahu.';

  @override
  String get aboutApp => 'Tentang Aplikasi';

  @override
  String get version => 'v1.1.0';

  @override
  String get sendFeedback => 'Kirim Feedback';

  @override
  String get feedbackDesc => 'Saran atau laporan bug';

  @override
  String get madeWith => '© 2026. All rights reserved.';

  @override
  String get stats => 'Statistik';

  @override
  String get streak => 'Streak';

  @override
  String get days => 'Hari';

  @override
  String get streakDesc => 'Streak menulis jurnal';

  @override
  String get startStreak => 'Mulai streak hari ini!';

  @override
  String get totalJournals => 'Total Jurnal';

  @override
  String get thisWeek => 'Minggu Ini';

  @override
  String get thisMonth => 'Bulan Ini';

  @override
  String get weeklyChart => '7 Hari Terakhir';

  @override
  String get moodDistribution => 'Distribusi Mood';

  @override
  String get topMood => 'Mood Terbanyak';

  @override
  String get noDataTitle => 'Belum ada data';

  @override
  String get noDataDesc =>
      'Tulis jurnal pertamamu untuk\nmelihat statistik di sini.';

  @override
  String get language => 'Bahasa';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get skip => 'Lewati';

  @override
  String get next => 'Lanjut';

  @override
  String get getStarted => 'Mulai Sekarang';

  @override
  String get onboarding1Title => 'Tulis Refleksimu';

  @override
  String get onboarding1Desc =>
      'Catat momen, pikiran, dan perasaanmu setiap hari. Tidak ada aturan, tidak ada tekanan.';

  @override
  String get onboarding2Title => 'Lacak Moodmu';

  @override
  String get onboarding2Desc =>
      'Pilih mood yang mewakili harimu. Lihat pola emosimu dari waktu ke waktu.';

  @override
  String get onboarding3Title => 'Lihat Perkembanganmu';

  @override
  String get onboarding3Desc =>
      'Statistik sederhana membantumu memahami diri sendiri lebih dalam.';

  @override
  String get exportedSuccessfully => 'Jurnal berhasil di-export!';

  @override
  String get nothingToExport => 'Belum ada jurnal untuk di-export';

  @override
  String journalsWithMood(int count) {
    return '$count jurnal dengan mood ini';
  }

  @override
  String get journalDetail => 'Detail Jurnal';

  @override
  String get uploadFromGallery => 'Unggah dari galeri';

  @override
  String get chooseFromGallery => 'Pilih dari galeri';

  @override
  String get changePhoto => 'Ganti foto';

  @override
  String get tapToChoose => 'Tap untuk memilih foto dari HP';

  @override
  String get tapToChange => 'Tap untuk mengganti foto';

  @override
  String get uploadPhoto => 'Unggah foto';

  @override
  String get galleryOption => 'Galeri';

  @override
  String get galleryOptionDesc => 'Pilih foto yang ada';

  @override
  String get cameraOption => 'Kamera';

  @override
  String get cameraOptionDesc => 'Ambil foto langsung';

  @override
  String get gotIt => 'Mengerti';

  @override
  String get reminder => 'Notifikasi';

  @override
  String get dailyReminder => 'Pengingat Harian';

  @override
  String get dailyReminderDesc => 'Dapatkan notifikasi untuk menulis jurnal';

  @override
  String get reminderTime => 'Jam Pengingat';

  @override
  String get reminderMessage => 'Pesan Pengingat';

  @override
  String get reminderMessageHint => 'Tulis pesan pengingatmu...';

  @override
  String get testNotification => 'Tes Notifikasi';

  @override
  String get testNotificationDesc => 'Kirim notifikasi tes sekarang';

  @override
  String get notificationSent => 'Notifikasi tes terkirim!';

  @override
  String get permissionDenied =>
      'Izin notifikasi ditolak. Aktifkan di Pengaturan HP.';

  @override
  String get reminderSaved => 'Pengingat berhasil disimpan!';

  @override
  String get languageDesc =>
      'Pilih bahasa yang paling cocok, dan bisa diubah kapan saja.';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get aboutFeatures => 'Fitur Utama';

  @override
  String get aboutFeature1 => 'Tulis, edit, dan hapus jurnal';

  @override
  String get aboutFeature2 => 'Unggah foto dari galeri atau kamera';

  @override
  String get aboutFeature3 => 'Lacak mood dengan 4 pilihan';

  @override
  String get aboutFeature4 => 'Statistik dengan streak, kalender, dan grafik';

  @override
  String get aboutFeature5 => 'Multi-bahasa (Inggris & Indonesia)';

  @override
  String get aboutDeveloper => 'Pengembang';

  @override
  String get aboutFollowMe => 'Follow akunku di Instagram';

  @override
  String get aboutInstagramHandle => 'imnotferrriii';

  @override
  String get sourceCode => 'Lihat Repositori di GitHub';

  @override
  String get sourceCodeDesc => 'Lihat semua projek ini di repositori GitHub';

  @override
  String get sendFeedbackOptions => ' Pilih opsi untuk mengirim feedback';

  @override
  String get viaEmail => 'Email';

  @override
  String get viaWhatsApp => 'WhatsApp';

  @override
  String get noWhatsApp => 'WhatsApp tidak terinstall';

  @override
  String get feedbackMessage =>
      'Halo Feri, saya ingin memberi feedback tentang NoteNest:\n\n';

  @override
  String get aboutGithubHandle => 'FerrCodes';

  @override
  String get aboutDeveloperName => 'Feri';

  @override
  String get socialMedia => 'Media Sosial';

  @override
  String get socialMediaDesc => 'Terhubung dengan si Developer';

  @override
  String get appDescription =>
      'Aplikasi jurnal minimalis untuk mencatat momen harian, refleksi diri, dan melacak mood. Bekerja sepenuhnya offline.';

  @override
  String get dangerZone => 'Zona Berbahaya';

  @override
  String get dangerZoneDesc => 'Aksi ini tidak bisa dibatalkan';

  @override
  String get resetSettings => 'Reset Pengaturan';

  @override
  String get resetSettingsDesc => 'Kembalikan bahasa dan notifikasi ke default';

  @override
  String get resetSettingsTitle => 'Reset Pengaturan?';

  @override
  String get resetSettingsConfirm =>
      'Semua pengaturan akan dikembalikan ke default. Jurnalmu tidak akan dihapus.';

  @override
  String get reset => 'Reset';

  @override
  String get settingsReset => 'Pengaturan berhasil direset';

  @override
  String get incompleteTitle => 'Jurnal Belum Lengkap';

  @override
  String get incompleteDesc => 'Lengkapi hal berikut sebelum menyimpan:';

  @override
  String get missingTitle => 'Judul jurnal masih kosong';

  @override
  String get missingContent => 'Isi jurnal masih kosong';

  @override
  String get missingImage => 'Pilih foto terlebih dahulu';

  @override
  String get ok => 'Mengerti';

  @override
  String get draftFoundTitle => 'Draft Belum Selesai';

  @override
  String get draftFoundDesc => 'Jurnal yang belum selesai. Lanjutkan?';

  @override
  String get continueDraft => 'Lanjutkan';

  @override
  String get discardDraft => 'Buang';

  @override
  String get draftSaved => 'Draft tersimpan otomatis';

  @override
  String get feedbackTitle => 'Kirim Feedback';

  @override
  String get feedbackWhatHappened => 'Apa yang terjadi?';

  @override
  String get feedbackHint => 'Ceritakan masalah atau bug yang kamu alami';

  @override
  String get feedbackDisclaimer =>
      'Feedback tersebut akan memberi perbaiki dan peningkatan pengalaman untuk aplikasi ini.';

  @override
  String get send => 'Kirim';

  @override
  String get personalization => 'Personalisasi';

  @override
  String get manageMoods => 'Kelola Mood';

  @override
  String get manageMoodsDesc => 'Buat mood kustom kamu sendiri';

  @override
  String get customMoods => 'Mood Kustom';

  @override
  String get addMood => 'Tambah Mood';

  @override
  String get newMood => 'Mood Baru';

  @override
  String get moodNameHint => 'mis. Cemas, Semangat, Lelah...';

  @override
  String get moodLimitReached => 'Maksimal 10 mood kustom tercapai';

  @override
  String get moodAlreadyExists => 'Nama mood ini sudah dipakai';

  @override
  String get moodAdded => 'Mood berhasil ditambahkan';

  @override
  String get moodDeleted => 'Mood dihapus';

  @override
  String get deleteMoodTitle => 'Hapus Mood?';

  @override
  String get deleteMoodDesc =>
      'Jurnal dengan mood ini tetap menyimpan labelnya.';

  @override
  String get noCustomMoods => 'Belum ada mood kustom';

  @override
  String get noCustomMoodsDesc =>
      'Tap \"Tambah Mood\" untuk membuat mood kustom pertamamu.';

  @override
  String get archive => 'Arsipkan';

  @override
  String get archiveMoodTitle => 'Arsipkan Mood?';

  @override
  String get archiveMoodDesc =>
      'Mood ini akan disembunyikan. Kamu bisa memulihkannya nanti dari section Arsip.';

  @override
  String get moodArchived => 'Mood diarsipkan';

  @override
  String get moodRestored => 'Mood dipulihkan';

  @override
  String get deletePermanentTitle => 'Hapus Permanen?';

  @override
  String get deletePermanentDesc =>
      'Mood ini akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.';

  @override
  String get moodDeletedPermanent => 'Mood dihapus permanen';

  @override
  String get moodColor => 'Warna Mood';

  @override
  String get dropdownHint => 'Lihat menu';

  @override
  String get headerSection => 'Sesuaikan header';

  @override
  String get headerScreenDesc =>
      'Atur tampilan header di halaman beranda. Nyalakan atau matikan sesuai kebutuhanmu.';

  @override
  String get displaySection => 'Tampilkan';

  @override
  String get userName => 'Nama Kamu';

  @override
  String get userNameHint => 'Masukkan namamu';

  @override
  String get showDate => 'Tampilkan Tanggal';

  @override
  String get showDateDesc => 'Tampilkan tanggal hari ini';

  @override
  String get showTime => 'Tampilkan Jam';

  @override
  String get showTimeDesc => 'Tampilkan jam saat ini';

  @override
  String get showWeather => 'Tampilkan Cuaca';

  @override
  String get showWeatherDesc => 'Tampilkan cuaca (butuh internet)';

  @override
  String get greetingMorning => 'Selamat pagi,';

  @override
  String get greetingAfternoon => 'Selamat siang,';

  @override
  String get greetingEvening => 'Selamat sore,';

  @override
  String get greetingNight => 'Selamat malam';

  @override
  String readingTime(int count) {
    return '$count menit baca';
  }

  @override
  String wordCount(int count) {
    return '$count kata';
  }

  @override
  String editedTime(String time) {
    return 'Diedit $time';
  }

  @override
  String get justNow => 'baru saja';

  @override
  String minutesAgo(int count) {
    return '$count menit lalu';
  }

  @override
  String hoursAgo(int count) {
    return '$count jam lalu';
  }

  @override
  String daysAgo(int count) {
    return '$count hari lalu';
  }

  @override
  String monthsAgo(int count) {
    return '$count bulan lalu';
  }

  @override
  String yearsAgo(int count) {
    return '$count tahun lalu';
  }

  @override
  String get edit => 'Edit';
}
