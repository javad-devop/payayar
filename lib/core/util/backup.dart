import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';

/// Fixed backup file name inside the app documents directory — a
/// deterministic path means restore needs no file picker.
const backupFileName = 'payayar_backup.db';

/// Directory holding [backupFileName] (app documents on desktop,
/// app-specific storage on Android).
Future<Directory> backupDirectory() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/backups');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

Future<String> backupFilePath() async {
  final dir = await backupDirectory();
  return '${dir.path}/$backupFileName';
}

/// Writes a consistent snapshot of the whole database to [destination]
/// with SQLite `VACUUM INTO` (single file, no WAL sidecars).
Future<String> exportBackupTo(AppDatabase db, String destination) async {
  final file = File(destination);
  if (await file.exists()) await file.delete();
  await db.customStatement('VACUUM INTO ?', [destination]);
  return destination;
}

Future<String> exportBackup(AppDatabase db) =>
    exportBackupTo(db, backupFilePath());

/// Replaces every application table's contents with the rows found in
/// the backup at [source]. Same-version schema assumed; columns are
/// intersected by name so a slightly older backup still restores.
/// Returns the number of restored tables.
Future<int> restoreBackupFrom(AppDatabase db, String source) async {
  if (!await File(source).exists()) {
    throw StateError('backup_missing');
  }
  await db.customStatement('PRAGMA foreign_keys = OFF');
  try {
    await db.customStatement('ATTACH DATABASE ? AS backup', [source]);
    try {
      final rows = await db
          .customSelect(
            "SELECT name FROM main.sqlite_master WHERE type = 'table' "
            "AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '\\_%' ESCAPE '\\' "
            "ORDER BY name",
          )
          .get();
      var restored = 0;
      for (final row in rows) {
        final table = row.read<String>('name');
        final mainCols = await _columns(db, 'main', table);
        final backupCols = await _columns(db, 'backup', table);
        if (mainCols.isEmpty || backupCols.isEmpty) continue;
        final common = mainCols.where(backupCols.contains).toList();
        if (common.isEmpty) continue;
        final quoted = common.map((c) => '"$c"').join(', ');
        // Per-table atomicity: ATTACH forbids an outer transaction.
        await db.transaction(() async {
          await db.customStatement('DELETE FROM "$table"');
          await db
              .customStatement('INSERT INTO "$table" ($quoted) '
                  'SELECT $quoted FROM "backup"."$table"');
        });
        restored++;
      }
      // Keep AUTOINCREMENT sequences aligned with the restored rows.
      final hasSeq = await db
          .customSelect(
            "SELECT name FROM backup.sqlite_master "
            "WHERE type = 'table' AND name = 'sqlite_sequence'",
          )
          .get();
      if (hasSeq.isNotEmpty) {
        await db.customStatement('DELETE FROM sqlite_sequence');
        await db.customStatement(
          'INSERT INTO sqlite_sequence (name, seq) '
          'SELECT name, seq FROM backup.sqlite_sequence',
        );
      }
      return restored;
    } finally {
      await db.customStatement('DETACH DATABASE backup');
    }
  } finally {
    await db.customStatement('PRAGMA foreign_keys = ON');
  }
}

Future<List<String>> _columns(AppDatabase db, String schema, String table) {
  return db
      .customSelect('PRAGMA $schema.table_info("$table")')
      .get()
      .then((rows) => rows.map((r) => r.read<String>('name')).toList());
}
