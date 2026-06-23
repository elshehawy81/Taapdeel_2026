import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ✅ Public kind (عشان تستخدمه برا الملف)
enum OrbitTagKind { category, subCategory, tag }

/// ✅ Callback signature (تقدر تعمل Edit/Delete في الشاشة)
typedef OrbitTagTap = void Function({
required String text,
required OrbitTagKind kind,
required int tagIndex, // index داخل tags (لو kind=tag) وإلا = -1
});

class OrbitTagsAround extends StatelessWidget {
  const OrbitTagsAround({
    Key? key,
    required this.child,
    this.enable = true,
    this.editable = false,
    this.ringCount = 2,
    this.padding = const EdgeInsets.all(10),
    this.tags = const <String>[],
    this.categoryLabel = '',
    this.subCategoryLabel = '',
    this.size,
    this.onCategoryChanged,
    this.onSubCategoryChanged,

    /// ✅ نسبة "الدائرة" اللي ممنوع التاجز تدخلها
    this.innerHoleRadiusFactor = 0.70,

    /// ✅ ستايل الألوان (اختياري)
    this.categoryAccent,
    this.subCategoryAccent,
    this.palette,

    /// ✅ Layout tuning
    this.tagHeight = 34,
    this.maxTagWidth = 150,
    this.minTagWidth = 64,
    this.minGapPx = 10,

    /// ✅ Callbacks
    this.onTagsChanged,
    this.onTap,
    this.onDelete,
    this.onCategoryTap,
    this.onSubCategoryTap,

    this.confirmDelete = false,
  }) : super(key: key);

  final Widget child;
  final bool enable;

  /// ✅ لو true: chips تبقى تفاعلية (تعديل/حذف)
  final bool editable;

  final int ringCount;
  final EdgeInsets padding;
  final List<String> tags;
  final String categoryLabel;
  final String subCategoryLabel;
  final VoidCallback? onCategoryTap;
  final VoidCallback? onSubCategoryTap;

  /// If null -> will use constraints.maxWidth (square).
  final double? size;

  /// 0.70 means: inner forbidden circle = 70% of half side.
  final double innerHoleRadiusFactor;

  /// ✅ Optional accents
  final Color? categoryAccent;
  final Color? subCategoryAccent;
  final List<Color>? palette;

  /// ✅ Layout tuning
  final double tagHeight;
  final double maxTagWidth;
  final double minTagWidth;
  final double minGapPx;

  /// ✅ Emits updated tags list after edit/delete
  final ValueChanged<List<String>>? onTagsChanged;
  final ValueChanged<String>? onCategoryChanged;
  final ValueChanged<String>? onSubCategoryChanged;

  /// ✅ Optional: notify parent when tapped (before dialog)
  final OrbitTagTap? onTap;

  /// ✅ Optional: notify parent when deleted
  final OrbitTagTap? onDelete;

  /// ✅ Optional confirm delete dialog
  final bool confirmDelete;

