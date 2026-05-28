import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taapdeel/utils/taapdeel_share_links.dart';

import '../../../../config/ps_config.dart';
import '../../../../viewobject/common/ps_value_holder.dart';
import '../../../../viewobject/product.dart';
import 'swap_share_happiness_phrases.dart';
import 'swap_share_theme.dart';

export 'swap_share_happiness_phrases.dart';
export 'swap_share_theme.dart';

// =============================================================
// SwapWhatsAppShareService
// =============================================================
// يبني صورة مشاركة مختلفة الشكل حسب الثيم:
//   1) pollGrid        : تصويت سريع A/B/C/D/E
//   2) vsBattle        : مواجهة VS وجولات
//   3) chatAdvice      : محادثة واتساب/استشارة
//   4) decisionBoard   : كارت قرار
//   5) storySocial     : Story social + كروت مائلة
// مع جملة سعادة عشوائية تظهر في مكان الـ footer بدل اللوجو.
// =============================================================
class SwapWhatsAppShareService {
  static const double _canvasW = 900;
  static const double _canvasH = 680;
  static const double _padding = 28;
  static const Color _white = Colors.white;
  static const List<String> _letters = <String>['أ', 'ب', 'ج', 'د', 'هـ'];

  static Future<void> share({
    required BuildContext context,
    required Product? myProduct,
    required List<Product> suggestions,
    SwapShareTheme? theme,
  }) async {
    if (myProduct == null) {
      Fluttertoast.showToast(msg: 'اختر منتجك أولاً');
      return;
    }

    if (suggestions.isEmpty) {
      Fluttertoast.showToast(msg: 'اختر منتج واحد على الأقل للاستشارة');
      return;
    }

    final SwapShareTheme selectedTheme = theme ?? SwapShareTheme.defaultTheme;
    final List<Product> shown = suggestions.take(5).toList(growable: false);
    final String happinessPhrase = SwapShareHappinessPhrases.random();
    final String referralCode = _readReferralCode(context);

    try {
      final ui.Image? myImg = await _loadProductImage(myProduct);
      final List<ui.Image?> sugImgs = await Future.wait(
        shown.map(_loadProductImage),
      );
      final ui.Image? logoImg = await _loadAssetImage(
        'assets/images/Taapdeel_icon.png',
      );

      final Uint8List pngBytes = await _buildShareImage(
        myProduct: myProduct,
        myImg: myImg,
        suggestions: shown,
        sugImgs: sugImgs,
        theme: selectedTheme,
        logoImg: logoImg,
      );

      final Directory tmpDir = await getTemporaryDirectory();
      final File imgFile = File(
        '${tmpDir.path}/taapdeel_swap_${selectedTheme.id}.png',
      );
      await imgFile.writeAsBytes(pngBytes);

      final String text = _buildShareText(myProduct, shown, selectedTheme, referralCode);
      await Share.shareXFiles(<XFile>[XFile(imgFile.path)], text: text);
    } catch (_) {
      final String text = _buildShareText(myProduct, shown, selectedTheme, referralCode);
      await Share.share(text);
    }
  }

  static String _readReferralCode(BuildContext context) {
    try {
      final PsValueHolder valueHolder =
      Provider.of<PsValueHolder>(context, listen: false);
      final String code = (valueHolder.referralCode ?? '').trim();
      if (code.isEmpty || code.toLowerCase() == 'null') return '';
      return code;
    } catch (_) {
      return '';
    }
  }

