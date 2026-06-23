import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../constant/ps_dimens.dart';

class TaapdeelDropdown<T> extends StatefulWidget {
  const TaapdeelDropdown({
    Key? key,
    required this.items,
    required this.itemLabelBuilder,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.prefixIcon,
    this.helperText,
    this.errorText,
    this.isExpanded = true,
    this.enabled = true,

    // ✅ NEW: BottomSheet style like "حالة المنتج"
    this.subtitleBuilder,
    this.iconBuilder,
    this.confirmText = 'تأكيد',
    this.clearText = 'مسح',
  }) : super(key: key);

  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;

  final String Function(T item) itemLabelBuilder;

  /// ✅ optional like "حالة المنتج" subtitle
  final String? Function(T item)? subtitleBuilder;

  /// ✅ optional like "حالة المنتج" icon at the right
  final IconData Function(T item)? iconBuilder;

  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;

  final IconData? prefixIcon;

  final bool isExpanded;
  final bool enabled;

  final String confirmText;
  final String clearText;

  @override
  State<TaapdeelDropdown<T>> createState() => _TaapdeelDropdownState<T>();
}

class _TaapdeelDropdownState<T> extends State<TaapdeelDropdown<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _appearController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  static const Duration _appearDuration = Duration(milliseconds: 220);

  static const Color brandBlue = Color(0xFF3167B0);
  static const Color iconColor = Color(0xFF255077);
  static const Color textDark = Color(0xFF0F2E57);

  static const BorderRadius radius = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(8),
  );

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(vsync: this, duration: _appearDuration);

    _scaleAnim = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeOutQuad),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeOutQuad),
    );

    _appearController.forward();
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  Future<void> _openBottomSheet() async {
    if (!widget.enabled) return;

    final T? current = widget.value;
    T? tempSelected = current;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget optionCard(T item)
            {
              final bool selected = tempSelected != null && tempSelected == item;
              final String title = widget.itemLabelBuilder(item);
              final String? sub = widget.subtitleBuilder?.call(item);
              final IconData? ic = widget.iconBuilder?.call(item);

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => setModalState(() => tempSelected = item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? brandBlue.withOpacity(0.55)
                          : brandBlue.withOpacity(0.20),
                      width: selected ? 1.6 : 1.0,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: textDark,
                              ),
                            ),
                            if (sub != null && sub.trim().isNotEmpty) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(
                                sub,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: textDark.withOpacity(0.55),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // right icon badge like "حالة المنتج"
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: brandBlue.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: brandBlue.withOpacity(0.22)),
                        ),
                        child: Center(
                          child: Icon(
                            ic ?? (selected ? Icons.check_rounded : Icons.circle_outlined),
                            size: 20,
                            color: selected ? brandBlue : textDark.withOpacity(0.55),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final Widget content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    widget.label ?? 'اختيار',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                ...widget.items.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: optionCard(e),
                )),

                const SizedBox(height: 6),
              ],
            );

            final Widget bottomBar = Row(
              children: <Widget>[
                Expanded(
                  child: _sheetButton(
                    label: widget.confirmText,
                    filled: true,
                    onTap: () {
                      widget.onChanged?.call(tempSelected);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _sheetButton(
                    label: widget.clearText,
                    filled: false,
                    onTap: () => setModalState(() => tempSelected = null),
                  ),
                ),
              ],
            );

            // ✅ Glass sheet container (built-in here, no dependency)
            return _TaapdeelGlassSheetShell(
              child: content,
              bottomBar: bottomBar,
            );
          },
        );
      },
    );
  }

  Widget _sheetButton({
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: filled
              ? const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: <Color>[Color(0xFF3167B0), Color(0xFF255077)],
          )
              : null,
          color: filled ? null : Colors.white.withOpacity(0.90),
          border: Border.all(
            color: filled ? Colors.transparent : brandBlue.withOpacity(0.22),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: filled ? Colors.white : textDark,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: Color(0x193167B0), width: 1.0),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: brandBlue, width: 1.6),
    );

    final OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: colorScheme.error, width: 1.6),
    );

    final String? selectedText = (widget.value == null)
        ? null
        : widget.itemLabelBuilder(widget.value as T);

    final double elevation = widget.enabled ? 2 : 0;

    // ✅ Field UI stays the same — but taps open bottom sheet
    final Widget field = InkWell(
      borderRadius: radius,
      onTap: _openBottomSheet,
      child: IgnorePointer(
        child: InputDecorator(
          isFocused: false,
          isEmpty: selectedText == null || selectedText.trim().isEmpty,
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
            floatingLabelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: iconColor)
                : null,
            suffixIcon: const Icon(Icons.arrow_drop_down_rounded, color: iconColor),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: PsDimens.lg,
              vertical: PsDimens.sm + 4,
            ),
            border: baseBorder,
            enabledBorder: baseBorder,
            focusedBorder: focusedBorder,
            disabledBorder: baseBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
            helperStyle: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              selectedText ?? '',
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: (selectedText != null && selectedText.isNotEmpty)
                    ? const Color(0xFF16355B)
                    : const Color(0xFF475569),
              ),
            ),
          ),
        ),
      ),
    );

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        alignment: Alignment.center,
        child: Material(
          elevation: elevation,
          shadowColor: brandBlue.withOpacity(0.18),
          borderRadius: radius,
          type: MaterialType.transparency,
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  color: Colors.white.withOpacity(0.94),
                  border: Border.all(
                    color: const Color(0x143167B0),
                    width: 1.0,
                  ),
                ),
                child: field,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ✅ Lightweight glass bottom sheet shell (no external dependency)
class _TaapdeelGlassSheetShell extends StatelessWidget {
  const _TaapdeelGlassSheetShell({
    required this.child,
    required this.bottomBar,
  });

  final Widget child;
  final Widget bottomBar;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                ),
                border: Border.all(
                  color: const Color(0x143167B0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    child,
                    const SizedBox(height: 12),
                    bottomBar,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