  @override
  Widget build(BuildContext context) {
    if (!enable) return child;

    final bool isSmallScreen = MediaQuery.sizeOf(context).width < 370;

    final List<_OrbitLabel> all = <_OrbitLabel>[
      if (categoryLabel.trim().isNotEmpty)
        _OrbitLabel(
          categoryLabel.trim(),
          kind: OrbitTagKind.category,
          tagIndex: -1,
        ),
      if (subCategoryLabel.trim().isNotEmpty)
        _OrbitLabel(
          subCategoryLabel.trim(),
          kind: OrbitTagKind.subCategory,
          tagIndex: -1,
        ),
      ...tags
          .take(isSmallScreen ? 4 : tags.length)
          .toList()
          .asMap()
          .entries
          .where((e) => e.value.trim().isNotEmpty)
          .map(
            (e) => _OrbitLabel(
          e.value.trim(),
          kind: OrbitTagKind.tag,
          tagIndex: e.key,
        ),
      ),
    ];

    if (all.isEmpty) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final double side = size ?? w;
        final bool isSmallBox = w < 370;

        final double adaptiveTagHeight = isSmallBox ? 32 : tagHeight;
        final double adaptiveMaxTagWidth = isSmallBox ? 118 : maxTagWidth;
        final double adaptiveMinTagWidth = isSmallBox ? 60 : minTagWidth;
        final double adaptiveInnerHoleFactor =
        isSmallBox ? 0.58 : innerHoleRadiusFactor;
        final EdgeInsets adaptivePadding =
        isSmallBox ? const EdgeInsets.all(6) : padding;

        return SizedBox(
          width: side,
          height: side,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: child),
              Positioned.fill(
                child: _OrbitLayer(
                  box: Size(side, side),
                  padding: adaptivePadding,
                  ringCount: math.max(1, ringCount),
                  labels: all,
                  innerHoleRadius: (side / 2) * adaptiveInnerHoleFactor,
                  tagHeight: adaptiveTagHeight,
                  maxTagWidth: adaptiveMaxTagWidth,
                  minTagWidth: adaptiveMinTagWidth,
                  onCategoryTap: onCategoryTap,
                  onSubCategoryTap: onSubCategoryTap,
                  minGapPx: minGapPx,
                  categoryAccent: categoryAccent,
                  subCategoryAccent: subCategoryAccent,
                  palette: palette,
                  editable: editable,
                  tags: tags,
                  onTagsChanged: onTagsChanged,
                  onTap: onTap,
                  onDelete: onDelete,
                  confirmDelete: confirmDelete,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrbitLabel {
  _OrbitLabel(this.text, {required this.kind, required this.tagIndex});

  final String text;
  final OrbitTagKind kind;

  /// ✅ index داخل tags لو kind=tag، وإلا -1
  final int tagIndex;
}

class _OrbitLayer extends StatelessWidget {
  const _OrbitLayer({
    required this.box,
    required this.padding,
    required this.ringCount,
    required this.labels,
    required this.innerHoleRadius,
    required this.tagHeight,
    required this.maxTagWidth,
    required this.minTagWidth,
    required this.minGapPx,
    required this.categoryAccent,
    required this.subCategoryAccent,
    required this.palette,
    required this.editable,
    required this.tags,
    required this.onTagsChanged,
    required this.onTap,
    required this.onDelete,
    required this.onCategoryTap,
    required this.onSubCategoryTap,
    required this.confirmDelete,
  });

  final Size box;
  final EdgeInsets padding;
  final int ringCount;
  final List<_OrbitLabel> labels;

  /// دائرة ممنوع التاجز تدخلها (حواليـن الصورة)
  final double innerHoleRadius;

  final double tagHeight;
  final double maxTagWidth;
  final double minTagWidth;
  final double minGapPx;

  final Color? categoryAccent;
  final Color? subCategoryAccent;
  final List<Color>? palette;
  final VoidCallback? onCategoryTap;
  final VoidCallback? onSubCategoryTap;
  final bool editable;
  final List<String> tags;
  final ValueChanged<List<String>>? onTagsChanged;
  final OrbitTagTap? onTap;
  final OrbitTagTap? onDelete;
  final bool confirmDelete;

  @override
  Widget build(BuildContext context) {
    final double minSide = math.min(box.width, box.height);

    final ThemeData theme = Theme.of(context);
    final TextStyle baseStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.0,
    ) ??
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1.0,
        );

    // ✅ outer radius (حدود الكارد)
    final double outerR = (minSide / 2) - (tagHeight / 2) - 6;

    // ✅ inner forbidden radius (دائرة الصورة)
    final double innerR = innerHoleRadius + (tagHeight / 2) + 10;

    if (outerR <= innerR + 10) {
      return Center(
        child: Padding(
          padding: padding,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: labels.take(4).map((label) {
              return _OrbitTagChip(
                text: label.text,
                height: tagHeight,
                width: math.min(maxTagWidth, 110),
                accent: _accentFor(label, 0),
                textStyle: baseStyle,
                editable: editable,
                canDelete: editable && label.kind == OrbitTagKind.tag,
                onTap: null,
                onDelete: null,
              );
            }).toList(),
          ),
        ),
      );
    }

    final List<List<_OrbitLabel>> rings = _splitAcrossRings(labels, ringCount);

    // ✅ radii between innerR .. outerR
    final double usable = outerR - innerR;
    final double ringGap = usable / math.max(1, ringCount);
    final List<double> radii = List<double>.generate(
      ringCount,
          (i) => innerR + ringGap * (i + 0.55),
    );

    final Offset center = Offset(box.width / 2, box.height / 2);
    final List<Widget> positioned = <Widget>[];

    for (int r = 0; r < rings.length; r++) {
      final List<_OrbitLabel> ringLabels = rings[r];
      if (ringLabels.isEmpty) continue;

      final double radius = radii[r];

      // ✅ زاوية بداية مختلفة لكل رينج عشان المنظر يبقى طبيعي
      final double startAngle = -math.pi / 2 + (r * 0.55);

      // ✅ احسب عرض كل chip حسب النص + مساحة زر × لو editable
      final List<double> widths = ringLabels
          .map(
            (e) => _measureChipWidth(
          e.text,
          baseStyle,
          minTagWidth: minTagWidth,
          maxTagWidth: maxTagWidth,
          hasDelete: editable && e.kind == OrbitTagKind.tag,
        ),
      )
          .toList();

      // ✅ زوايا مبدئية
      List<double> angles = List<double>.generate(
        ringLabels.length,
            (i) => startAngle + (i * (math.pi * 2 / ringLabels.length)),
      );

      // ✅ حاول تمنع التداخل على نفس الرينج (greedy spacing)
      angles = _spreadAnglesByWidth(
        angles: angles,
        widths: widths,
        radius: radius,
        minGapPx: minGapPx,
      );

      for (int i = 0; i < ringLabels.length; i++) {
        final _OrbitLabel label = ringLabels[i];
        final double w = widths[i];
        final double a = angles[i];

        final double x = center.dx + radius * math.cos(a);
        final double y = center.dy + radius * math.sin(a);

        double left = x - (w / 2);
        double top = y - (tagHeight / 2);

        final double minLeft = padding.left;
        final double maxLeft = box.width - padding.right - w;
        final double minTop = padding.top;
        final double maxTop = box.height - padding.bottom - tagHeight;

        if (left < minLeft) left = minLeft;
        if (left > maxLeft) left = maxLeft;
        if (top < minTop) top = minTop;
        if (top > maxTop) top = maxTop;

        final Color accent = _accentFor(label, i);
        final bool isTag = label.kind == OrbitTagKind.tag;
        final bool isCat = label.kind == OrbitTagKind.category;
        final bool isSub = label.kind == OrbitTagKind.subCategory;

        positioned.add(
          Positioned(
            left: left,
            top: top,
            child: _OrbitTagChip(
              text: label.text,
              height: tagHeight,
              width: w,
              accent: accent,
              textStyle: baseStyle,
              editable: editable,
              canDelete: editable && isTag,
              onTap: !editable
                  ? null
                  : () async {
                if (isTag) {
                  await _handleEdit(context, label);
                  return;
                }
                if (isCat) {
                  onCategoryTap?.call();
                  return;
                }
                if (isSub) {
                  onSubCategoryTap?.call();
                  return;
                }
              },
              onDelete: (editable && isTag)
                  ? () => _handleDelete(context, label)
                  : null,
            ),
          ),
        );
      }
    }

    if (!editable) {
      return IgnorePointer(
        ignoring: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: positioned,
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: positioned,
    );
  }

  List<List<_OrbitLabel>> _splitAcrossRings(List<_OrbitLabel> list, int rings) {
    final List<List<_OrbitLabel>> out =
    List<List<_OrbitLabel>>.generate(rings, (_) => <_OrbitLabel>[]);

    for (int i = 0; i < list.length; i++) {
      out[i % rings].add(list[i]);
    }
    return out;
  }

  double _measureChipWidth(
      String text,
      TextStyle style, {
        required double minTagWidth,
        required double maxTagWidth,
        required bool hasDelete,
      }) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.rtl,
      ellipsis: '…',
    )..layout(maxWidth: maxTagWidth);

    double raw = tp.width + 24 + 6;

    if (hasDelete) raw += 22;

    return raw.clamp(minTagWidth, maxTagWidth);
  }