  static Future<ui.Image?> _loadProductImage(Product p) async {
    try {
      final String? raw = p.defaultPhoto?.imgPath;
      if (raw == null || raw.trim().isEmpty) return null;

      final String path = raw.trim();
      final String url = path.startsWith('http://') || path.startsWith('https://')
          ? path
          : '${PsConfig.ps_app_image_url}$path';

      final http.Response response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final ui.Codec codec = await ui.instantiateImageCodec(
        response.bodyBytes,
        targetWidth: 420,
        targetHeight: 420,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  static Future<ui.Image?> _loadAssetImage(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 360,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  static Future<Uint8List> _buildShareImage({
    required Product myProduct,
    required ui.Image? myImg,
    required List<Product> suggestions,
    required List<ui.Image?> sugImgs,
    required SwapShareTheme theme,
    required ui.Image? logoImg,

  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    _drawBackground(canvas, theme);

    switch (_resolveLayout(theme, suggestions.length)) {
      case SwapShareLayout.pollGrid:
        _drawPollGridLayout(canvas, myProduct, myImg, suggestions, sugImgs, theme);
        break;
      case SwapShareLayout.chatAdvice:
        _drawChatAdviceLayout(canvas, myProduct, myImg, suggestions, sugImgs, theme);
        break;
      case SwapShareLayout.decisionBoard:
        _drawDecisionBoardLayout(canvas, myProduct, myImg, suggestions, sugImgs, theme);
        break;
      case SwapShareLayout.vsBattle:
        _drawVsBattleLayout(canvas, myProduct, myImg, suggestions, sugImgs, theme);
        break;
      case SwapShareLayout.storySocial:
        _drawStorySocialLayout(canvas, myProduct, myImg, suggestions, sugImgs, theme);
        break;
    }

    _drawTopLogo(canvas, theme, logoImg);
    _drawFooter(canvas, theme);

    final ui.Picture picture = recorder.endRecording();
    final ui.Image img = await picture.toImage(_canvasW.toInt(), _canvasH.toInt());
    final ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static SwapShareLayout _resolveLayout(SwapShareTheme theme, int count) {
    if (count <= 1 && theme.layout == SwapShareLayout.pollGrid) {
      return SwapShareLayout.vsBattle;
    }
    if (count >= 4 && theme.layout == SwapShareLayout.vsBattle) {
      return SwapShareLayout.decisionBoard;
    }
    return theme.layout;
  }

  // =============================================================
  // Layout 1: Poll Grid — أنهي عرض أفضل؟
  // =============================================================
  static void _drawPollGridLayout(
      Canvas canvas,
      Product myProduct,
      ui.Image? myImg,
      List<Product> suggestions,
      List<ui.Image?> sugImgs,
      SwapShareTheme theme,
      ) {
    _drawCompactHeader(canvas, theme, 'رد برقم/حرف الاختيار فقط — أ / ب / ج');

    _drawMiniMyProductStrip(
      canvas,
      product: myProduct,
      image: myImg,
      rect: const Rect.fromLTWH(48, 112, 804, 88),
      theme: theme,
    );

    final int count = suggestions.length;
    final int columns = count <= 3 ? count : (count == 4 ? 2 : 3);
    final int rows = (count / columns).ceil();
    final double gap = 18;
    final double gridTop = 218;
    final double gridW = 804;
    final double gridH = rows == 1 ? 320 : 328;
    final double cardW = (gridW - gap * (columns - 1)) / columns;
    final double cardH = (gridH - gap * (rows - 1)) / rows;

    for (int i = 0; i < count; i++) {
      final int r = i ~/ columns;
      final int c = i % columns;
      final Rect rect = Rect.fromLTWH(
        48 + c * (cardW + gap),
        gridTop + r * (cardH + gap),
        cardW,
        cardH,
      );
      _drawPollCard(
        canvas,
        product: suggestions[i],
        image: i < sugImgs.length ? sugImgs[i] : null,
        rect: rect,
        letter: _letters[i],
        theme: theme,
        compact: rows > 1,
      );
    }

    _drawQuestionStrip(
      canvas,
      theme,
      y: 568,
      text: 'ابعتلي رقم الاختيار 👇  ${_letters.take(count).join(' / ')}',
    );
  }

  // =============================================================
  // Layout 2: VS Battle — مين يكسب؟
  // =============================================================
  static void _drawVsBattleLayout(
      Canvas canvas,
      Product myProduct,
      ui.Image? myImg,
      List<Product> suggestions,
      List<ui.Image?> sugImgs,
      SwapShareTheme theme,
      ) {
    _drawCompactHeader(canvas, theme, 'شايف تبديل أنهي عرض أقوى؟');

    if (suggestions.length <= 2) {
      final Product opponent = suggestions.first;
      final ui.Image? opponentImg = sugImgs.isNotEmpty ? sugImgs.first : null;

      _drawBattleCard(
        canvas,
        product: myProduct,
        image: myImg,
        rect: const Rect.fromLTWH(52, 154, 310, 360),
        title: 'منتجي',
        theme: theme,
        mine: true,
      );
      _drawVsCircle(canvas, const Offset(450, 326), theme);
      _drawBattleCard(
        canvas,
        product: opponent,
        image: opponentImg,
        rect: const Rect.fromLTWH(538, 154, 310, 360),
        title: 'الجولة 1 - اختيار أ',
        theme: theme,
      );

      if (suggestions.length == 2) {
        _drawSmallRunnerUp(
          canvas,
          product: suggestions[1],
          image: sugImgs.length > 1 ? sugImgs[1] : null,
          rect: const Rect.fromLTWH(232, 532, 436, 54),
          theme: theme,
        );
      }
    } else {
      _drawBattleCard(
        canvas,
        product: myProduct,
        image: myImg,
        rect: const Rect.fromLTWH(48, 142, 276, 330),
        title: 'منتجي',
        theme: theme,
        mine: true,
      );
      _drawVsCircle(canvas, const Offset(360, 306), theme, small: true);
      _drawText(
        canvas,
        text: 'اختار الفائز في كل جولة',
        x: 620,
        y: 134,
        fontSize: 20,
        color: theme.primaryColor,
        bold: true,
        center: true,
        maxWidth: 440,
      );

      const double startY = 178;
      for (int i = 0; i < suggestions.length; i++) {
        _drawText(
          canvas,
          text: 'الجولة ${i + 1}',
          x: 836,
          y: startY + i * 74 - 16,
          fontSize: 11,
          color: theme.accentColor,
          bold: true,
          maxWidth: 100,
        );
        _drawHorizontalChoiceCard(
          canvas,
          product: suggestions[i],
          image: i < sugImgs.length ? sugImgs[i] : null,
          rect: Rect.fromLTWH(418, startY + i * 74, 426, 64),
          letter: _letters[i],
          theme: theme,
          compact: true,
        );
      }
    }

    _drawQuestionStrip(canvas, theme, y: 596, text: 'اختار الفائز واكتب الرمز');
  }

  // =============================================================
  // Layout 3: Chat Advice — استشارة صديق
  // =============================================================
  static void _drawChatAdviceLayout(
      Canvas canvas,
      Product myProduct,
      ui.Image? myImg,
      List<Product> suggestions,
      List<ui.Image?> sugImgs,
      SwapShareTheme theme,
      ) {
    _drawPhoneFrame(canvas, theme);

    _drawChatBubble(
      canvas,
      rect: const Rect.fromLTWH(92, 86, 450, 58),
      text: theme.headerTitle,
      theme: theme,
      fromMe: false,
      fontSize: 18,
      bold: true,
    );

    _drawChatProductBubble(
      canvas,
      rect: const Rect.fromLTWH(92, 160, 560, 108),
      label: 'عندي المنتج ده',
      product: myProduct,
      image: myImg,
      theme: theme,
      fromMe: true,
    );

    const double startY = 286;
    final double cardH = suggestions.length >= 4 ? 58 : 70;
    for (int i = 0; i < suggestions.length; i++) {
      _drawChatProductBubble(
        canvas,
        rect: Rect.fromLTWH(
          i.isEven ? 156 : 92,
          startY + i * (cardH + 10),
          652,
          cardH,
        ),
        label: 'اختيار ${_letters[i]}',
        product: suggestions[i],
        image: i < sugImgs.length ? sugImgs[i] : null,
        theme: theme,
        fromMe: false,
        compact: suggestions.length >= 4,
      );
    }

    _drawChatBubble(
      canvas,
      rect: const Rect.fromLTWH(188, 540, 520, 54),
      text: 'أبدّل؟ ولا أستنى عرض أحسن؟',
      theme: theme,
      fromMe: true,
      fontSize: 18,
      bold: true,
    );
  }

  // =============================================================
  // Layout 4: Decision Board — مساعدة في القرار
  // =============================================================
  static void _drawDecisionBoardLayout(
      Canvas canvas,
      Product myProduct,
      ui.Image? myImg,
      List<Product> suggestions,
      List<ui.Image?> sugImgs,
      SwapShareTheme theme,
      ) {
    _drawMainHeader(canvas, theme, myProduct, titleOverride: 'مساعدة في اتخاذ القرار');

    final RRect board = RRect.fromRectAndRadius(
      const Rect.fromLTWH(36, 128, 828, 420),
      const Radius.circular(28),
    );
    canvas.drawRRect(board, Paint()..color = theme.surfaceColor);
    canvas.drawRRect(
      board,
      Paint()
        ..color = theme.accentColor.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    _drawDecisionMyProduct(
      canvas,
      product: myProduct,
      image: myImg,
      rect: const Rect.fromLTWH(58, 154, 230, 348),
      theme: theme,
    );

    _drawText(
      canvas,
      text: 'الخيارات المتاحة',
      x: 832,
      y: 154,
      fontSize: 18,
      color: theme.primaryColor,
      bold: true,
      maxWidth: 500,
    );

    const double startY = 194;
    final double rowH = suggestions.length >= 4 ? 60 : 78;
    for (int i = 0; i < suggestions.length; i++) {
      _drawDecisionRow(
        canvas,
        product: suggestions[i],
        image: i < sugImgs.length ? sugImgs[i] : null,
        rect: Rect.fromLTWH(318, startY + i * (rowH + 10), 516, rowH),
        letter: _letters[i],
        theme: theme,
        compact: suggestions.length >= 4,
      );
    }

    _drawQuestionStrip(canvas, theme, y: 566, text: 'لو كنت مكاني، تختار أنهي عرض؟');
  }

  // =============================================================
  // Layout 5: Story Social — ساعدني أقرر
  // =============================================================
  static void _drawStorySocialLayout(
      Canvas canvas,
      Product myProduct,
      ui.Image? myImg,
      List<Product> suggestions,
      List<ui.Image?> sugImgs,
      SwapShareTheme theme,
      ) {
    _drawText(
      canvas,
      text: theme.headerTitle,
      x: 450,
      y: 58,
      fontSize: 28,
      color: theme.primaryColor,
      bold: true,
      center: true,
      maxWidth: 820,
    );
    _drawText(
      canvas,
      text: theme.question,
      x: 450,
      y: 96,
      fontSize: 16,
      color: theme.accentColor,
      bold: true,
      center: true,
      maxWidth: 800,
    );

    const Rect heroRect = Rect.fromLTWH(58, 110, 784, 230);
    _drawShadowCard(canvas, heroRect, radius: 32, shadowAlpha: 0.10);
    _drawProductImage(canvas, myImg, const Rect.fromLTWH(594, 128, 220, 194), radius: 24, theme: theme);
    _drawBadge(canvas, const Rect.fromLTWH(696, 142, 96, 32), 'منتجي', theme.primaryColor, theme.accentColor, fontSize: 13);
    _drawText(canvas, text: _truncate(_productTitle(myProduct), 34), x: 558, y: 152, fontSize: 25, color: theme.primaryColor, bold: true, maxWidth: 456);
    _drawProductMetaLine(canvas, myProduct, x: 558, y: 198, theme: theme, maxWidth: 456);
    _drawPill(canvas, text: 'ده اللي عايز أبدله', cx: 356, cy: 258, bgColor: theme.softAccentColor, textColor: theme.primaryColor, maxW: 250);

    final int count = suggestions.length;
    const double baseY = 376;
    final double cardW = count <= 3 ? 234 : 172;
    final double gap = count <= 3 ? 24 : 10;
    final double totalW = cardW * count + gap * (count - 1);
    final double startX = (_canvasW - totalW) / 2;
    final List<double> angles = <double>[-0.07, 0.04, -0.035, 0.055, -0.045];

    for (int i = 0; i < count; i++) {
      final Rect card = Rect.fromLTWH(
        startX + i * (cardW + gap),
        baseY + (i.isEven ? 10 : 0),
        cardW,
        count <= 3 ? 150 : 138,
      );
      _drawStoryStackedCard(
        canvas,
        product: suggestions[i],
        image: i < sugImgs.length ? sugImgs[i] : null,
        rect: card,
        letter: _letters[i],
        angle: angles[i],
        theme: theme,
        compact: count >= 4,
      );
    }

    _drawQuestionStrip(canvas, theme, y: 568, text: theme.replyHint);
  }

  // =============================================================
  // Shared drawing blocks
  // =============================================================
  static void _drawBackground(Canvas canvas, SwapShareTheme theme) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _canvasW, _canvasH),
      Paint()..color = theme.backgroundColor,
    );

    canvas.drawCircle(
      Offset(_canvasW - 70, 70),
      160,
      Paint()..color = theme.accentColor.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      const Offset(40, 650),
      170,
      Paint()..color = theme.secondaryAccentColor.withValues(alpha: 0.14),
    );

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _canvasW, 8),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(_canvasW, 0),
          <Color>[theme.primaryColor, theme.accentColor],
        ),
    );
  }

  static void _drawTopLogo(Canvas canvas, SwapShareTheme theme, ui.Image? logoImg) {
    // لوجو أوضح وأكبر في أعلى الكارت بدون التأثير على العنوان الرئيسي.
    final RRect pill = RRect.fromRectAndRadius(
      const Rect.fromLTWH(28, 16, 196, 58),
      const Radius.circular(999),
    );



    if (logoImg != null) {
      paintImage(
        canvas: canvas,
        rect: const Rect.fromLTWH(48, 24, 156, 42),
        image: logoImg,
        fit: BoxFit.contain,
      );
      return;
    }

    _drawText(
      canvas,
      text: 'Taapdeel',
      x: 126,
      y: 34,
      fontSize: 18,
      color: _white,
      bold: true,
      center: true,
      maxWidth: 170,
    );
  }

  static void _drawMainHeader(
      Canvas canvas,
      SwapShareTheme theme,
      Product myProduct, {
        String? titleOverride,
      }) {
    final RRect pill = RRect.fromRectAndRadius(
      const Rect.fromLTWH(_padding, 54, _canvasW - _padding * 2, 70),
      const Radius.circular(24),
    );
    canvas.drawRRect(
      pill,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(_padding, 54),
          const Offset(_canvasW - _padding, 124),
          <Color>[theme.primaryColor, theme.accentColor],
        ),
    );

    _drawText(canvas, text: titleOverride ?? theme.headerTitle, x: _canvasW / 2, y: 68, fontSize: 21, color: _white, bold: true, center: true, maxWidth: 700);
    _drawText(canvas, text: 'عندي "${_truncate(_productTitle(myProduct), 32)}" وعايز أبادله', x: _canvasW / 2, y: 98, fontSize: 13, color: Colors.white.withValues(alpha: 0.88), center: true, maxWidth: 700);
  }

