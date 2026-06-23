import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../wish_Items/wish_story_card_themes.dart';
import '../../wish_Items/wish_share_themes.dart';
import '../../wish_Items/wish_tag_models.dart';

import '../../item/share_theme/core/share_product_data.dart';
import '../../item/share_theme/core/share_theme_definition.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';

const Color _kNavy  = Color(0xFF043757);
const Color _kBlue  = Color(0xFF0C587A);
const Color _kTeal  = Color(0xFF24A9C4);


String resolveTaapdeelWishImageUrl(String? raw, {String imageBaseUrl = ''}) {
  String value = (raw ?? '').toString().trim();

  if (value.isEmpty || value.toLowerCase() == 'null') return '';

  value = value.replaceAll('\\', '/');

  if (value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('file://')) {
    return value;
  }

  while (value.startsWith('/')) {
    value = value.substring(1);
  }

  value = value.replaceFirst(RegExp(r'^index\.php/'), '');

  if (value.startsWith('uploads/') ||
      value.startsWith('storage/') ||
      value.startsWith('files/')) {
    return 'https://taapdeel.com/$value';
  }

  final String cleanBase = imageBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  if (cleanBase.isNotEmpty) {
    if (cleanBase.endsWith('/uploads')) {
      return '$cleanBase/$value';
    }
    return '$cleanBase/uploads/$value';
  }

  return 'https://taapdeel.com/uploads/$value';
}


// ══════════════════════════════════════════════════════════════════
//  DATA MODEL  (unchanged)
// ══════════════════════════════════════════════════════════════════

class WishCardData {
  const WishCardData({
    required this.id, required this.title, required this.hasHawadeet,
    this.imageUrl, this.hookPhrase, this.storyTitle, this.storyText,
    this.narratorComment, this.personaType = 'family', this.storyType,
    this.needReason, this.meTooCount = 0, this.userReactedMeToo = false,
    this.happenedLikeMeCount = 0, this.userReactedHappenedLikeMe = false,
    this.offerCount = 0, this.shareCount = 0, this.favouriteCount = 0, this.hawadeetStatus,
    this.catId, this.subCatId, this.storyThemeId,
    this.roleOneLabel, this.roleTwoLabel, this.dialogueOne, this.dialogueTwo,
    this.storyCardTitle,
  });

  final String id, title;
  final bool hasHawadeet;
  final String? imageUrl, hookPhrase, storyTitle, storyText, narratorComment;
  final String personaType;
  final String? storyType, needReason, hawadeetStatus, catId, subCatId;
  final String? storyThemeId, roleOneLabel, roleTwoLabel;
  final String? dialogueOne, dialogueTwo, storyCardTitle;
  final int meTooCount, happenedLikeMeCount, offerCount, shareCount, favouriteCount;
  final bool userReactedMeToo, userReactedHappenedLikeMe;

  String get effectiveStoryTitle {
    final String t = (storyCardTitle ?? storyTitle ?? '').trim();
    return t.isNotEmpty ? t : (title.trim().isEmpty ? 'حدوتة تبديل' : title.trim());
  }
  String get effectiveHook {
    final String t = (hookPhrase ?? needReason ?? '').trim();
    return t.isNotEmpty ? t : 'مش لازم نشتري جديد، يمكن نلاقيها تبديل.';
  }
  String get effectiveDialogueOne {
    final String d = (dialogueOne ?? '').trim();
    if (d.isNotEmpty) return d;
    final String l = (hookPhrase ?? '').trim();
    return l.isNotEmpty ? l : 'بدور على $title ومش عايز/ة أشتري جديد لو في فرصة تبديل.';
  }
  String get effectiveDialogueTwo {
    final String d = (dialogueTwo ?? '').trim();
    if (d.isNotEmpty) return d;
    final String l = (storyText ?? narratorComment ?? '').trim();
    return l.isNotEmpty ? l : 'جرب/ي تبديل، يمكن الحاجة موجودة عند حد ومش محتاجها.';
  }