  List<double> _spreadAnglesByWidth({
    required List<double> angles,
    required List<double> widths,
    required double radius,
    required double minGapPx,
  }) {
    if (angles.length <= 2) return angles;

    final List<int> idx = List<int>.generate(angles.length, (i) => i);
    idx.sort((a, b) => angles[a].compareTo(angles[b]));

    final List<double> out = List<double>.from(angles);

    for (int k = 1; k < idx.length; k++) {
      final int prev = idx[k - 1];
      final int cur = idx[k];

      final double needPx =
          (widths[prev] / 2) + (widths[cur] / 2) + minGapPx;
      final double needAng = needPx / radius;

      if (out[cur] < out[prev] + needAng) {
        out[cur] = out[prev] + needAng;
      }
    }

    final double minA = out.reduce(math.min);
    final double maxA = out.reduce(math.max);

    if ((maxA - minA) > (math.pi * 2 * 0.98)) {
      final double start = angles[idx.first];
      return List<double>.generate(
        angles.length,
            (i) => start + (i * (math.pi * 2 / angles.length)),
      );
    }

    final double meanBefore = angles.reduce((a, b) => a + b) / angles.length;
    final double meanAfter = out.reduce((a, b) => a + b) / out.length;
    final double shift = meanBefore - meanAfter;

    return out.map((a) => a + shift).toList();
  }

