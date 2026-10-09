import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/util/shamsi.dart' show toFaDigits;
import '../../core/widgets/glass_card.dart';

/// Manual grade calculator (phase 10): weighted average over entered
/// scores — a tool, fully offline; no data leaves the device.
class GradeCalculatorCard extends StatefulWidget {
  const GradeCalculatorCard({super.key});

  @override
  State<GradeCalculatorCard> createState() => _GradeCalculatorCardState();
}

class _GradeRow {
  final score = TextEditingController();
  final weight = TextEditingController(text: '1');
}

class _GradeCalculatorCardState extends State<GradeCalculatorCard> {
  final List<_GradeRow> _rows = [_GradeRow(), _GradeRow()];

  @override
  void dispose() {
    for (final row in _rows) {
      row.score.dispose();
      row.weight.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() => _rows.add(_GradeRow()));
  }

  void _removeRow(int index) {
    final row = _rows[index];
    setState(() => _rows.removeAt(index));
    row.score.dispose();
    row.weight.dispose();
  }

  /// Weighted average over valid rows; null when nothing is entered.
  double? get _average {
    var weightSum = 0.0;
    var scoreSum = 0.0;
    for (final row in _rows) {
      final score = double.tryParse(row.score.text.trim());
      final weight = double.tryParse(row.weight.text.trim()) ?? 1;
      if (score == null || weight <= 0) continue;
      scoreSum += score * weight;
      weightSum += weight;
    }
    if (weightSum == 0) return null;
    return scoreSum / weightSum;
  }

  String _fa(double value) => toFaDigits(value.toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final average = _average;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.calc_title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: AppFontWeight.semiBold,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < _rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rows[i].score,
                      onChanged: (_) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.calc_score,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _rows[i].weight,
                      onChanged: (_) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.calc_weight,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.common_delete,
                    onPressed: _rows.length > 1 ? () => _removeRow(i) : null,
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.calc_add),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.calc_average,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                average == null ? '—' : _fa(average),
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
