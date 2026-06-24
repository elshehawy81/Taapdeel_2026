import 'package:flutter/material.dart';

class SettingFAQView extends StatefulWidget {
  const SettingFAQView({Key? key}) : super(key: key);

  @override
  State<SettingFAQView> createState() => _SettingFAQViewState();
}

class _SettingFAQViewState extends State<SettingFAQView> {
  static const Color _brandDark = Color(0xFF102236);
  static const Color _softBg = Color(0xFFF3FAFB);

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedIds = <String>{};

  String _selectedCategoryId = 'all';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqItem> get _filteredItems {
    final String normalizedQuery = _normalize(_query);

    return _faqItems.where((_FaqItem item) {
      final bool categoryMatches = _selectedCategoryId == 'all' ||
          item.categoryId == _selectedCategoryId;

      if (!categoryMatches) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      final String searchableText = _normalize(
        '${item.question} ${item.answer} ${item.bullets.join(' ')} ${item.tags.join(' ')}',
      );

      return searchableText.contains(normalizedQuery);
    }).toList();
  }

  List<_FaqItem> _itemsForCategory(String categoryId) {
    return _faqItems
        .where((_FaqItem item) => item.categoryId == categoryId)
        .toList();
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<_FaqItem> filteredItems = _filteredItems;
    final bool isSearching = _query.trim().isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _softBg,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: _softBg,
          foregroundColor: _brandDark,
          title: const Text(
            'الأسئلة المكررة',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _FaqHeroCard(),
                const SizedBox(height: 16),
                _FaqSearchBox(
                  controller: _searchController,
                  query: _query,
                  onChanged: (String value) {
                    setState(() {
                      _query = value;
                    });
                  },
                  onClear: _clearSearch,
                ),
                const SizedBox(height: 14),
                _FaqCategoryChips(
                  selectedCategoryId: _selectedCategoryId,
                  categories: _faqCategories,
                  onSelected: _selectCategory,
                ),
                const SizedBox(height: 18),
                if (isSearching)
                  _SearchResultsBlock(
                    items: filteredItems,
                    expandedIds: _expandedIds,
                    onToggle: _toggleExpanded,
                    onClear: _clearSearch,
                  )
                else if (_selectedCategoryId == 'all')
                  _AllFaqContent(
                    expandedIds: _expandedIds,
                    onToggle: _toggleExpanded,
                    onSelectCategory: _selectCategory,
                  )
                else
                  _SingleCategoryContent(
                    category: _categoryById(_selectedCategoryId),
                    items: _itemsForCategory(_selectedCategoryId),
                    expandedIds: _expandedIds,
                    onToggle: _toggleExpanded,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqHeroCard extends StatelessWidget {
  const _FaqHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 238,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0E8F65).withOpacity(0.20),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const _FaqAssetImage(
              assetPath: 'assets/images/faq/faq_hero.png',
              fallbackIcon: Icons.swap_horiz_rounded,
              fallbackColor: Color(0xFF0E8F65),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: <Color>[
                    const Color(0xFF08243A).withOpacity(0.86),
                    const Color(0xFF0E8F65).withOpacity(0.72),
                    Colors.black.withOpacity(0.10),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              top: 18,
              start: 18,
              end: 18,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.help_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'افهم تبديل بسرعة',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              start: 18,
              end: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'بدّل الحاجة اللي مش محتاجها بحاجة تنفعك',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الصفحة دي هتفهمك الفكرة، إضافة المنتجات، فرص التبديل، العائلة، الأمان والمشاركة.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class _FaqSearchBox extends StatelessWidget {
  const _FaqSearchBox({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black.withOpacity(0.045),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'ابحث: إضافة منتج، تبديل، عائلة، أمان...',
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.38),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF0E8F65),
          ),
          suffixIcon: query.trim().isEmpty
              ? null
              : IconButton(
            onPressed: onClear,
            icon: Icon(
              Icons.close_rounded,
              color: Colors.black.withOpacity(0.42),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

class _FaqCategoryChips extends StatelessWidget {
  const _FaqCategoryChips({
    required this.selectedCategoryId,
    required this.categories,
    required this.onSelected,
  });

  final String selectedCategoryId;
  final List<_FaqCategory> categories;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final _FaqCategory category = categories[index];
          final bool selected = selectedCategoryId == category.id;

          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 5),
            avatar: Icon(
              category.icon,
              size: 18,
              color: selected ? Colors.white : category.color,
            ),
            label: Text(
              category.title,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF102236),
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
            selectedColor: category.color,
            backgroundColor: Colors.white,
            side: BorderSide(
              color:
              selected ? category.color : Colors.black.withOpacity(0.06),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            onSelected: (_) => onSelected(category.id),
          );
        },
      ),
    );
  }
}

class _AllFaqContent extends StatelessWidget {
  const _AllFaqContent({
    required this.expandedIds,
    required this.onToggle,
    required this.onSelectCategory,
  });

  final Set<String> expandedIds;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final List<_FaqItem> priorityItems = _faqItems
        .where((_FaqItem item) => item.isPriority)
        .toList();

    final List<_FaqCategory> sectionCategories = _faqCategories
        .where((_FaqCategory category) => category.id != 'all')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _PriorityQuestionsBlock(
          items: priorityItems,
          expandedIds: expandedIds,
          onToggle: onToggle,
        ),
        const SizedBox(height: 18),
        const _SectionTitle(
          title: 'اختار الجزء اللي محتاج تفهمه',
          subtitle: 'كل قسم فيه أهم الأسئلة بدون كلام طويل.',
        ),
        const SizedBox(height: 10),
        for (final _FaqCategory category in sectionCategories) ...<Widget>[
          _CompactCategoryCard(
            category: category,
            questionsCount: _faqItems
                .where((_FaqItem item) => item.categoryId == category.id)
                .length,
            onTap: () => onSelectCategory(category.id),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _PriorityQuestionsBlock extends StatelessWidget {
  const _PriorityQuestionsBlock({
    required this.items,
    required this.expandedIds,
    required this.onToggle,
  });

  final List<_FaqItem> items;
  final Set<String> expandedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return _ModernPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _PanelHeader(
            icon: Icons.bolt_rounded,
            color: Color(0xFFF59E0B),
            title: 'أسئلة لازم تعرفها الأول',
            subtitle: 'مختصر سريع قبل أول تبديل.',
          ),
          const SizedBox(height: 10),
          for (final _FaqItem item in items) ...<Widget>[
            _FaqQuestionTile(
              item: item,
              category: _categoryById(item.categoryId),
              expanded: expandedIds.contains(item.id),
              onTap: () => onToggle(item.id),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SingleCategoryContent extends StatelessWidget {
  const _SingleCategoryContent({
    required this.category,
    required this.items,
    required this.expandedIds,
    required this.onToggle,
  });

  final _FaqCategory category;
  final List<_FaqItem> items;
  final Set<String> expandedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _CategoryIntroCard(category: category),
        const SizedBox(height: 14),
        for (final _FaqItem item in items) ...<Widget>[
          _FaqQuestionTile(
            item: item,
            category: category,
            expanded: expandedIds.contains(item.id),
            onTap: () => onToggle(item.id),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SearchResultsBlock extends StatelessWidget {
  const _SearchResultsBlock({
    required this.items,
    required this.expandedIds,
    required this.onToggle,
    required this.onClear,
  });

  final List<_FaqItem> items;
  final Set<String> expandedIds;
  final ValueChanged<String> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _FaqEmptyState(onClear: onClear);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ResultCountCard(count: items.length),
        const SizedBox(height: 12),
        for (final _FaqItem item in items) ...<Widget>[
          _FaqQuestionTile(
            item: item,
            category: _categoryById(item.categoryId),
            expanded: expandedIds.contains(item.id),
            onTap: () => onToggle(item.id),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ResultCountCard extends StatelessWidget {
  const _ResultCountCard({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0E8F65).withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'وجدنا $count سؤال مناسب لبحثك',
        style: const TextStyle(
          color: Color(0xFF0E8F65),
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CategoryIntroCard extends StatelessWidget {
  const _CategoryIntroCard({
    required this.category,
  });

  final _FaqCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: category.color.withOpacity(0.16),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: category.color.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _FaqAssetImage(
              assetPath: category.assetPath,
              fallbackIcon: category.icon,
              fallbackColor: category.color,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withOpacity(0.04),
                      Colors.black.withOpacity(0.12),
                      Colors.black.withOpacity(0.70),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 16,
              end: 16,
              bottom: 16,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          category.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          category.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCategoryCard extends StatelessWidget {
  const _CompactCategoryCard({
    required this.category,
    required this.questionsCount,
    required this.onTap,
  });

  final _FaqCategory category;
  final int questionsCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: category.color.withOpacity(0.13),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            height: 104,
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadiusDirectional.horizontal(
                    start: Radius.circular(24),
                  ),
                  child: SizedBox(
                    width: 104,
                    height: 104,
                    child: _FaqAssetImage(
                      assetPath: category.assetPath,
                      fallbackIcon: category.icon,
                      fallbackColor: category.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          category.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF102236),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          category.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.52),
                            fontSize: 12.5,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(end: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$questionsCount سؤال',
                    style: TextStyle(
                      color: category.color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqQuestionTile extends StatelessWidget {
  const _FaqQuestionTile({
    required this.item,
    required this.category,
    required this.expanded,
    required this.onTap,
  });

  final _FaqItem item;
  final _FaqCategory category;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: expanded
              ? category.color.withOpacity(0.30)
              : Colors.black.withOpacity(0.045),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: expanded
                ? category.color.withOpacity(0.10)
                : Colors.black.withOpacity(0.040),
            blurRadius: expanded ? 20 : 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.11),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          item.icon,
                          color: category.color,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.question,
                              style: const TextStyle(
                                color: Color(0xFF102236),
                                fontSize: 15,
                                height: 1.35,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (!expanded) ...<Widget>[
                              const SizedBox(height: 6),
                              Text(
                                item.answer,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.56),
                                  fontSize: 12.5,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: category.color,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: _QuestionExpandedBody(
                      item: item,
                      color: category.color,
                    ),
                    crossFadeState: expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                    sizeCurve: Curves.easeOutCubic,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionExpandedBody extends StatelessWidget {
  const _QuestionExpandedBody({
    required this.item,
    required this.color,
  });

  final _FaqItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 12),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.black.withOpacity(0.06),
        ),
        const SizedBox(height: 12),
        Text(
          item.answer,
          style: TextStyle(
            color: Colors.black.withOpacity(0.74),
            fontSize: 13.5,
            height: 1.55,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (item.bullets.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          for (final String bullet in item.bullets) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(top: 7),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bullet,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.62),
                      fontSize: 12.8,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ],
    );
  }
}

class _ModernPanel extends StatelessWidget {
  const _ModernPanel({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withOpacity(0.65),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
            size: 25,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF102236),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.52),
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 5,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF0E8F65),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF102236),
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.50),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqAssetImage extends StatelessWidget {
  const _FaqAssetImage({
    required this.assetPath,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  final String assetPath;
  final IconData fallbackIcon;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
          ) {
        return _ImageFallback(
          icon: fallbackIcon,
          color: fallbackColor,
        );
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(0.10),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class _FaqEmptyState extends StatelessWidget {
  const _FaqEmptyState({
    required this.onClear,
  });

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFF0E8F65).withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF0E8F65),
              size: 42,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'لم نجد سؤالًا مطابقًا',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF102236),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرّب كلمة أبسط مثل: تبديل، منتج، عائلة، أمان، واتساب، ترشيحات.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withOpacity(0.55),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onClear,
            child: const Text(
              'مسح البحث',
              style: TextStyle(
                color: Color(0xFF0E8F65),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCategory {
  const _FaqCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final IconData icon;
  final Color color;
}

class _FaqItem {
  const _FaqItem({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.answer,
    required this.icon,
    this.bullets = const <String>[],
    this.tags = const <String>[],
    this.isPriority = false,
  });

  final String id;
  final String categoryId;
  final String question;
  final String answer;
  final IconData icon;
  final List<String> bullets;
  final List<String> tags;
  final bool isPriority;
}

_FaqCategory _categoryById(String id) {
  return _faqCategories.firstWhere(
        (_FaqCategory category) => category.id == id,
    orElse: () => _faqCategories.first,
  );
}

const List<_FaqCategory> _faqCategories = <_FaqCategory>[
  _FaqCategory(
    id: 'all',
    title: 'الكل',
    subtitle: 'كل الأسئلة المهمة عن تبديل.',
    assetPath: 'assets/images/faq/faq_hero.png',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF0E8F65),
  ),
  _FaqCategory(
    id: 'start',
    title: 'ابدأ هنا',
    subtitle: 'فكرة التطبيق وطريقة استخدامه لأول مرة.',
    assetPath: 'assets/images/faq/faq_discover.png',
    icon: Icons.rocket_launch_rounded,
    color: Color(0xFF0E8F65),
  ),
  _FaqCategory(
    id: 'discover',
    title: 'اكتشف',
    subtitle: 'تصفح المنتجات والفئات والاهتمامات.',
    assetPath: 'assets/images/faq/faq_discover.png',
    icon: Icons.storefront_rounded,
    color: Color(0xFF0EA5E9),
  ),
  _FaqCategory(
    id: 'add',
    title: 'إضافة منتج',
    subtitle: 'صوّر المنتج واكتب بياناته بوضوح.',
    assetPath: 'assets/images/faq/faq_add_products.png',
    icon: Icons.add_photo_alternate_rounded,
    color: Color(0xFF2563EB),
  ),
  _FaqCategory(
    id: 'swap',
    title: 'فرص التبديل',
    subtitle: 'ترشيحات مناسبة بين منتجاتك ومنتجات الآخرين.',
    assetPath: 'assets/images/faq/faq_recommendations.png',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFFF59E0B),
  ),
  _FaqCategory(
    id: 'family',
    title: 'العائلة والثقة',
    subtitle: 'الأصدقاء والأقارب يجعلوا التبديل أسهل.',
    assetPath: 'assets/images/faq/faq_family_relation.png',
    icon: Icons.people_alt_rounded,
    color: Color(0xFF7C3AED),
  ),
  _FaqCategory(
    id: 'wish',
    title: 'منتجات مطلوبة',
    subtitle: 'اكتب الحاجة التي تحتاجها أو تتمناها.',
    assetPath: 'assets/images/faq/faq_wishlist.png',
    icon: Icons.favorite_rounded,
    color: Color(0xFFD4537E),
  ),
  _FaqCategory(
    id: 'share',
    title: 'المشاركة',
    subtitle: 'شارك المنتج أو استشير أصحابك بشكل جذاب.',
    assetPath: 'assets/images/faq/faq_share_design.png',
    icon: Icons.ios_share_rounded,
    color: Color(0xFF14B8A6),
  ),
  _FaqCategory(
    id: 'safety',
    title: 'الأمان',
    subtitle: 'نصائح مهمة قبل إتمام أي تبديل.',
    assetPath: 'assets/images/faq/faq_safety.png',
    icon: Icons.privacy_tip_rounded,
    color: Color(0xFF64748B),
  ),
];

const List<_FaqItem> _faqItems = <_FaqItem>[
  _FaqItem(
    id: 'start_1',
    categoryId: 'start',
    question: 'تبديل يعني إيه؟',
    answer:
    'تبديل هو إنك تضيف حاجة عندك مش محتاجها وتستبدلها بحاجة تانية تنفعك بدل ما تشتري جديد.',
    icon: Icons.swap_horiz_rounded,
    isPriority: true,
    tags: <String>['فكرة', 'تبديل', 'شرح'],
  ),
  _FaqItem(
    id: 'start_2',
    categoryId: 'start',
    question: 'أبدأ منين أول مرة؟',
    answer:
    'ابدأ بإضافة منتج عندك، أو أضف حاجة بتتمناها، وبعدها تابع فرص التبديل المقترحة.',
    bullets: <String>[
      'لو عندك منتج: اضغط أضف منتج.',
      'لو محتاج حاجة: أضفها في المنتجات المطلوبة.',
      'لو عايز تشوف الموجود: افتح اكتشف.',
    ],
    icon: Icons.play_circle_fill_rounded,
    isPriority: true,
    tags: <String>['ابدأ', 'أول مرة', 'استخدام'],
  ),
  _FaqItem(
    id: 'start_3',
    categoryId: 'start',
    question: 'هل التطبيق للبيع والشراء؟',
    answer:
    'لا. الفكرة الأساسية هي التبادل. السعر مجرد رقم يساعد الطرفين يفهموا قيمة المنتج ويقارنوا التبديل.',
    icon: Icons.price_change_rounded,
    isPriority: true,
    tags: <String>['بيع', 'شراء', 'سعر'],
  ),
  _FaqItem(
    id: 'discover_1',
    categoryId: 'discover',
    question: 'صفحة اكتشف بتعرض إيه؟',
    answer:
    'بتعرض منتجات المستخدمين حسب الفئات والاهتمامات، وتقدر منها تشوف منتجات مناسبة أو قريبة من احتياجك.',
    icon: Icons.storefront_rounded,
    tags: <String>['اكتشف', 'منتجات', 'فئات'],
  ),
  _FaqItem(
    id: 'discover_2',
    categoryId: 'discover',
    question: 'أستخدم الفئات ليه؟',
    answer:
    'الفئات بتساعدك توصل أسرع للمنتجات المناسبة، مثل كتب، ألعاب، إلكترونيات، رياضة أو مستلزمات البيت.',
    icon: Icons.category_rounded,
    tags: <String>['فئات', 'تصنيفات', 'بحث'],
  ),
  _FaqItem(
    id: 'add_1',
    categoryId: 'add',
    question: 'أضيف منتج إزاي؟',
    answer:
    'اضغط أضف منتج، صوّر المنتج، اكتب اسمه وحالته ووصف بسيط، وحدد السعر التقريبي لو متاح.',
    bullets: <String>[
      'استخدم صورة واضحة وحقيقية.',
      'اكتب الحالة بصدق.',
      'اذكر أي عيب أو ملاحظة مهمة.',
    ],
    icon: Icons.add_photo_alternate_rounded,
    isPriority: true,
    tags: <String>['إضافة', 'منتج', 'صورة'],
  ),
  _FaqItem(
    id: 'add_2',
    categoryId: 'add',
    question: 'هل أقدر أضيف عدة منتجات مرة واحدة؟',
    answer:
    'نعم. تقدر تصوّر مجموعة منتجات، وبعد التحليل تراجع كل منتج وتدخل بياناته قبل نشره.',
    icon: Icons.collections_rounded,
    tags: <String>['عدة منتجات', 'ذكاء اصطناعي', 'تحليل'],
  ),
  _FaqItem(
    id: 'add_3',
    categoryId: 'add',
    question: 'ليه المنتج ممكن لا يظهر فورًا؟',
    answer:
    'بعض المنتجات تحتاج مراجعة قبل الظهور للتأكد من أن الصور والوصف مناسبين وواضحين.',
    icon: Icons.verified_rounded,
    tags: <String>['مراجعة', 'منتج لا يظهر', 'موافقة'],
  ),
  _FaqItem(
    id: 'swap_1',
    categoryId: 'swap',
    question: 'فرص التبديل بتظهر بناءً على إيه؟',
    answer:
    'بناءً على منتجاتك، اهتماماتك، المنتجات المطلوبة، القيمة التقريبية، والعلاقات القريبة لو موجودة.',
    icon: Icons.auto_awesome_rounded,
    isPriority: true,
    tags: <String>['فرص', 'ترشيحات', 'تبديل'],
  ),
  _FaqItem(
    id: 'swap_2',
    categoryId: 'swap',
    question: 'يعني إيه فرصة مناسبة؟',
    answer:
    'يعني فيه احتمال جيد إن منتجك يناسب الطرف الآخر ومنتجه يناسبك. لكنها ليست إجبارية والقرار النهائي للطرفين.',
    icon: Icons.percent_rounded,
    tags: <String>['نسبة', 'فرصة', 'مناسبة'],
  ),
  _FaqItem(
    id: 'swap_3',
    categoryId: 'swap',
    question: 'أطلب التبديل إزاي؟',
    answer:
    'افتح فرصة التبديل المناسبة، راجع المنتجين، ثم اضغط اطلب التبديل أو ابدأ محادثة لو متاحة.',
    icon: Icons.send_rounded,
    tags: <String>['طلب تبديل', 'محادثة', 'قبول'],
  ),
  _FaqItem(
    id: 'swap_4',
    categoryId: 'swap',
    question: 'هل لازم أقبل أي طلب؟',
    answer:
    'لا. القبول اختياري تمامًا، ومن حقك ترفض أي طلب لا يناسبك بدون أي مشكلة.',
    icon: Icons.do_not_disturb_on_rounded,
    tags: <String>['رفض', 'قبول', 'طلب'],
  ),
  _FaqItem(
    id: 'family_1',
    categoryId: 'family',
    question: 'إيه فايدة إضافة الأصحاب أو الأقارب؟',
    answer:
    'التبديل مع ناس قريبة بيكون أسهل وأكثر ثقة، وبيخلي فرص التبادل أوضح وأسرع.',
    icon: Icons.people_alt_rounded,
    isPriority: true,
    tags: <String>['عائلة', 'أصدقاء', 'ثقة'],
  ),
  _FaqItem(
    id: 'family_2',
    categoryId: 'family',
    question: 'هل منتجاتي تظهر لكل الناس؟',
    answer:
    'حسب طريقة الظهور في التطبيق. بعض المنتجات قد تظهر للعامة، وبعضها قد يرتبط بالعائلة أو العلاقات.',
    icon: Icons.visibility_rounded,
    tags: <String>['ظهور', 'خصوصية', 'عامة'],
  ),
  _FaqItem(
    id: 'family_3',
    categoryId: 'family',
    question: 'زر واتساب يظهر إمتى؟',
    answer:
    'يفضل ظهوره مع العلاقات المباشرة مثل صديق أو قريب، لتسهيل التواصل السريع قبل التبديل.',
    icon: Icons.chat_rounded,
    tags: <String>['واتساب', 'تواصل', 'قريب'],
  ),
  _FaqItem(
    id: 'wish_1',
    categoryId: 'wish',
    question: 'يعني إيه منتج مطلوب؟',
    answer:
    'هو شيء أنت محتاجه أو بتتمناه. التطبيق يستخدمه عشان يفهم احتياجك ويرشح لك فرص أقرب.',
    icon: Icons.favorite_rounded,
    tags: <String>['مطلوب', 'أتمنى', 'احتياج'],
  ),
  _FaqItem(
    id: 'wish_2',
    categoryId: 'wish',
    question: 'هل أقدر أضيف حاجة أتمناها بدون مقابل؟',
    answer:
    'نعم، لكن فرص التبديل تكون أقوى لما يكون عندك منتجات منشورة يقدر الطرف الآخر يختار منها.',
    icon: Icons.star_rounded,
    tags: <String>['منتج أتمناه', 'مطلوب', 'بدون مقابل'],
  ),
  _FaqItem(
    id: 'share_1',
    categoryId: 'share',
    question: 'فائدة مشاركة المنتج إيه؟',
    answer:
    'المشاركة بتخلي منتجك يظهر بشكل جذاب على واتساب أو السوشيال، وده يزود فرص إن حد يهتم به.',
    icon: Icons.ios_share_rounded,
    tags: <String>['مشاركة', 'واتساب', 'سوشيال'],
  ),
  _FaqItem(
    id: 'share_2',
    categoryId: 'share',
    question: 'يعني إيه استشير أصحابك؟',
    answer:
    'تقدر تشارك كارت استشارة وتسأل أصحابك يساعدوك تختار بين منتجات أو فرص تبديل مختلفة.',
    icon: Icons.groups_rounded,
    tags: <String>['استشارة', 'أصدقاء', 'مشاركة'],
  ),
  _FaqItem(
    id: 'safety_1',
    categoryId: 'safety',
    question: 'إزاي أبدّل بأمان؟',
    answer:
    'راجع الصور، اسأل عن الحالة، اتفق بوضوح، ويفضل التبديل مع شخص موثوق أو في مكان مناسب.',
    bullets: <String>[
      'لا تتسرع في الاتفاق.',
      'اطلب صور واضحة لو محتاج.',
      'اسأل عن العيوب قبل التبديل.',
    ],
    icon: Icons.privacy_tip_rounded,
    tags: <String>['أمان', 'ثقة', 'حماية'],
  ),
  _FaqItem(
    id: 'safety_2',
    categoryId: 'safety',
    question: 'هل التطبيق يضمن جودة المنتج؟',
    answer:
    'التطبيق يساعد في العرض والترشيح، لكن التأكد النهائي من حالة المنتج مسؤولية الطرفين قبل إتمام التبديل.',
    icon: Icons.verified_user_rounded,
    tags: <String>['ضمان', 'جودة', 'مسؤولية'],
  ),
  _FaqItem(
    id: 'safety_3',
    categoryId: 'safety',
    question: 'لو المنتج مختلف عن الوصف؟',
    answer:
    'لا تكمل التبديل، ووضح المشكلة للطرف الآخر، واستخدم البلاغ أو الدعم لو متاح داخل التطبيق.',
    icon: Icons.report_problem_rounded,
    tags: <String>['بلاغ', 'مشكلة', 'وصف'],
  ),
];