  factory WishCardData.fromProduct(Product p) {
    final dynamic dp = p;
    String? rawHi;
    try { rawHi = dp.highlightInfo?.toString().trim(); } catch (_) {}
    if (rawHi == null || rawHi.isEmpty || rawHi == 'null') { try { rawHi = dp.highlight_info?.toString().trim(); } catch (_) {} }
    if (rawHi == null || rawHi.isEmpty || rawHi == 'null') { try { rawHi = dp.highlightInformation?.toString().trim(); } catch (_) {} }
    if (rawHi == null || rawHi.isEmpty || rawHi == 'null') { try { rawHi = dp.highlightInfomation?.toString().trim(); } catch (_) {} }
    Map<String, dynamic> hi = {};
    if (rawHi != null && rawHi.isNotEmpty && rawHi != 'null') {
      try { final dynamic d = jsonDecode(rawHi); if (d is Map) hi = Map<String, dynamic>.from(d); } catch (_) {}
    }
    String? rHi(List<String> keys) { for (final k in keys) { final v = (hi[k] ?? '').toString().trim(); if (v.isNotEmpty && v.toLowerCase() != 'null') return v; } return null; }
    String? rD(List<String> keys) {
      for (final key in keys) {
        try {
          dynamic f;
          if (key == 'storyTitle') f = dp.storyTitle; else if (key == 'story_title') f = dp.story_title;
          else if (key == 'hookPhrase') f = dp.hookPhrase; else if (key == 'hook_phrase') f = dp.hook_phrase;
          else if (key == 'storyText') f = dp.storyText; else if (key == 'story_text') f = dp.story_text;
          else if (key == 'narratorComment') f = dp.narratorComment; else if (key == 'narrator_comment') f = dp.narrator_comment;
          else if (key == 'storyType') f = dp.storyType; else if (key == 'story_type') f = dp.story_type;
          else if (key == 'personaType') f = dp.personaType; else if (key == 'persona_type') f = dp.persona_type;
          else if (key == 'needReason') f = dp.needReason; else if (key == 'need_reason') f = dp.need_reason;
          else if (key == 'meTooCount') f = dp.meTooCount; else if (key == 'me_too_count') f = dp.me_too_count;
          else if (key == 'shareCount') f = dp.shareCount; else if (key == 'share_count') f = dp.share_count;
          else if (key == 'favouriteCount') f = dp.favouriteCount; else if (key == 'favourite_count') f = dp.favourite_count;
          else if (key == 'favoriteCount') f = dp.favoriteCount; else if (key == 'favorite_count') f = dp.favorite_count;
          else if (key == 'offerCount') f = dp.offerCount; else if (key == 'offer_count') f = dp.offer_count;
          else if (key == 'hawadeetStatus') f = dp.hawadeetStatus; else if (key == 'hawadeet_status') f = dp.hawadeet_status;
          else if (key == 'userReactedMeToo') f = dp.userReactedMeToo; else if (key == 'user_reacted_me_too') f = dp.user_reacted_me_too;
          else if (key == 'storyThemeId') f = dp.storyThemeId; else if (key == 'story_theme_id') f = dp.story_theme_id;
          else if (key == 'roleOneLabel') f = dp.roleOneLabel; else if (key == 'role_one_label') f = dp.role_one_label;
          else if (key == 'roleTwoLabel') f = dp.roleTwoLabel; else if (key == 'role_two_label') f = dp.role_two_label;
          else if (key == 'dialogueOne') f = dp.dialogueOne; else if (key == 'dialogue_one') f = dp.dialogue_one;
          else if (key == 'dialogueTwo') f = dp.dialogueTwo; else if (key == 'dialogue_two') f = dp.dialogue_two;
          else if (key == 'storyCardTitle') f = dp.storyCardTitle; else if (key == 'story_card_title') f = dp.story_card_title;
          else if (key == 'happenedLikeMeCount') f = dp.happenedLikeMeCount; else if (key == 'happened_like_me_count') f = dp.happened_like_me_count;
          else if (key == 'userReactedHappenedLikeMe') f = dp.userReactedHappenedLikeMe; else if (key == 'user_reacted_happened_like_me') f = dp.user_reacted_happened_like_me;
          final String t = (f ?? '').toString().trim();
          if (t.isNotEmpty && t.toLowerCase() != 'null') return t;
        } catch (_) {}
      }
      return null;
    }
    final stT = rD(['storyTitle','story_title']) ?? rHi(['story_title','hawadeet_title']);
    final hkP = rD(['hookPhrase','hook_phrase']) ?? rHi(['hook_phrase','hookPhrase']);
    final sTx = rD(['storyText','story_text']) ?? rHi(['story_text','storyText']);
    final nrC = rD(['narratorComment','narrator_comment']) ?? rHi(['narrator_comment','narratorComment']);
    final stTy = rD(['storyType','story_type']) ?? rHi(['story_type','storyType']);
    final peTy = rD(['personaType','persona_type']) ?? rHi(['persona_type','personaType']) ?? 'family';
    final ndR = rD(['needReason','need_reason']) ?? rHi(['need_reason','needReason']);
    final hwS = rD(['hawadeetStatus','hawadeet_status']) ?? rHi(['hawadeet_status','hawadeetStatus']);
    final thId = rD(['storyThemeId','story_theme_id']) ?? rHi(['story_theme_id','theme_id']);
    final r1 = rD(['roleOneLabel','role_one_label']) ?? rHi(['role_one_label','speaker_one_label']);
    final r2 = rD(['roleTwoLabel','role_two_label']) ?? rHi(['role_two_label','speaker_two_label']);
    final d1 = rD(['dialogueOne','dialogue_one']) ?? rHi(['dialogue_one','scene_1','scene1']);
    final d2 = rD(['dialogueTwo','dialogue_two']) ?? rHi(['dialogue_two','scene_2','scene2']);
    final scTi = rD(['storyCardTitle','story_card_title']) ?? rHi(['story_card_title','card_title']);
    final meTooStr = rD(['meTooCount','me_too_count']) ?? rHi(['me_too_count','meTooCount']) ?? '0';
    final hapStr  = rD(['happenedLikeMeCount','happened_like_me_count']) ?? rHi(['happened_like_me_count','same_story_count']) ?? '0';
    final ofStr   = rD(['offerCount','offer_count']) ?? rHi(['offer_count','offerCount']) ?? '0';
    final shStr   = rD(['shareCount','share_count']) ?? rHi(['share_count','shareCount']) ?? '0';
    final favStr  = rD(['favouriteCount','favourite_count','favoriteCount','favorite_count']) ??
        rHi(['favourite_count','favorite_count','favouriteCount','favoriteCount']) ?? '0';
    final reStr   = rD(['userReactedMeToo','user_reacted_me_too']) ?? rHi(['user_reacted_me_too','userReactedMeToo']);
    final hrStr   = rD(['userReactedHappenedLikeMe','user_reacted_happened_like_me']) ?? rHi(['user_reacted_happened_like_me','userReactedHappenedLikeMe']);
    String? imgUrl;
    try { imgUrl = dp.fullPath?.toString().trim(); } catch (_) {}
    if (imgUrl == null || imgUrl.isEmpty || imgUrl == 'null') { try { imgUrl = dp.imgPath?.toString().trim(); } catch (_) {} }
    if (imgUrl == null || imgUrl.isEmpty || imgUrl == 'null') { try { imgUrl = dp.defaultPhoto?.imgPath?.toString().trim(); } catch (_) {} }
    if (imgUrl == null || imgUrl.isEmpty || imgUrl == 'null') imgUrl = null;
    String title = '';
    try { title = dp.title?.toString().trim() ?? ''; } catch (_) {}
    final bool hasH = <String?>[stT,hkP,sTx,nrC,scTi,d1,d2].any((v)=>(v??'').trim().isNotEmpty) || stTy=='official'||stTy=='user_generated'||stTy=='template';
    return WishCardData(id:(dp.id??'').toString(),title:title,imageUrl:imgUrl,hasHawadeet:hasH,hookPhrase:hkP,storyTitle:stT,storyText:sTx,narratorComment:nrC,personaType:peTy,storyType:stTy,needReason:ndR,meTooCount:int.tryParse(meTooStr)??0,userReactedMeToo:reStr=='1'||reStr=='true',happenedLikeMeCount:int.tryParse(hapStr)??0,userReactedHappenedLikeMe:hrStr=='1'||hrStr=='true',offerCount:int.tryParse(ofStr)??0,shareCount:int.tryParse(shStr)??0,favouriteCount:int.tryParse(favStr)??0,hawadeetStatus:hwS,catId:(dp.catId??'').toString(),subCatId:(dp.subCatId??'').toString(),storyThemeId:thId,roleOneLabel:r1,roleTwoLabel:r2,dialogueOne:d1,dialogueTwo:d2,storyCardTitle:scTi);
  }
}