  static void _drawCompactHeader(Canvas canvas, SwapShareTheme theme, String hint) {
    _drawText(canvas, text: theme.headerTitle, x: 450, y: 58, fontSize: 28, color: theme.primaryColor, bold: true, center: true, maxWidth: 600);
    _drawText(canvas, text: hint, x: 450, y: 96, fontSize: 14.5, color: theme.accentColor, bold: true, center: true, maxWidth: 600);
  }

  static void _drawMiniMyProductStrip(
      Canvas canvas, {
        required Product product,
        required ui.Image? image,
        required Rect rect,
        required SwapShareTheme theme,
      }) {
    _drawShadowCard(canvas, rect, radius: 22, shadowAlpha: 0.06);
    _drawProductImage(canvas, image, Rect.fromLTWH(rect.right - 76, rect.top + 10, 68, 68), radius: 16, theme: theme);
    _drawBadge(canvas, Rect.fromLTWH(rect.left + 18, rect.top + 23, 88, 32), 'منتجي', theme.primaryColor, theme.accentColor);
    _drawText(canvas, text: _truncate(_productTitle(product), 42), x: rect.right - 94, y: rect.top + 20, fontSize: 18, color: theme.primaryColor, bold: true, maxWidth: 610);
    _drawProductMetaLine(canvas, product, x: rect.right - 94, y: rect.top + 52, theme: theme, maxWidth: 610, small: true);
  }

