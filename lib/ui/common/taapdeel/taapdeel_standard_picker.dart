import 'package:flutter/material.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_glass_bottom_sheet.dart';

class TaapdeelPickerOption {
  final String id;
  final String title;
  final String? subtitle;
  final String? emoji;

  const TaapdeelPickerOption({
    required this.id,
    required this.title,
    this.subtitle,
    this.emoji,
  });
}

class TaapdeelPickerOptionTile extends StatelessWidget {
  const TaapdeelPickerOptionTile({
    Key? key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final TaapdeelPickerOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3A73C4), Color(0xFF2C5EA3)],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.96),
                    const Color(0xFFE6F2FF).withOpacity(0.96),
                  ],
                ),
          border: Border.all(
            color: selected ? Colors.white.withOpacity(0.60) : const Color(0xFFB8D9FF),
            width: 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3167B0).withOpacity(0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LeadingIcon(emoji: option.emoji, selected: selected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: selected ? Colors.white : const Color(0xFF0F2E57),
                    ),
                  ),
                  if ((option.subtitle ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white.withOpacity(0.80)
                            : const Color(0xFF0F2E57).withOpacity(0.60),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 120),
              child: selected
                  ? Container(
                      key: const ValueKey('sel'),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.35)),
                      ),
                      child: const Icon(Icons.check, size: 18, color: Colors.white),
                    )
                  : const SizedBox(key: ValueKey('nosel'), width: 28, height: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.emoji, required this.selected});

  final String? emoji;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final String e = (emoji ?? '✨');

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? Colors.white.withOpacity(0.14) : const Color(0xFF3167B0).withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? Colors.white.withOpacity(0.25) : const Color(0xFF3167B0).withOpacity(0.16),
        ),
      ),
      child: Text(e, style: const TextStyle(fontSize: 22)),
    );
  }
}

class TaapdeelStandardPickerSheet extends StatefulWidget {
  const TaapdeelStandardPickerSheet({
    Key? key,
    required this.title,
    required this.options,
    required this.initialSelectedIndex,
    required this.onConfirm,
    required this.onClear,
    this.maxHeight = 360,
  });

  final String title;
  final List<TaapdeelPickerOption> options;
  final int initialSelectedIndex;

  final void Function(int selectedIndex) onConfirm;
  final VoidCallback onClear;

  final double maxHeight;

  @override
  State<TaapdeelStandardPickerSheet> createState() => _TaapdeelStandardPickerSheetState();
}

class _TaapdeelStandardPickerSheetState extends State<TaapdeelStandardPickerSheet> {
  late int _tempIndex;

  @override
  void initState() {
    super.initState();
    _tempIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final opt = widget.options[i];
              final bool isSel = i == _tempIndex;

              return TaapdeelPickerOptionTile(
                option: opt,
                selected: isSel,
                onTap: () => setState(() => _tempIndex = i),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // NOTE: uses your existing TaapdeelButton
        Row(
          children: [
            Expanded(
              child: TaapdeelButton(
                label: 'مسح',
                isPrimary: false,
                onPressed: widget.onClear,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TaapdeelButton(
                label: 'تأكيد',
                isPrimary: true,
                onPressed: () => widget.onConfirm(_tempIndex),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Call this from anywhere to open the same standardized picker UI.
/// Requires TaapdeelGlassBottomSheet + TaapdeelButton to exist in your project.
Future<void> showTaapdeelStandardPicker({
  required BuildContext context,
  required String title,
  required List<TaapdeelPickerOption> options,
  required int initialSelectedIndex,
  required void Function(int selectedIndex) onConfirm,
  required VoidCallback onClear,
}) async
{
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (ctx) {
      return SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: TaapdeelGlassBottomSheet(
            child: TaapdeelStandardPickerSheet(
              title: title,
              options: options,
              initialSelectedIndex: initialSelectedIndex,
              onConfirm: (idx) {
                onConfirm(idx);
                Navigator.of(ctx).pop();
              },
              onClear: () {
                onClear();
                Navigator.of(ctx).pop();
              },
            ),
          ),
        ),
      );
    },
  );
}