// ══════════════════════════════════════════════════════════════════
//  CATEGORY FILTER BAR
// ══════════════════════════════════════════════════════════════════

class HawadeetCategoryFilterBar extends StatelessWidget {
  const HawadeetCategoryFilterBar({Key? key, required this.filters, required this.selectedKey, this.onSelected, this.onSelect})
      : assert(onSelected != null || onSelect != null), super(key: key);
  final List<HawadeetCategoryFilter> filters;
  final String selectedKey;
  final ValueChanged<String>? onSelected, onSelect;
  @override Widget build(BuildContext context) => SizedBox(height: 42, child: ListView.separated(padding: const EdgeInsetsDirectional.only(start: 14, end: 14, bottom: 4), scrollDirection: Axis.horizontal, itemBuilder: (_, int i) { final f = filters[i]; final sel = f.key == selectedKey; return _FilterChip(filter: f, selected: sel, onTap: () => (onSelected ?? onSelect)!(f.key)); }, separatorBuilder: (_, __) => const SizedBox(width: 8), itemCount: filters.length));
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.filter, required this.selected, required this.onTap});
  final HawadeetCategoryFilter filter; final bool selected; final VoidCallback onTap;
  static IconData _iconFor(String n) { switch (n) { case 'checkroom': return Icons.checkroom_rounded; case 'menu_book': return Icons.menu_book_rounded; case 'toys': return Icons.toys_rounded; case 'home': return Icons.home_rounded; case 'devices': return Icons.devices_rounded; case 'sports_soccer': return Icons.sports_soccer_rounded; case 'card_giftcard': return Icons.card_giftcard_rounded; default: return Icons.auto_stories_rounded; } }
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(999), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: selected ? _kBlue : Colors.white, border: Border.all(color: selected ? _kBlue : const Color(0xFFD8E4EE)), boxShadow: selected ? [BoxShadow(color: _kBlue.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 5))] : []), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_iconFor(filter.iconName), size: 15, color: selected ? Colors.white : _kBlue), const SizedBox(width: 6), Text(filter.label, style: TextStyle(color: selected ? Colors.white : _kBlue, fontWeight: FontWeight.w800, fontSize: 12))])));
}

// ══════════════════════════════════════════════════════════════════
//  VIEW MODEL  –  now carries product data directly
// ══════════════════════════════════════════════════════════════════

class _VM {
  const _VM({required this.title, required this.hook, required this.roleOne, required this.roleTwo, required this.textOne, required this.textTwo, required this.storyText, required this.meTooCount, required this.sameCount, required this.meTooActive, required this.sameActive, required this.onMeToo, required this.onSame, required this.productTitle, required this.productImageUrl, required this.imageBaseUrl, required this.onAddOffer});
  final String title, hook, roleOne, roleTwo, textOne, textTwo, storyText;
  final String productTitle; final String? productImageUrl; final String imageBaseUrl;
  final int meTooCount, sameCount;
  final bool meTooActive, sameActive;
  final VoidCallback onMeToo, onSame, onAddOffer;