  static void _drawPollCard(
      Canvas canvas, {
        required Product product,
        required ui.Image? image,
        required Rect rect,
        required String letter,
        required SwapShareTheme theme,
        bool compact = false,
      }) {
    _drawShadowCard(canvas, rect, radius: 24, shadowAlpha: 0.09);
    final double imgH = compact ? rect.height * 0.54 : rect.height * 0.64;
    _drawProductImage(canvas, image, Rect.fromLTWH(rect.left + 12, rect.top + 12, rect.width - 24, imgH), radius: 18, theme: theme);
    _drawBadge(canvas, Rect.fromLTWH(rect.left + 22, rect.top + 22, 44, 36), letter, theme.primaryColor, theme.accentColor, fontSize: 19);

    final int score = _scoreOf(product);
    if (score > 0) {
      _drawBadge(canvas, Rect.fromLTWH(rect.right - 76, rect.top + 22, 52, 28), '$score%', _scoreColor(score), _scoreColor(score), fontSize: 12);
    }

    _drawText(canvas, text: _truncate(_productTitle(product), compact ? 22 : 28), x: rect.right - 18, y: rect.top + imgH + 22, fontSize: compact ? 13 : 15, color: theme.primaryColor, bold: true, maxWidth: rect.width - 36);
    _drawProductMetaLine(canvas, product, x: rect.right - 18, y: rect.top + imgH + (compact ? 47 : 52), theme: theme, maxWidth: rect.width - 36, small: true);
  }

