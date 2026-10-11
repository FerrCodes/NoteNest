import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/journal_entry.dart';

class JournalRepository {
  final Box<JournalEntry> _box = Hive.box<JournalEntry>('journalBox');

  /// Ambil semua jurnal, urutkan dari yang terbaru.
  List<JournalEntry> getAllJournals() {
    return _box.values.toList().reversed.toList();
  }

  /// Ambil jurnal dengan filter mood, favorit, dan kata kunci pencarian.
  List<JournalEntry> getFilteredJournals({
    String? moodFilter, // null = semua, 'FAVORITE' = hanya favorit
    String searchQuery = '',
  }) {
    return getAllJournals().where((entry) {
      // Filter berdasarkan mood atau favorit
      if (moodFilter != null) {
        if (moodFilter == 'FAVORITE') {
          if (!entry.isFavorite) return false;
        } else {
          if (entry.mood != moodFilter) return false;
        }
      }
      // Filter berdasarkan kata kunci
      if (searchQuery.isNotEmpty) {
        final titleMatch = entry.title.toLowerCase().contains(searchQuery);
        final contentMatch = entry.content.toLowerCase().contains(searchQuery);
        if (!titleMatch && !contentMatch) return false;
      }
      return true;
    }).toList();
  }

  /// Cek apakah database kosong.
  bool isEmpty() => _box.isEmpty;

  /// Jumlah total jurnal.
  int get count => _box.length;

  /// Tambah jurnal baru.
  Future<void> addJournal(JournalEntry entry) async {
    await _box.add(entry);
  }

  /// Hapus jurnal.
  Future<void> deleteJournal(JournalEntry entry) async {
    await entry.delete();
  }

  /// Simpan perubahan pada jurnal (untuk edit).
  Future<void> updateJournal(JournalEntry entry) async {
    await entry.save();
  }

  /// Hapus semua jurnal.
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Ambil listenable box, untuk ValueListenableBuilder di UI.
  ValueListenable<Box<JournalEntry>> get listenable => _box.listenable();
}