  static _VM from(WishCardData d, WishStoryCardTheme t, int meToo, int same, bool meTooA, bool sameA, VoidCallback onMeToo, VoidCallback onSame, VoidCallback onAddOffer, String imageBaseUrl) => _VM(
    title: d.effectiveStoryTitle, hook: d.effectiveHook,
    roleOne: (d.roleOneLabel ?? '').trim().isNotEmpty ? d.roleOneLabel!.trim() : t.roleOne,
    roleTwo: (d.roleTwoLabel ?? '').trim().isNotEmpty ? d.roleTwoLabel!.trim() : t.roleTwo,
    textOne: d.effectiveDialogueOne, textTwo: d.effectiveDialogueTwo,
    storyText: (d.storyText ?? '').trim(),
    meTooCount: meToo, sameCount: same, meTooActive: meTooA, sameActive: sameA,
    onMeToo: onMeToo, onSame: onSame,
    productTitle: d.title, productImageUrl: d.imageUrl, imageBaseUrl: imageBaseUrl,
    onAddOffer: onAddOffer,
  );

  /// Resolved full image URL
  String? get resolvedImageUrl {
    final String resolved = resolveTaapdeelWishImageUrl(
      productImageUrl,
      imageBaseUrl: imageBaseUrl,
    );
    return resolved.isEmpty ? null : resolved;
  }
}

// ══════════════════════════════════════════════════════════════════
//  MAIN CARD WIDGET  –  collapsed by default
// ══════════════════════════════════════════════════════════════════

class HawadeetWishCard extends StatefulWidget {
  const HawadeetWishCard({Key? key, required this.data, required this.onMeToo, required this.onHaveItem, required this.onShare, required this.onAddOffer, this.imageBaseUrl = '', this.themeIndex, this.product, this.openCardId, this.onExpansionChanged, this.initiallyExpanded = false}) : super(key: key);
  final WishCardData data;
  final Product? product;
  final Future<void> Function(String id, bool reacted) onMeToo;
  final VoidCallback onHaveItem, onShare, onAddOffer;
  final String imageBaseUrl;
  final int? themeIndex;
  final String? openCardId;
  final void Function(String id, bool expanded)? onExpansionChanged;
  final bool initiallyExpanded;
  @override State<HawadeetWishCard> createState() => _CardState();
}

class _CardState extends State<HawadeetWishCard> with SingleTickerProviderStateMixin {
  late bool _meTooReacted;
  late int  _meTooCount;
  late bool _sameReacted;
  late int  _sameCount;
  bool _collapsed = true;   // ← starts COLLAPSED unless initiallyExpanded=true
  bool _narratorExpanded = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _expandAnim;

  @override void initState() {
    super.initState();
    _meTooReacted = widget.data.userReactedMeToo;
    _meTooCount   = widget.data.meTooCount;
    _sameReacted  = widget.data.userReactedHappenedLikeMe;
    _sameCount    = widget.data.favouriteCount > 0 ? widget.data.favouriteCount : widget.data.happenedLikeMeCount;
    _collapsed = !widget.initiallyExpanded;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.initiallyExpanded ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override void dispose() { _animCtrl.dispose(); super.dispose(); }

  @override
  void didUpdateWidget(covariant HawadeetWishCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.id != widget.data.id) {
      _collapsed = !widget.initiallyExpanded;
      if (widget.initiallyExpanded) {
        _animCtrl.value = 1.0;
      } else {
        _animCtrl.value = 0.0;
      }
      return;
    }

    if (!_collapsed && widget.openCardId != null && widget.openCardId != widget.data.id) {
      _collapsed = true;
      _animCtrl.reverse();
    }
  }

  void _toggleCollapse() {
    final bool willExpand = _collapsed;
    setState(() => _collapsed = !willExpand);
    if (willExpand) {
      widget.onExpansionChanged?.call(widget.data.id, true);
      _animCtrl.forward();
    } else {
      widget.onExpansionChanged?.call(widget.data.id, false);
      _animCtrl.reverse();
    }
  }

  Future<void> _handleMeToo() async {
    HapticFeedback.lightImpact();
    final prev = _meTooReacted; final pc = _meTooCount;
    setState(() { _meTooReacted = !_meTooReacted; _meTooCount += _meTooReacted ? 1 : -1; if (_meTooCount < 0) _meTooCount = 0; });
    try { await widget.onMeToo(widget.data.id, _meTooReacted); } catch (_) { if (mounted) setState(() { _meTooReacted = prev; _meTooCount = pc; }); }
  }

  void _handleSame() {
    HapticFeedback.selectionClick();
    setState(() {
      _sameReacted = !_sameReacted;
      _sameCount += _sameReacted ? 1 : -1;
      if (_sameCount < 0) _sameCount = 0;
    });
    _writeFavouriteCountToProduct(_sameCount);
  }