  static void _drawBattleCard(Canvas canvas, {required Product product, required ui.Image? image, required Rect rect, required String title, required SwapShareTheme theme, bool mine = false}) {
    _drawShadowCard(canvas, rect, radius: 28, shadowAlpha: 0.11);
    _drawProductImage(canvas, image, Rect.fromLTWH(rect.left + 16, rect.top + 58, rect.width - 32, 210), radius: 22, theme: theme);
    _drawText(canvas, text: title, x: rect.left + rect.width / 2, y: rect.top + 22, fontSize: 19, color: mine ? theme.primaryColor : theme.accentColor, bold: true, center: true, maxWidth: rect.width - 40);
    _drawText(canvas, text: _truncate(_productTitle(product), 25), x: rect.right - 20, y: rect.top + 290, fontSize: 16, color: theme.primaryColor, bold: true, maxWidth: rect.width - 40);
    _drawProductMetaLine(canvas, product, x: rect.right - 20, y: rect.top + 322, theme: theme, maxWidth: rect.width - 40, small: true);
  }

  static void _drawVsCircle(Canvas canvas, Offset center, SwapShareTheme theme, {bool small = false}) {
    final double r = small ? 42 : 58;
    canvas.drawCircle(center.translate(4, 5), r, Paint()..color = Colors.black.withValues(alpha: 0.11));
    canvas.drawCircle(center, r, Paint()..shader = ui.Gradient.radial(center, r, <Color>[theme.secondaryAccentColor, theme.primaryColor]));
    _drawText(canvas, text: 'VS', x: center.dx, y: center.dy - (small ? 18 : 22), fontSize: small ? 28 : 38, color: _white, bold: true, center: true);
  }

