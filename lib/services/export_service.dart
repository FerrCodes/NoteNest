import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';

class ExportService {
  final Box<JournalEntry> _box = Hive.box<JournalEntry>('journalBox');

  /// Mengecek apakah ada data untuk di-export.
  bool hasData() => _box.isNotEmpty;

  /// Jumlah jurnal yang akan di-export.
  int get totalJournals => _box.length;

  /// Membuat konten teks dari seluruh jurnal.
  String _buildExportContent() {
    final buffer = StringBuffer();
    buffer.writeln('=== NOTENEST EXPORT ===');
    buffer.writeln(
      'Tanggal Export: ${DateFormat('MMM d, yyyy - HH:mm').format(DateTime.now())}',
    );
    buffer.writeln('Total Jurnal: ${_box.length}');
    buffer.writeln('================================\n');

    final entries = _box.values.toList().reversed.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.writeln('--- Jurnal #${i + 1} ---');
      buffer.writeln('Tanggal: ${entry.date}');
      buffer.writeln('Mood   : ${entry.mood}');
      buffer.writeln('Judul  : ${entry.title}');
      buffer.writeln('Isi    :');
      buffer.writeln(entry.content);
      buffer.writeln('\n');
    }

    return buffer.toString();
  }

  /// Menyimpan konten export ke file sementara, dan mengembalikan path-nya.
  /// Return null jika gagal.
  Future<String?> saveToTempFile() async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/NoteNest_$timestamp.txt');
      await file.writeAsString(_buildExportContent());
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