  void _writeFavouriteCountToProduct(int value) {
    final Product? p = widget.product;
    if (p == null) return;
    final dynamic dp = p;
    try { dp.favouriteCount = value.toString(); } catch (_) {}
    try { dp.favourite_count = value.toString(); } catch (_) {}
    try { dp.favoriteCount = value.toString(); } catch (_) {}
    try { dp.favorite_count = value.toString(); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final WishStoryCardTheme theme = WishStoryCardThemes.byId(widget.data.storyThemeId);
    final _VM vm = _VM.from(widget.data, theme, _meTooCount, _sameCount, _meTooReacted, _sameReacted, _handleMeToo, _handleSame, widget.onAddOffer, widget.imageBaseUrl);

    if (_collapsed) {
      return _WantedCollapsedWishCard(
        data: widget.data,
        vm: vm,
        theme: theme,
        onDetails: _toggleCollapse,
        onShare: widget.onShare,
        onHaveItem: widget.onHaveItem,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: theme.accent.withOpacity(0.18)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _kNavy.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Column(children: [
          GestureDetector(
            onTap: _toggleCollapse,
            child: _CollapsibleHeader(vm: vm, theme: theme, collapsed: _collapsed, imageOnRight: true),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _buildBody(vm, theme),
          ),
        ]),
      ),
    );
  }

  Widget _buildBody(_VM vm, WishStoryCardTheme theme) {
    final Widget card = _buildAttachedWishThemeBody(vm, theme);

    return Column(children: [

      card,
      if (vm.storyText.isNotEmpty) _StoryTextSection(text: vm.storyText, theme: theme),
      AnimatedSize(
        duration: const Duration(milliseconds: 220),
        child: _narratorExpanded && (widget.data.narratorComment ?? '').isNotEmpty
            ? Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: _NarratorNote(text: widget.data.narratorComment!, theme: theme),
        )
            : const SizedBox.shrink(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: _ExpandedActionBar(
          theme: theme,
          onShare: widget.onShare,
          onHaveItem: widget.onHaveItem,
          onSame: _handleSame,
          sameCount: _sameCount,
          sameActive: _sameReacted,
        ),
      ),
    ]);
  }

  Widget _buildAttachedWishThemeBody(_VM vm, WishStoryCardTheme storyTheme) {
    final ShareThemeDefinition shareTheme = _resolveAttachedWishShareTheme();
    final String imageUrl = resolveTaapdeelWishImageUrl(
      vm.resolvedImageUrl ?? widget.data.imageUrl,
      imageBaseUrl: widget.imageBaseUrl,
    );

    final ShareProductData shareData = ShareProductData.from(
      widget.product ?? _WishCardShareProduct(widget.data),
      imageUrl,
      '',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double height = (width * 1.33).clamp(390.0, 560.0);
          return SizedBox(
            width: double.infinity,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: shareTheme.builder(context, shareData),
            ),
          );
        },
      ),
    );
  }

  ShareThemeDefinition _resolveAttachedWishShareTheme() {
    final List<ShareThemeDefinition> themes = WishShareThemes.themes;
    if (themes.isEmpty) {
      throw StateError('WishShareThemes.themes is empty.');
    }

    final String storyThemeId = (widget.data.storyThemeId ?? '').trim();
    final String normalizedStoryThemeId = _normalizeThemeId(storyThemeId);

    if (normalizedStoryThemeId.isNotEmpty) {
      for (final ShareThemeDefinition theme in themes) {
        if (theme.id == storyThemeId || _normalizeThemeId(theme.id) == normalizedStoryThemeId) {
          return theme;
        }
      }
    }

    final int index = widget.themeIndex ?? 0;
    return themes[index.abs() % themes.length];
  }

  String _normalizeThemeId(String value) {
    String id = value.trim().toLowerCase();
    if (id.isEmpty || id == 'null') return '';

    while (id.startsWith('hawadeet_')) {
      id = id.substring('hawadeet_'.length);
    }
    while (id.startsWith('story_')) {
      id = id.substring('story_'.length);
    }

    return id;
  }
}

class _WishCardShareProduct extends Product {
  _WishCardShareProduct(this.data) : super();

  final WishCardData data;

  @override
  String? get id => data.id;

  @override
  String? get title => data.title;

  @override
  String? get description {
    final String text = data.storyText ?? data.narratorComment ?? data.hookPhrase ?? '';
    return text.trim().isEmpty ? null : text.trim();
  }

  String? get catId => data.catId;

  String? get subCatId => data.subCatId;
}

class _WantedCollapsedWishCard extends StatelessWidget {
  const _WantedCollapsedWishCard({
    required this.data,
    required this.vm,
    required this.theme,
    required this.onDetails,
    required this.onShare,
    required this.onHaveItem,
  });

  final WishCardData data;
  final _VM vm;
  final WishStoryCardTheme theme;
  final VoidCallback onDetails;
  final VoidCallback onShare;
  final VoidCallback onHaveItem;