  static void _drawSmallRunnerUp(Canvas canvas, {required Product product, required ui.Image? image, required Rect rect, required SwapShareTheme theme}) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)), Paint()..color = _white);
    _drawProductImage(canvas, image, Rect.fromLTWH(rect.right - 48, rect.top + 7, 40, 40), radius: 12, theme: theme);
    _drawText(canvas, text: 'بديل إضافي: ${_truncate(_productTitle(product), 32)}', x: rect.right - 60, y: rect.top + 17, fontSize: 14, color: theme.primaryColor, bold: true, maxWidth: rect.width - 130);
  }

  static void _drawHorizontalChoiceCard(
      Canvas canvas, {
        required Product product,
        required ui.Image? image,
        required Rect rect,
        required String letter,
        required SwapShareTheme theme,
        bool compact = false,
      }) {
    _drawShadowCard(canvas, rect, radius: 22, shadowAlpha: 0.08);
    final Rect imageRect = Rect.fromLTWH(rect.right - rect.height + 10, rect.top + 10, rect.height - 20, rect.height - 20);
    _drawProductImage(canvas, image, imageRect, radius: 16, theme: theme);
    _drawBadge(canvas, Rect.fromLTWH(rect.left + 14, rect.top + 14, 36, 32), letter, theme.accentColor, theme.secondaryAccentColor, fontSize: 16);

    final int score = _scoreOf(product);
    if (score > 0) {
      _drawBadge(canvas, Rect.fromLTWH(rect.left + 58, rect.top + 16, 62, 27), '$score%', _scoreColor(score), _scoreColor(score), fontSize: 12);
    }

    final double textRight = imageRect.left - 14;
    final double reservedLeft = rect.left + 132;
    final double textMaxW = math.max(90, textRight - reservedLeft);
    _drawText(canvas, text: _truncate(_productTitle(product), compact ? 24 : 32), x: textRight, y: rect.top + (compact ? 16 : 22), fontSize: compact ? 13 : 15, color: theme.primaryColor, bold: true, maxWidth: textMaxW);
    _drawProductMetaLine(canvas, product, x: textRight, y: rect.top + (compact ? 42 : 54), theme: theme, maxWidth: textMaxW, small: compact);
  }

  static void _drawPhoneFrame(Canvas canvas, SwapShareTheme theme) {
    final RRect phone = RRect.fromRectAndRadius(const Rect.fromLTWH(54, 24, 792, 594), const Radius.circular(34));
    canvas.drawRRect(phone, Paint()..color = _white);
    canvas.drawRRect(phone, Paint()..color = theme.primaryColor.withValues(alpha: 0.16)..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(54, 24, 792, 48), const Radius.circular(34)), Paint()..color = theme.softAccentColor);
    _drawText(canvas, text: 'استشارة تبديل', x: 450, y: 39, fontSize: 15, color: theme.primaryColor, bold: true, center: true);
  }

  static void _drawChatBubble(Canvas canvas, {required Rect rect, required String text, required SwapShareTheme theme, required bool fromMe, double fontSize = 15, bool bold = false}) {
    final Color bg = fromMe ? theme.softAccentColor : const Color(0xFFF4F7FA);
    final Color textColor = fromMe ? theme.primaryColor : const Color(0xFF233746);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)), Paint()..color = bg);
    _drawText(canvas, text: text, x: rect.right - 18, y: rect.top + 15, fontSize: fontSize, color: textColor, bold: bold, maxWidth: rect.width - 36);
  }

  static void _drawChatProductBubble(Canvas canvas, {required Rect rect, required String label, required Product product, required ui.Image? image, required SwapShareTheme theme, required bool fromMe, bool compact = false}) {
    final Color bg = fromMe ? theme.softAccentColor : const Color(0xFFF4F7FA);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(22)), Paint()..color = bg);
    final double imgSize = compact ? 44 : 62;
    _drawProductImage(canvas, image, Rect.fromLTWH(rect.right - imgSize - 12, rect.top + (rect.height - imgSize) / 2, imgSize, imgSize), radius: 14, theme: theme);
    _drawText(canvas, text: label, x: rect.right - imgSize - 26, y: rect.top + (compact ? 8 : 14), fontSize: compact ? 11 : 12, color: theme.accentColor, bold: true, maxWidth: rect.width - imgSize - 42);
    _drawText(canvas, text: _truncate(_productTitle(product), compact ? 32 : 40), x: rect.right - imgSize - 26, y: rect.top + (compact ? 27 : 38), fontSize: compact ? 13 : 15, color: theme.primaryColor, bold: true, maxWidth: rect.width - imgSize - 42);
    if (!compact) {
      _drawProductMetaLine(canvas, product, x: rect.right - imgSize - 26, y: rect.top + 68, theme: theme, maxWidth: rect.width - imgSize - 42, small: true);
    } else {
      final int score = _scoreOf(product);
      if (score > 0) _drawText(canvas, text: 'تطابق $score%', x: rect.left + 78, y: rect.top + 27, fontSize: 11, color: _scoreColor(score), bold: true, maxWidth: 80);
    }
  }

  static void _drawDecisionMyProduct(Canvas canvas, {required Product product, required ui.Image? image, required Rect rect, required SwapShareTheme theme}) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)), Paint()..color = theme.softAccentColor);
    _drawProductImage(canvas, image, Rect.fromLTWH(rect.left + 16, rect.top + 16, rect.width - 32, 178), radius: 18, theme: theme);
    _drawBadge(canvas, Rect.fromLTWH(rect.left + 24, rect.top + 26, 78, 28), 'منتجي', theme.primaryColor, theme.accentColor);
    _drawText(canvas, text: _truncate(_productTitle(product), 24), x: rect.right - 18, y: rect.top + 218, fontSize: 16, color: theme.primaryColor, bold: true, maxWidth: rect.width - 36);
    _drawProductMetaLine(canvas, product, x: rect.right - 18, y: rect.top + 252, theme: theme, maxWidth: rect.width - 36, small: true);
    _drawPill(canvas, text: 'المطلوب: رأي واضح', cx: rect.left + rect.width / 2, cy: rect.top + 296, bgColor: _white, textColor: theme.primaryColor, maxW: rect.width - 36);
  }

  static void _drawDecisionRow(Canvas canvas, {required Product product, required ui.Image? image, required Rect rect, required String letter, required SwapShareTheme theme, bool compact = false}) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)), Paint()..color = const Color(0xFFF8FBFD));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)), Paint()..color = theme.accentColor.withValues(alpha: 0.12)..style = PaintingStyle.stroke..strokeWidth = 1);
    _drawBadge(canvas, Rect.fromLTWH(rect.right - 48, rect.top + (rect.height - 32) / 2, 34, 32), letter, theme.primaryColor, theme.accentColor, fontSize: 16);
    _drawProductImage(canvas, image, Rect.fromLTWH(rect.right - 112, rect.top + 8, rect.height - 16, rect.height - 16), radius: 13, theme: theme);
    _drawText(canvas, text: _truncate(_productTitle(product), compact ? 26 : 34), x: rect.right - 128, y: rect.top + (compact ? 11 : 16), fontSize: compact ? 13 : 15, color: theme.primaryColor, bold: true, maxWidth: rect.width - 230);
    _drawProductMetaLine(canvas, product, x: rect.right - 128, y: rect.top + (compact ? 35 : 47), theme: theme, maxWidth: rect.width - 230, small: true);
    final int score = _scoreOf(product);
    if (score > 0) _drawBadge(canvas, Rect.fromLTWH(rect.left + 16, rect.top + (rect.height - 27) / 2, 64, 27), '$score%', _scoreColor(score), _scoreColor(score), fontSize: 12);
  }

  static void _drawStoryStackedCard(Canvas canvas, {required Product product, required ui.Image? image, required Rect rect, required String letter, required double angle, required SwapShareTheme theme, bool compact = false}) {
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(angle);
    final Rect local = Rect.fromCenter(center: Offset.zero, width: rect.width, height: rect.height);
    canvas.drawRRect(RRect.fromRectAndRadius(local.shift(const Offset(4, 5)), const Radius.circular(24)), Paint()..color = Colors.black.withValues(alpha: 0.12));
    canvas.drawRRect(RRect.fromRectAndRadius(local, const Radius.circular(24)), Paint()..color = _white);
    canvas.drawRRect(RRect.fromRectAndRadius(local, const Radius.circular(24)), Paint()..color = theme.accentColor.withValues(alpha: 0.18)..style = PaintingStyle.stroke..strokeWidth = 1.4);
    final double imageSize = compact ? 66 : 82;
    _drawProductImage(canvas, image, Rect.fromLTWH(local.right - imageSize - 12, local.top + 12, imageSize, imageSize), radius: 18, theme: theme);
    _drawBadge(canvas, Rect.fromLTWH(local.left + 12, local.top + 12, compact ? 42 : 48, 30), letter, theme.primaryColor, theme.accentColor, fontSize: compact ? 14 : 16);
    final int score = _scoreOf(product);
    if (score > 0) _drawBadge(canvas, Rect.fromLTWH(local.left + 12, local.top + 50, compact ? 54 : 62, 25), '$score%', _scoreColor(score), _scoreColor(score), fontSize: 11);
    _drawText(canvas, text: _truncate(_productTitle(product), compact ? 18 : 24), x: local.right - imageSize - 26, y: local.top + 20, fontSize: compact ? 12.5 : 15, color: theme.primaryColor, bold: true, maxWidth: local.width - imageSize - 92);
    _drawProductMetaLine(canvas, product, x: local.right - imageSize - 26, y: local.top + (compact ? 48 : 58), theme: theme, maxWidth: local.width - imageSize - 92, small: true);
    _drawSmartReasonBadge(canvas, product: product, rect: Rect.fromLTWH(local.left + 12, local.bottom - 34, local.width - 24, 24), theme: theme);
    canvas.restore();
  }

  static void _drawSmartReasonBadge(Canvas canvas, {required Product product, required Rect rect, required SwapShareTheme theme}) {
    final String text = _smartReason(product);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(999)), Paint()..color = theme.softAccentColor);
    _drawText(canvas, text: text, x: rect.center.dx, y: rect.top + 5, fontSize: 10.5, color: theme.primaryColor, bold: true, center: true, maxWidth: rect.width - 16);
  }

  static void _drawShadowCard(Canvas canvas, Rect rect, {double radius = 20, double shadowAlpha = 0.10}) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect.shift(const Offset(4, 5)), Radius.circular(radius)), Paint()..color = Colors.black.withValues(alpha: shadowAlpha));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()..color = _white);
  }

  static void _drawProductImage(Canvas canvas, ui.Image? image, Rect rect, {required double radius, required SwapShareTheme theme}) {
    if (image != null) {
      canvas.save();
      canvas.clipRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
      paintImage(canvas: canvas, rect: rect, image: image, fit: BoxFit.cover);
      canvas.restore();
      return;
    }
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()..color = theme.softAccentColor);
    _drawText(canvas, text: '📦', x: rect.center.dx, y: rect.center.dy - 22, fontSize: math.min(rect.width, rect.height) * 0.28, color: theme.accentColor, center: true);
  }

  static void _drawBadge(Canvas canvas, Rect rect, String text, Color c1, Color c2, {double fontSize = 12}) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(999)), Paint()..shader = ui.Gradient.linear(rect.topLeft, rect.bottomRight, <Color>[c1, c2]));
    _drawText(canvas, text: text, x: rect.center.dx, y: rect.top + (rect.height - fontSize * 1.25) / 2, fontSize: fontSize, color: _white, bold: true, center: true, maxWidth: rect.width - 4);
  }

  static void _drawQuestionStrip(Canvas canvas, SwapShareTheme theme, {required double y, required String text}) {
    final RRect rect = RRect.fromRectAndRadius(Rect.fromLTWH(70, y, 760, 46), const Radius.circular(999));
    canvas.drawRRect(rect, Paint()..shader = ui.Gradient.linear(Offset(70, y), Offset(830, y + 46), <Color>[theme.primaryColor, theme.accentColor]));
    _drawText(canvas, text: text, x: 450, y: y + 12, fontSize: 16, color: _white, bold: true, center: true, maxWidth: 700);
  }


  static void _drawFooter(Canvas canvas, SwapShareTheme theme) {
    const double y = _canvasH - 32;
    canvas.drawLine(
      const Offset(_padding, y - 12),
      const Offset(_canvasW - _padding, y - 12),
      Paint()
        ..color = theme.accentColor.withValues(alpha: 0.16)
        ..strokeWidth = 1,
    );

  }


  static void _drawProductMetaLine(Canvas canvas, Product product, {required double x, required double y, required SwapShareTheme theme, required double maxWidth, bool small = false}) {
    final String price = _productPrice(product);
    final String condition = (product.conditionOfItem?.name ?? '').trim();
    final int score = _scoreOf(product);
    final List<String> parts = <String>[
      if (price.isNotEmpty) '💰 $price',
      if (condition.isNotEmpty) '✅ $condition',
      if (score > 0) '🎯 $score%',
    ];
    _drawText(canvas, text: parts.isEmpty ? 'تفاصيل المنتج غير مكتملة' : parts.join('   '), x: x, y: y, fontSize: small ? 11 : 12, color: small ? const Color(0xFF5C7389) : theme.accentColor, bold: !small, maxWidth: maxWidth);
  }

  static void _drawPill(Canvas canvas, {required String text, required double cx, required double cy, required Color bgColor, required Color textColor, double maxW = 180}) {
    final double w = math.min(maxW, math.max(56, text.length * 8.0 + 28));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - w / 2, cy, w, 24), const Radius.circular(999)), Paint()..color = bgColor);
    _drawText(canvas, text: text, x: cx, y: cy + 5, fontSize: 11, color: textColor, center: true, bold: true, maxWidth: w - 12);
  }

  static void _drawText(Canvas canvas, {required String text, required double x, required double y, required double fontSize, required Color color, bool bold = false, bool center = false, double? maxWidth}) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: color, fontWeight: bold ? FontWeight.w900 : FontWeight.w600, fontFamily: 'Cairo', height: 1.25),
      ),
      textDirection: TextDirection.rtl,
      textAlign: center ? TextAlign.center : TextAlign.right,
      maxLines: 2,
      ellipsis: '...',
    );
    tp.layout(maxWidth: maxWidth ?? _canvasW);
    final double dx = center ? x - tp.width / 2 : x - tp.width;
    tp.paint(canvas, Offset(dx, y));
  }

  // =============================================================
  // Data helpers
  // =============================================================
  static String _productTitle(Product p) => (p.title ?? '').trim().isEmpty ? 'منتج' : (p.title ?? '').trim();

  static int _scoreOf(Product p) {
    return int.tryParse((p.swapScorePercent ?? '').toString().trim()) ?? 0;
  }

  static Color _scoreColor(int score) {
    if (score >= 70) return const Color(0xFF22C55E);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFF64748B);
  }

  static String _smartReason(Product p) {
    final int score = _scoreOf(p);
    final String condition = (p.conditionOfItem?.name ?? '').trim();
    final String city = (p.itemLocationTownship?.townshipName ?? '').trim();
    if (score >= 75) return 'أفضل توافق';
    if (city.isNotEmpty) return 'قريب من منطقتك';
    if (condition.contains('ممتاز') || condition.contains('جديد') || condition.contains('زيرو')) return 'حالته ممتازة';
    if (score >= 55) return 'اختيار قوي';
    return 'مناسب للمقارنة';
  }

  static String _productPrice(Product p) {
    final String low = (p.lowPrice ?? '').trim();
    final String high = (p.highPrice ?? '').trim();
    final String price = (p.price ?? '').trim();
    bool valid(String v) => v.isNotEmpty && v != '0' && v.toLowerCase() != 'null';
    if (valid(low) && valid(high)) {
      if (low == high) return '$low جنيه';
      return '$low - $high جنيه';
    }
    if (valid(price)) return '$price جنيه';
    if (valid(low)) return '$low جنيه';
    if (valid(high)) return '$high جنيه';
    return '';
  }

  static String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}...';
  }

  static String _buildShareText(Product myProduct, List<Product> suggestions, SwapShareTheme theme, String referralCode) {
    final StringBuffer buf = StringBuffer();

    // مهم:
    // مشاركة استشارة التبديل ليست deep link لفتح شاشة الترشيحات داخل التطبيق.
    // الترشيحات هنا محسوبة لصاحب المنتج فقط وقد لا تكون صالحة أو ظاهرة للمستلم.
    // لذلك نرسلها كاستشارة رأي داخل واتساب، ونترك الرابط كرابط عام لتجربة/تحميل Taapdeel.
    buf.writeln('🔄 *${theme.whatsAppTitle}!*');
    buf.writeln();
    buf.writeln('محتاج رأيك في قرار تبديل 👀');
    buf.writeln('عندي *${_productTitle(myProduct)}* وظهرلي كذا اختيار مناسب.');
    buf.writeln('بعتلك الصورة والاختيارات عشان تقولي تختار أنهي واحد.');
    buf.writeln();
    buf.writeln('${theme.question}');
    buf.writeln();
    buf.writeln('━━━━━━━━━━━━━━');

    for (int i = 0; i < suggestions.length; i++) {
      final Product p = suggestions[i];
      final int score = _scoreOf(p);
      final String price = _productPrice(p);
      final String city = (p.itemLocationTownship?.townshipName ?? '').trim();

      buf.writeln('${_letters[i]} - *${_productTitle(p)}*');

      if (price.isNotEmpty) {
        buf.writeln('    💰 $price');
      }

      if (city.isNotEmpty) {
        buf.writeln('    📍 $city');
      }

      if (score > 0) {
        buf.writeln('    🎯 تطابق $score%');
      }

      buf.writeln();
    }

    buf.writeln('━━━━━━━━━━━━━━');
    buf.writeln('*${theme.replyHint}* 😄');
    buf.writeln();
    buf.writeln('ملاحظة: دي استشارة رأي فقط، والاختيارات ظاهرة في الصورة المرفقة.');
    buf.writeln('لو حابب تجرب تبديل بنفسك:');
    buf.writeln(TaapdeelShareLinks.downloadWithReferral(
      referralCode: referralCode,
      source: 'swap_advice_share',
    ));

    return buf.toString();
  }
}