  Color _accentFor(_OrbitLabel label, int i) {
    final List<Color> base = palette ??
        const <Color>[
          Color(0xFFFFB74D),
          Color(0xFF4DD0E1),
          Color(0xFF9575CD),
          Color(0xFFE57373),
          Color(0xFF64B5F6),
          Color(0xFF81C784),
          Color(0xFFFF8A65),
          Color(0xFF4FC3F7),
        ];

    switch (label.kind) {
      case OrbitTagKind.category:
        return categoryAccent ?? const Color(0xFF4DD0E1);
      case OrbitTagKind.subCategory:
        return subCategoryAccent ?? const Color(0xFF9575CD);
      case OrbitTagKind.tag:
        return base[i % base.length];
    }
  }

  Future<void> _handleEdit(BuildContext context, _OrbitLabel label) async {
    onTap?.call(text: label.text, kind: label.kind, tagIndex: label.tagIndex);

    if (label.kind != OrbitTagKind.tag) return;

    final String? newText = await _showEditDialog(
      context: context,
      initial: label.text,
    );

    if (newText == null) return;

    final String trimmed = newText.trim();
    if (trimmed.isEmpty) return;
    if (label.tagIndex < 0 || label.tagIndex >= tags.length) return;

    final List<String> updated = List<String>.from(tags);
    updated[label.tagIndex] = trimmed;
    onTagsChanged?.call(updated);
  }

  Future<void> _handleDelete(BuildContext context, _OrbitLabel label) async {
    onDelete?.call(text: label.text, kind: label.kind, tagIndex: label.tagIndex);

    if (label.kind != OrbitTagKind.tag) return;
    if (label.tagIndex < 0 || label.tagIndex >= tags.length) return;

    bool ok = true;
    if (confirmDelete) {
      ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('حذف التاج'),
          content: Text('تحب تحذف "${label.text}" ؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف'),
            ),
          ],
        ),
      ) ??
          false;
    }

    if (!ok) return;

    final List<String> updated = List<String>.from(tags)
      ..removeAt(label.tagIndex);
    onTagsChanged?.call(updated);
  }

  Future<String?> _showEditDialog({
    required BuildContext context,
    required String initial,
  }) async {
    final TextEditingController c = TextEditingController(text: initial);

    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit tag'),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: c,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => Navigator.pop(ctx, c.text),
              decoration: const InputDecoration(
                hintText: 'اكتب التاج…',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _OrbitTagChip extends StatelessWidget {
  const _OrbitTagChip({
    required this.text,
    required this.height,
    required this.width,
    required this.accent,
    required this.textStyle,
    required this.editable,
    required this.canDelete,
    this.onTap,
    this.onDelete,
  });

  final String text;
  final double height;
  final double width;
  final Color accent;
  final TextStyle textStyle;

  final bool editable;
  final bool canDelete;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final Color bg = Color.lerp(Colors.white, accent, 0.10)!.withOpacity(0.98);
    final Color border = accent.withOpacity(0.65);
    final Color textColor = Colors.black.withOpacity(0.78);

    final Widget body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1.4),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textAlign: TextAlign.center,
              style: textStyle.copyWith(color: textColor),
            ),
          ),
          if (editable && canDelete) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.black.withOpacity(0.70),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: editable
          ? InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: body,
      )
          : body,
    );
  }
}