  @override
  Widget build(BuildContext context) {
    final _WantedCardMeta meta = _WantedCardMeta.from(data, theme);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1EAF2)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _kNavy.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: <Color>[
                Colors.white,
                Color.lerp(Colors.white, meta.color, 0.035)!,
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _WantedThumb(vm: vm, accent: meta.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _cleanWantedTitle(vm.title, vm.productTitle),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _kNavy,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              height: 1.28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _WantedDetailsArrowButton(
                          color: meta.color,
                          onTap: onDetails,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _WantedMetaChip(meta: meta),
                    ),
                    const SizedBox(height: 10),
                    _WantedActionsRow(
                      accent: meta.color,
                      onShare: onShare,
                      onHaveItem: onHaveItem,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _cleanWantedTitle(String title, String productTitle) {
    final String value = title.trim().isNotEmpty ? title.trim() : productTitle.trim();
    if (value.isEmpty) return 'منتج مطلوب';
    return value;
  }
}

class _WantedCardMeta {
  const _WantedCardMeta({
    required this.category,
    required this.icon,
    required this.color,
    required this.timeLabel,
  });

  final String category;
  final IconData icon;
  final Color color;
  final String timeLabel;

  static _WantedCardMeta from(WishCardData data, WishStoryCardTheme theme) {
    final String title = '${data.title} ${data.effectiveStoryTitle} ${data.effectiveHook}'
        .toLowerCase();
    final String storyThemeId = (data.storyThemeId ?? '').toLowerCase();
    final String catId = (data.catId ?? '').toLowerCase();

    String category = 'طلب عام';
    IconData icon = Icons.public_rounded;
    Color color = theme.accent;

    if (_hasAny(title, <String>['عربية', 'اطفال', 'أطفال', 'سرير', 'بيبي', 'رضع', 'رضيع', 'كرسي']) ||
        storyThemeId.contains('baby') ||
        storyThemeId.contains('family') ||
        catId.contains('baby') ||
        catId.contains('child')) {
      category = 'الأم والطفل';
      icon = Icons.child_friendly_rounded;
      color = const Color(0xFF7E57C2);
    } else if (_hasAny(title, <String>['تنس', 'رياضة', 'كرة', 'جيم', 'دراجة'])) {
      category = 'الرياضة';
      icon = Icons.sports_soccer_rounded;
      color = const Color(0xFFC17812);
    } else if (_hasAny(title, <String>['فستان', 'ملابس', 'لبس', 'حذاء', 'شنطة', 'حقيبة'])) {
      category = 'الملابس';
      icon = Icons.checkroom_rounded;
      color = const Color(0xFF43A36C);
    } else if (_hasAny(title, <String>['موبايل', 'هاتف', 'لابتوب', 'كمبيوتر', 'تابلت', 'سماعة'])) {
      category = 'الإلكترونيات';
      icon = Icons.devices_rounded;
      color = const Color(0xFF1565C0);
    } else if (_hasAny(title, <String>['منزل', 'مطبخ', 'كرسي', 'ترابيزة', 'طاولة', 'كنبة'])) {
      category = 'المنزل';
      icon = Icons.home_rounded;
      color = const Color(0xFF0C7A62);
    }

    return _WantedCardMeta(
      category: category,
      icon: icon,
      color: color,
      timeLabel: 'مطلوب الآن',
    );
  }

  static bool _hasAny(String source, List<String> words) {
    for (final String word in words) {
      if (source.contains(word.toLowerCase())) return true;
    }
    return false;
  }
}

class _WantedThumb extends StatelessWidget {
  const _WantedThumb({required this.vm, required this.accent});

  final _VM vm;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = resolveTaapdeelWishImageUrl(
      vm.resolvedImageUrl ?? vm.productImageUrl,
      imageBaseUrl: vm.imageBaseUrl,
    );

    return Container(
      width: 96,
      height: 106,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl.isNotEmpty
            ? Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (_, Widget child, ImageChunkEvent? progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: accent,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _placeholder(),
        )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: accent.withOpacity(0.06),
      child: Icon(
        Icons.image_outlined,
        color: accent.withOpacity(0.42),
        size: 30,
      ),
    );
  }
}

class _WantedMetaChip extends StatelessWidget {
  const _WantedMetaChip({required this.meta});

  final _WantedCardMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: meta.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Icon(meta.icon, color: meta.color, size: 14),
          const SizedBox(width: 5),
          Text(
            '${meta.category}',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: meta.color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _WantedDetailsArrowButton extends StatelessWidget {
  const _WantedDetailsArrowButton({
    required this.color,
    required this.onTap,
  });

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'تفاصيل',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.24)),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: color,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _WantedActionsRow extends StatelessWidget {
  const _WantedActionsRow({
    required this.accent,
    required this.onShare,
    required this.onHaveItem,
  });

  final Color accent;
  final VoidCallback onShare;
  final VoidCallback onHaveItem;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: _WantedFilledButton(
            label: 'عندي المنتج',
            icon: Icons.pan_tool_alt_rounded,
            color: _kBlue,
            useGradient: false,
            backgroundColor: Colors.white,
            foregroundColor: _kBlue,
            borderColor: const Color(0xFFBFEAF0),
            onTap: onHaveItem,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: _WantedIconButton(
            label: 'شارك',
            icon: Icons.share_rounded,
            color: accent,
            onTap: onShare,
          ),
        ),
      ],
    );
  }
}

