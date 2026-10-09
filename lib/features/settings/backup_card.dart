import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/util/backup.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/glass_card.dart';

/// Settings card: create a full-database backup file / restore from the
/// last backup (phase 11). All local — the file never leaves the device.
class BackupCard extends ConsumerStatefulWidget {
  const BackupCard({super.key});

  @override
  ConsumerState<BackupCard> createState() => _BackupCardState();
}

class _BackupCardState extends ConsumerState<BackupCard> {
  bool _busy = false;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _export() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final db = ref.read(databaseProvider);
      final path = await exportBackup(db);
      if (!mounted) return;
      _snack('${l10n.backup_exportDone} $path');
    } catch (_) {
      _snack(l10n.backup_error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.backup_import),
        content: Text(l10n.backup_importConfirm),
        actions: [
          SecondaryButton(
            label: l10n.common_cancel,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          PrimaryButton(
            label: l10n.common_confirm,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final db = ref.read(databaseProvider);
      final source = await backupFilePath();
      await restoreBackupFrom(db, source);
      if (!mounted) return;
      _snack(l10n.backup_importDone);
    } on StateError {
      _snack(l10n.backup_none);
    } catch (_) {
      _snack(l10n.backup_error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.save_alt_outlined, size: 20),
              const SizedBox(width: AppSpacing.md),
              Text(
                l10n.backup_title,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.backup_desc),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              PrimaryButton(
                label: l10n.backup_export,
                icon: Icons.file_download_outlined,
                onPressed: _busy ? null : _export,
              ),
              const SizedBox(width: AppSpacing.md),
              SecondaryButton(
                label: l10n.backup_import,
                icon: Icons.settings_backup_restore,
                onPressed: _busy ? null : _restore,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
