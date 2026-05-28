import 'package:flutter/material.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_chip.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_glass_bottom_sheet.dart';


typedef TaapdeelIdGetter<T> = String Function(T item);
typedef TaapdeelLabelGetter<T> = String Function(T item);

Future<T?> showTaapdeelStandardGridPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required String selectedId,

  required TaapdeelIdGetter<T> idGetter,
  required TaapdeelLabelGetter<T> labelGetter,

  // UI params
  int columns = 2,
  double gap = 12,
  double maxHeight = 340,
  double chipHeight = 46,

  // Bottom actions
  String clearLabel = 'مسح',
  String confirmLabel = 'تأكيد',

  // callbacks
  bool allowEmptyConfirm = true,
}) async {
  final ThemeData theme = Theme.of(context);

  String tempId = selectedId;

  return await showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: TaapdeelGlassBottomSheet(
            child: StatefulBuilder(
              builder: (BuildContext _, void Function(void Function()) setModal) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxHeight),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints c) {
                            final double totalSpacing = (columns - 1) * gap;
                            final double chipW =
                                (c.maxWidth - totalSpacing) / columns;

                            return Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: options.map((opt) {
                                final String id = idGetter(opt);
                                final String label = labelGetter(opt);
                                final bool isSelected = id == tempId;

                                return SizedBox(
                                  width: chipW,
                                  child: TaapdeelChip(
                                    label: label,
                                    selected: isSelected,
                                    height: chipHeight,
                                    compact: false,
                                    showCheck: false,
                                    onTap: () => setModal(() => tempId = id),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TaapdeelButton(
                            label: clearLabel,
                            isPrimary: false,
                            onPressed: () => Navigator.of(ctx).pop(null),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TaapdeelButton(
                            label: confirmLabel,
                            isPrimary: true,
                            onPressed: () {
                              if (tempId.isEmpty && !allowEmptyConfirm) {
                                return;
                              }
                              // return selected item (or null if empty)
                              if (tempId.isEmpty) {
                                Navigator.of(ctx).pop(null);
                                return;
                              }
                              final T selected = options.firstWhere(
                                (o) => idGetter(o) == tempId,
                                orElse: () => options.first,
                              );
                              Navigator.of(ctx).pop(selected);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