class _WantedFilledButton extends StatelessWidget {
  const _WantedFilledButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.useGradient = true,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool useGradient;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final Color effectiveForeground = foregroundColor ?? Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: useGradient ? null : (backgroundColor ?? Colors.white),
            gradient: useGradient
                ? const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: <Color>[_kNavy, _kBlue, _kTeal],
            )
                : null,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: borderColor ?? Colors.transparent,
              width: borderColor == null ? 0 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (foregroundColor ?? _kBlue).withOpacity(
                  useGradient ? 0.20 : 0.08,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Icon(icon, color: effectiveForeground, size: 15),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: effectiveForeground,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WantedIconButton extends StatelessWidget {
  const _WantedIconButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: color.withOpacity(0.36)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Icon(icon, color: color, size: 15),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollapsibleHeader extends StatelessWidget {
  const _CollapsibleHeader({
    required this.vm,
    required this.theme,
    required this.collapsed,
    required this.imageOnRight,
  });

  final _VM vm;
  final WishStoryCardTheme theme;
  final bool collapsed;
  final bool imageOnRight;

  @override
  Widget build(BuildContext context) {
    final Color accent = theme.accent;
    final Color bg = Color.lerp(Colors.white, accent, 0.045)!;
    final Widget thumb = _HeaderThumb(vm: vm, theme: theme);

    final Widget textBlock = Expanded(
      child: Column(
        crossAxisAlignment:
        imageOnRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            ' ${vm.title}',
            textDirection: TextDirection.rtl,
            textAlign: imageOnRight ? TextAlign.center : TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.titleColor,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              height: 1.8,
            ),
          ),

        ],
      ),
    );

    final List<Widget> middle = imageOnRight
        ? <Widget>[textBlock, const SizedBox(width: 10), thumb]
        : <Widget>[thumb, const SizedBox(width: 10), textBlock];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: theme.headerGradient,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: bg,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(collapsed ? 0.10 : 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(0.25)),
                ),
                child: Icon(
                  collapsed
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              ...middle,
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderThumb extends StatelessWidget {
  const _HeaderThumb({required this.vm, required this.theme});

  final _VM vm;
  final WishStoryCardTheme theme;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = resolveTaapdeelWishImageUrl(
      vm.resolvedImageUrl ?? vm.productImageUrl,
      imageBaseUrl: vm.imageBaseUrl,
    );

    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: theme.accent.withOpacity(0.32), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.accent.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: imageUrl.isNotEmpty
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _thumbPlaceholder(),
        )
            : _thumbPlaceholder(),
      ),
    );
  }

  Widget _thumbPlaceholder() {
    return Container(
      color: theme.accent.withOpacity(0.06),
      child: Icon(
        Icons.image_outlined,
        color: theme.accent.withOpacity(0.45),
        size: 24,
      ),
    );
  }
}

class _ExpandedActionBar extends StatelessWidget {
  const _ExpandedActionBar({
    required this.theme,
    required this.onShare,
    required this.onHaveItem,
    required this.onSame,
    required this.sameCount,
    required this.sameActive,
  });

  final WishStoryCardTheme theme;
  final VoidCallback onShare;
  final VoidCallback onHaveItem;
  final VoidCallback onSame;
  final int sameCount;
  final bool sameActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: _ActionBtn(
            label: 'عندي المنتج',
            icon: Icons.shopping_bag_outlined,
            bg: Colors.white,
            fg: theme.accent,
            borderColor: theme.accent.withOpacity(0.26),
            onTap: onHaveItem,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          flex: 1,
          child: _ActionBtn(
            label: 'شارك',
            icon: Icons.share_rounded,
            bg: theme.bottomPrimary,
            onTap: onShare,
          ),
        ),
      ],
    );
  }
}

class _StoryTextSection extends StatelessWidget {
  const _StoryTextSection({required this.text, required this.theme});
  final String text; final WishStoryCardTheme theme;
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: theme.accent.withOpacity(0.07),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: theme.accent.withOpacity(0.20)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text('الوصف', textDirection: TextDirection.rtl, style: TextStyle(color: theme.accent, fontSize: 11, fontWeight: FontWeight.w900)),
        const SizedBox(width: 5),
        Icon(Icons.auto_stories_rounded, size: 14, color: theme.accent),
      ]),
      const SizedBox(height: 6),
      Text(text, textDirection: TextDirection.rtl, style: TextStyle(color: theme.titleColor.withOpacity(0.85), fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.55)),
    ]),
  );
}


class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.bg,
    required this.onTap,
    this.fg = Colors.white,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final VoidCallback onTap;
  final Color fg;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          minimumSize: const Size(0, 44),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: Icon(
          icon,
          size: 15,
          color: fg,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _NarratorNote extends StatelessWidget {
  const _NarratorNote({required this.text, required this.theme});
  final String text; final WishStoryCardTheme theme;
  @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.accent.withOpacity(0.16))), child: Text(text, textDirection: TextDirection.rtl, style: TextStyle(color: theme.titleColor.withOpacity(0.85), fontWeight: FontWeight.w700, height: 1.5)));
}


class HawadeetMeTooSheet extends StatelessWidget {
  const HawadeetMeTooSheet({Key? key, required this.wishId, required this.title, required this.catId, required this.subCatId, required this.onAddWish, required this.onAddOffer, required this.onSearchCategory, required this.onShare}) : super(key: key);
  final String wishId, title; final String? catId, subCatId;
  final VoidCallback onAddWish, onAddOffer, onSearchCategory, onShare;
  static Future<void> show({required BuildContext context, required String wishId, required String title, String? catId, String? subCatId, required VoidCallback onAddWish, required VoidCallback onAddOffer, required VoidCallback onSearchCategory, required VoidCallback onShare}) => showModalBottomSheet<void>(context: context, backgroundColor: Colors.transparent, barrierColor: Colors.black.withOpacity(0.28), builder: (_) => HawadeetMeTooSheet(wishId: wishId, title: title, catId: catId, subCatId: subCatId, onAddWish: onAddWish, onAddOffer: onAddOffer, onSearchCategory: onSearchCategory, onShare: onShare));
  @override Widget build(BuildContext context) => Container(decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))), padding: const EdgeInsets.fromLTRB(20, 14, 20, 30), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 38, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.12), borderRadius: BorderRadius.circular(999))), const SizedBox(height: 16), Container(width: 58, height: 58, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_kNavy, _kTeal]), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.emoji_emotions_rounded, color: Colors.white, size: 30)), const SizedBox(height: 12), const Text('حابب تكمل؟', style: TextStyle(color: _kNavy, fontWeight: FontWeight.w900, fontSize: 20)), const SizedBox(height: 6), Text(title, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: TextStyle(color: _kBlue.withOpacity(0.72), fontWeight: FontWeight.w700)), const SizedBox(height: 18), _SheetTile(icon: Icons.add_comment_rounded, iconColor: _kBlue, title: 'احكي نفسك فى ايه', subtitle: 'ضيف طلبك بنفس الثيم اللي تحبه', onTap: () { Navigator.pop(context); onAddWish(); }), const SizedBox(height: 8), _SheetTile(icon: Icons.shopping_bag_outlined, iconColor: const Color(0xFF2E7D32), title: 'عندي المنتج المطلوب', subtitle: 'اعرضه وابدأ التبديل', onTap: () { Navigator.pop(context); onAddOffer(); }), const SizedBox(height: 8), _SheetTile(icon: Icons.search_rounded, iconColor: const Color(0xFF7E57C2), title: 'شوف منتجات قريبة', subtitle: 'ممكن تلاقي المنتج المطلوب فورًا', onTap: () { Navigator.pop(context); onSearchCategory(); }), const SizedBox(height: 8), _SheetTile(icon: Icons.share_outlined, iconColor: const Color(0xFF1565C0), title: 'شارك المنتج المطلوب', subtitle: 'يمكن حد من معارفك يكون عنده الحل', onTap: () { Navigator.pop(context); onShare(); })]));
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final Color iconColor; final String title, subtitle; final VoidCallback onTap;
  @override Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(16), onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: iconColor.withOpacity(0.06), borderRadius: BorderRadius.circular(16), border: Border.all(color: iconColor.withOpacity(0.16))), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, textDirection: TextDirection.rtl, style: const TextStyle(color: _kNavy, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(subtitle, textDirection: TextDirection.rtl, style: TextStyle(color: Colors.black.withOpacity(0.56), fontSize: 12.5))])), Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: iconColor.withOpacity(0.50))]))));
}

class WishMiniProductCard extends StatelessWidget {
  const WishMiniProductCard({Key? key, required this.data, required this.onTap, this.imageBaseUrl = ''}) : super(key: key);
  final WishCardData data; final VoidCallback onTap; final String imageBaseUrl;
  @override Widget build(BuildContext context) {
    String? url = data.imageUrl;
    if (url != null && url.isNotEmpty && !url.startsWith('http') && imageBaseUrl.isNotEmpty) url = '$imageBaseUrl/$url';
    return Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFDCE7F0)), boxShadow: [BoxShadow(color: _kNavy.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6))]), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(flex: 6, child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(18)), child: Container(color: const Color(0xFFF3F8FC), child: url != null && url.isNotEmpty ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_outlined, color: Color(0xFFBACBD8), size: 28))) : const Center(child: Icon(Icons.favorite_border_rounded, color: Color(0xFFBACBD8), size: 28))))), Padding(padding: const EdgeInsets.fromLTRB(8, 8, 8, 4), child: Text(data.title, textDirection: TextDirection.rtl, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _kNavy, fontWeight: FontWeight.w800, fontSize: 12, height: 1.3))), Padding(padding: const EdgeInsets.fromLTRB(8, 0, 8, 8), child: Text('احكي نفسك فى ايه', textDirection: TextDirection.rtl, style: TextStyle(color: _kTeal.withOpacity(0.92), fontWeight: FontWeight.w700, fontSize: 10.5)))]))));
  }
}

class WishAddButton extends StatelessWidget {
  const WishAddButton({
    Key? key,
    required this.onTap,
    this.forceVisible,
  }) : super(key: key);

  final VoidCallback onTap;

  /// Optional override from the parent page.
  /// Use it when the page already knows that the user is logged in.
  final bool? forceVisible;

  bool _validUserId(String? value) {
    final String userId = (value ?? '').trim().toLowerCase();

    return userId.isNotEmpty &&
        userId != 'null' &&
        userId != '0' &&
        userId != 'nologinuser' &&
        userId != 'no_login_user' &&
        userId != 'no_login_user_id';
  }

  bool _isLoggedIn(BuildContext context) {
    if (forceVisible != null) {
      return forceVisible!;
    }

    PsValueHolder? valueHolder;

    try {
      valueHolder = context.read<PsValueHolder>();
    } catch (_) {
      try {
        valueHolder = Provider.of<PsValueHolder>(context, listen: false);
      } catch (_) {
        valueHolder = null;
      }
    }

    if (valueHolder == null) {
      return false;
    }

    final dynamic holder = valueHolder;

    final List<String?> candidates = <String?>[
      valueHolder.loginUserId,
      _tryReadString(() => holder.userId),
      _tryReadString(() => holder.user_id),
      _tryReadString(() => holder.id),
    ];

    return candidates.any(_validUserId);
  }

  static String? _tryReadString(dynamic Function() getter) {
    try {
      final dynamic value = getter();
      return value?.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn(context)) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[_kNavy, _kBlue, _kTeal],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _kBlue.withOpacity(0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'اضف حاجه تتمناها',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

class WishSectionHeader extends StatelessWidget {
  const WishSectionHeader({Key? key, required this.totalCount, this.showCount = true}) : super(key: key);
  final int totalCount; final bool showCount;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(14, 14, 14, 8), child: const Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Text('تبديــــل ... حدوته في كل بيت', textDirection: TextDirection.rtl, style: TextStyle(color: _kNavy, fontWeight: FontWeight.w900, fontSize: 18))]))]));
}
