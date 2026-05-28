import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/ui/item/detail/product_detail_view.dart';
import 'package:taapdeel/ui/wish_Items/wish_ui_tabs_widgets.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';

class AdminPendingProductsReviewView extends StatefulWidget {
  const AdminPendingProductsReviewView({Key? key}) : super(key: key);

  @override
  State<AdminPendingProductsReviewView> createState() =>
      _AdminPendingProductsReviewViewState();
}

enum _ReviewTabType { products, wishes }

class _AdminPendingProductsReviewViewState
    extends State<AdminPendingProductsReviewView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _loading = true;
  bool _actionLoading = false;
  int _currentIndex = 0;
  _ReviewTabType _selectedTab = _ReviewTabType.products;

  List<_PendingAdminItem> _products = <_PendingAdminItem>[];
  List<_PendingAdminItem> _wishes = <_PendingAdminItem>[];

  String get _serverBase {
    String base = PsConfig.ps_app_url.trim();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    base = base.replaceFirst(RegExp(r'/index\.php/?$'), '');
    return base;
  }

  Uri _endpoint(_ReviewTabType type, String action) {
    final String controller =
    type == _ReviewTabType.products ? 'items' : 'items_wishlist';
    return Uri.parse(
      '$_serverBase/index.php/rest/$controller/$action/api_key/teampsisthebest1',
    );
  }

  List<_PendingAdminItem> get _items =>
      _selectedTab == _ReviewTabType.products ? _products : _wishes;

  String get _tabTitle =>
      _selectedTab == _ReviewTabType.products ? 'المنتجات' : 'Wish Items';

  String get _emptyTitle => _selectedTab == _ReviewTabType.products
      ? 'لا توجد منتجات في انتظار الموافقة'
      : 'لا توجد Wish Items في انتظار الموافقة';

  String get _emptySubtitle => _selectedTab == _ReviewTabType.products
      ? 'أي منتجات جديدة حالتها Pending ستظهر هنا تلقائيًا.'
      : 'أي طلبات Wish جديدة حالتها Pending ستظهر هنا تلقائيًا.';

  bool get _canGoPrevious => _items.length > 1 && _currentIndex > 0;
  bool get _canGoNext => _items.length > 1 && _currentIndex < _items.length - 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadAllPendingItems();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }

    final _ReviewTabType nextType = _tabController.index == 0
        ? _ReviewTabType.products
        : _ReviewTabType.wishes;

    if (nextType == _selectedTab) {
      return;
    }

    setState(() {
      _selectedTab = nextType;
      _currentIndex = 0;
    });
  }

  Future<void> _loadAllPendingItems() async {
    setState(() {
      _loading = true;
    });

    try {
      final List<_PendingAdminItem> products =
      await _loadPendingItems(_ReviewTabType.products);
      final List<_PendingAdminItem> wishes =
      await _loadPendingItems(_ReviewTabType.wishes);

      if (!mounted) {
        return;
      }

      setState(() {
        _products = products;
        _wishes = wishes;
        _currentIndex = 0;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[ADMIN_PENDING] load error=$e');
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء تحميل العناصر المنتظرة'),
        ),
      );
    }
  }

  Future<List<_PendingAdminItem>> _loadPendingItems(_ReviewTabType type) async {
    final PsValueHolder holder = context.read<PsValueHolder>();
    final String adminUserId = holder.loginUserId ?? '';
    final String action = type == _ReviewTabType.products
        ? 'get_pending_approval_items'
        : 'get_pending_approval_wish_items';

    final Uri url = _endpoint(type, action);
    final http.Response response = await http.post(
      url,
      body: <String, String>{
        'admin_user_id': adminUserId,
        'limit': '50',
        'offset': '0',
      },
    );

    debugPrint('[ADMIN_PENDING][$type] url=$url');
    debugPrint('[ADMIN_PENDING][$type] status=${response.statusCode}');
    debugPrint('[ADMIN_PENDING][$type] body=${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load pending $type');
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> rawList = _extractList(decoded);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map<_PendingAdminItem>(
          (Map<String, dynamic> json) => _PendingAdminItem.fromJson(json),
    )
        .where((_PendingAdminItem e) => e.id.isNotEmpty)
        .toList();
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List<dynamic>) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final dynamic data = decoded['data'] ??
          decoded['items'] ??
          decoded['result'] ??
          decoded['results'];
      if (data is List<dynamic>) {
        return data;
      }
    }

    return <dynamic>[];
  }

  Future<void> _reviewCurrentItem({required int status}) async {
    if (_items.isEmpty || _actionLoading) {
      return;
    }

    final PsValueHolder holder = context.read<PsValueHolder>();
    final String adminUserId = holder.loginUserId ?? '';
    final int reviewedIndex = _currentIndex;
    final _PendingAdminItem item = _items[reviewedIndex];
    final _ReviewTabType actionTab = _selectedTab;
    final String action = actionTab == _ReviewTabType.products
        ? 'review_pending_item'
        : 'review_pending_wish_item';
    final String idKey = actionTab == _ReviewTabType.products ? 'item_id' : 'wish_id';

    setState(() {
      _actionLoading = true;
    });

    try {
      final Uri url = _endpoint(actionTab, action);
      final http.Response response = await http.post(
        url,
        body: <String, String>{
          'admin_user_id': adminUserId,
          idKey: item.id,
          'status': status.toString(),
        },
      );

      debugPrint('[ADMIN_REVIEW][$actionTab] url=$url');
      debugPrint('[ADMIN_REVIEW][$actionTab] status=${response.statusCode}');
      debugPrint('[ADMIN_REVIEW][$actionTab] body=${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Review failed');
      }

      if (!mounted) {
        return;
      }

      final List<_PendingAdminItem> updatedItems =
      List<_PendingAdminItem>.of(_items);
      updatedItems.removeAt(reviewedIndex);

      final int nextIndex = updatedItems.isEmpty
          ? 0
          : reviewedIndex.clamp(0, updatedItems.length - 1).toInt();

      setState(() {
        if (actionTab == _ReviewTabType.products) {
          _products = updatedItems;
        } else {
          _wishes = updatedItems;
        }
        _currentIndex = nextIndex;
        _actionLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 1 ? 'تمت الموافقة بنجاح' : 'تم الرفض بنجاح'),
        ),
      );
    } catch (e) {
      debugPrint('[ADMIN_REVIEW] error=$e');
      if (!mounted) {
        return;
      }

      setState(() {
        _actionLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء تنفيذ العملية'),
        ),
      );
    }
  }

  void _goToPreviousProduct() {
    if (_actionLoading || !_canGoPrevious) {
      return;
    }

    setState(() {
      _currentIndex -= 1;
    });
  }

  void _goToNextProduct() {
    if (_actionLoading || !_canGoNext) {
      return;
    }

    setState(() {
      _currentIndex += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B2447),
        title: const Text('مراجعة العناصر'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF0C587A),
                  borderRadius: BorderRadius.circular(14),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF0B2447),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                tabs: <Widget>[
                  Tab(text: 'المنتجات (${_products.length})'),
                  Tab(text: 'Wish Items (${_wishes.length})'),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _actionLoading ? null : _loadAllPendingItems,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading ? _buildLoading() : _buildBody(context),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_items.isEmpty) {
      return _EmptyReviewState(
        title: _emptyTitle,
        subtitle: _emptySubtitle,
      );
    }

    final _PendingAdminItem item = _items[_currentIndex];
    final bool isWish = _selectedTab == _ReviewTabType.wishes;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                12,
                12,
                MediaQuery.of(context).padding.bottom + 104,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _ReviewCounterBar(
                      title: _tabTitle,
                      current: _currentIndex + 1,
                      total: _items.length,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _AdminReviewContent(
                        key: ValueKey<String>(
                          'admin_review_${isWish ? 'wish' : 'product'}_${item.id}',
                        ),
                        item: item,
                        serverBase: _serverBase,
                        isWish: isWish,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 6,
          top: 0,
          bottom: 100,
          child: Center(
            child: _SideNavButton(
              icon: Icons.chevron_left_rounded,
              enabled: !_actionLoading && _canGoNext,
              onTap: _goToNextProduct,
            ),
          ),
        ),
        Positioned(
          right: 6,
          top: 0,
          bottom: 100,
          child: Center(
            child: _SideNavButton(
              icon: Icons.chevron_right_rounded,
              enabled: !_actionLoading && _canGoPrevious,
              onTap: _goToPreviousProduct,
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: _AdminReviewActions(
            loading: _actionLoading,
            onApprove: () => _reviewCurrentItem(status: 1),
            onReject: () => _reviewCurrentItem(status: 2),
          ),
        ),
      ],
    );
  }
}

class _AdminReviewContent extends StatelessWidget {
  const _AdminReviewContent({
    Key? key,
    required this.item,
    required this.serverBase,
    required this.isWish,
  }) : super(key: key);

  final _PendingAdminItem item;
  final String serverBase;
  final bool isWish;

  @override
  Widget build(BuildContext context) {
    if (isWish) {
      return _WishAdminReviewPreview(
        item: item,
        serverBase: serverBase,
      );
    }

    return _ProductAdminReviewPreview(item: item);
  }
}

class _ProductAdminReviewPreview extends StatelessWidget {
  const _ProductAdminReviewPreview({required this.item});

  final _PendingAdminItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: Colors.white,
        child: ProductDetailView(
          productId: item.id,
          heroTagImage: 'admin_review_${item.id}_image',
          heroTagTitle: 'admin_review_${item.id}_title',
          adminReviewMode: true,
        ),
      ),
    );
  }
}

class _WishAdminReviewPreview extends StatelessWidget {
  const _WishAdminReviewPreview({
    required this.item,
    required this.serverBase,
  });

  final _PendingAdminItem item;
  final String serverBase;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HawadeetWishCard(
            key: ValueKey<String>('admin_wish_card_${item.id}'),
            data: item.toWishCardData(),
            imageBaseUrl: serverBase,
            initiallyExpanded: true,
            onMeToo: (String id, bool reacted) async {},
            onHaveItem: () {},
            onShare: () {},
            onAddOffer: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ReviewCounterBar extends StatelessWidget {
  const _ReviewCounterBar({
    required this.title,
    required this.current,
    required this.total,
  });

  final String title;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: Color(0xFF0C587A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'مراجعة $title',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0B2447),
              ),
            ),
          ),
          Text(
            '$current / $total',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0C587A),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingReviewCard extends StatefulWidget {
  const _PendingReviewCard({
    Key? key,
    required this.item,
    required this.serverBase,
    required this.isWish,
  }) : super(key: key);

  final _PendingAdminItem item;
  final String serverBase;
  final bool isWish;

  @override
  State<_PendingReviewCard> createState() => _PendingReviewCardState();
}

class _PendingReviewCardState extends State<_PendingReviewCard> {
  late final PageController _imageController;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void didUpdateWidget(covariant _PendingReviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _imageIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _imageController.hasClients) {
          _imageController.jumpToPage(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  String _absoluteImageUrl(String path) {
    final String value = path.trim();
    if (value.isEmpty) {
      return '';
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final String cleanPath = value.startsWith('/') ? value.substring(1) : value;
    return '${widget.serverBase}/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = widget.item.images
        .map(_absoluteImageUrl)
        .where((String e) => e.isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: AspectRatio(
              aspectRatio: 1.05,
              child: imageUrls.isEmpty
                  ? const _NoImageBox()
                  : Stack(
                children: <Widget>[
                  PageView.builder(
                    controller: _imageController,
                    itemCount: imageUrls.length,
                    physics: const ClampingScrollPhysics(),
                    onPageChanged: (int index) {
                      setState(() {
                        _imageIndex = index;
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _NoImageBox(),
                        loadingBuilder: (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                            ) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      );
                    },
                  ),
                  if (imageUrls.length > 1)
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${_imageIndex + 1} / ${imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.item.title.isEmpty ? 'بدون عنوان' : widget.item.title,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.25,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0B2447),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TypeBadge(isWish: widget.isWish),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _InfoChip(icon: Icons.tag_rounded, label: 'ID: ${widget.item.id}'),
                    if (widget.item.addedUserId.isNotEmpty)
                      _InfoChip(
                        icon: Icons.person_rounded,
                        label: 'User: ${widget.item.addedUserId}',
                      ),
                    if (widget.item.price.isNotEmpty)
                      _InfoChip(
                        icon: Icons.payments_rounded,
                        label: widget.item.price,
                      ),
                    if (widget.item.locationText.isNotEmpty)
                      _InfoChip(
                        icon: Icons.location_on_rounded,
                        label: widget.item.locationText,
                      ),
                  ],
                ),
                if (widget.item.description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  const Text(
                    'الوصف',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0C587A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.item.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isWish});

  final bool isWish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isWish ? const Color(0xFFFFF4E5) : const Color(0xFFEAF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isWish ? 'Wish' : 'Product',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: isWish ? const Color(0xFF9A3412) : const Color(0xFF0C587A),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2EAF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: const Color(0xFF0C587A)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF243B53),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoImageBox extends StatelessWidget {
  const _NoImageBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEAF6FF),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          color: Color(0xFF0C587A),
          size: 42,
        ),
      ),
    );
  }
}

class _EmptyReviewState extends StatelessWidget {
  const _EmptyReviewState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF0C587A),
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0B2447),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideNavButton extends StatelessWidget {
  const _SideNavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.28,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 42,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.94),
              borderRadius: BorderRadius.circular(18),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0B2447),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminReviewActions extends StatelessWidget {
  const _AdminReviewActions({
    required this.loading,
    required this.onApprove,
    required this.onReject,
  });

  final bool loading;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: loading ? null : onApprove,
                icon: loading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.check_circle_rounded),
                label: const Text('موافقة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C587A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: loading ? null : onReject,
                icon: const Icon(Icons.close_rounded),
                label: const Text('رفض'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9A3412),
                  side: const BorderSide(
                    color: Color(0xFFF3C7A7),
                    width: 1.2,
                  ),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingAdminItem {
  const _PendingAdminItem({
    required this.id,
    required this.title,
    required this.images,
    required this.description,
    required this.price,
    required this.addedUserId,
    required this.locationText,
    this.catId = '',
    this.subCatId = '',
    this.hookPhrase = '',
    this.storyTitle = '',
    this.storyText = '',
    this.narratorComment = '',
    this.personaType = 'family',
    this.storyType = '',
    this.needReason = '',
    this.hawadeetStatus = '',
    this.storyThemeId = '',
    this.roleOneLabel = '',
    this.roleTwoLabel = '',
    this.dialogueOne = '',
    this.dialogueTwo = '',
    this.storyCardTitle = '',
    this.meTooCount = 0,
    this.happenedLikeMeCount = 0,
    this.offerCount = 0,
    this.shareCount = 0,
    this.favouriteCount = 0,
    this.userReactedMeToo = false,
    this.userReactedHappenedLikeMe = false,
  });

  final String id;
  final String title;
  final List<String> images;
  final String description;
  final String price;
  final String addedUserId;
  final String locationText;

  final String catId;
  final String subCatId;
  final String hookPhrase;
  final String storyTitle;
  final String storyText;
  final String narratorComment;
  final String personaType;
  final String storyType;
  final String needReason;
  final String hawadeetStatus;
  final String storyThemeId;
  final String roleOneLabel;
  final String roleTwoLabel;
  final String dialogueOne;
  final String dialogueTwo;
  final String storyCardTitle;
  final int meTooCount;
  final int happenedLikeMeCount;
  final int offerCount;
  final int shareCount;
  final int favouriteCount;
  final bool userReactedMeToo;
  final bool userReactedHappenedLikeMe;

  String get primaryImage => images.isEmpty ? '' : images.first;

  bool get hasHawadeet {
    return <String>[
      storyTitle,
      hookPhrase,
      storyText,
      narratorComment,
      storyCardTitle,
      dialogueOne,
      dialogueTwo,
    ].any((String e) => e.trim().isNotEmpty) ||
        storyType == 'official' ||
        storyType == 'user_generated' ||
        storyType == 'template';
  }

  WishCardData toWishCardData() {
    final String fallbackStoryText = storyText.trim().isNotEmpty
        ? storyText.trim()
        : description.trim();

    return WishCardData(
      id: id,
      title: title.trim().isEmpty ? 'منتج مطلوب' : title.trim(),
      imageUrl: primaryImage,
      hasHawadeet: hasHawadeet || fallbackStoryText.isNotEmpty,
      hookPhrase: hookPhrase.trim().isEmpty ? null : hookPhrase.trim(),
      storyTitle: storyTitle.trim().isEmpty ? null : storyTitle.trim(),
      storyText: fallbackStoryText.isEmpty ? null : fallbackStoryText,
      narratorComment:
      narratorComment.trim().isEmpty ? null : narratorComment.trim(),
      personaType: personaType.trim().isEmpty ? 'family' : personaType.trim(),
      storyType: storyType.trim().isEmpty ? null : storyType.trim(),
      needReason: needReason.trim().isEmpty ? null : needReason.trim(),
      hawadeetStatus:
      hawadeetStatus.trim().isEmpty ? null : hawadeetStatus.trim(),
      catId: catId.trim().isEmpty ? null : catId.trim(),
      subCatId: subCatId.trim().isEmpty ? null : subCatId.trim(),
      storyThemeId: storyThemeId.trim().isEmpty ? null : storyThemeId.trim(),
      roleOneLabel: roleOneLabel.trim().isEmpty ? null : roleOneLabel.trim(),
      roleTwoLabel: roleTwoLabel.trim().isEmpty ? null : roleTwoLabel.trim(),
      dialogueOne: dialogueOne.trim().isEmpty ? null : dialogueOne.trim(),
      dialogueTwo: dialogueTwo.trim().isEmpty ? null : dialogueTwo.trim(),
      storyCardTitle:
      storyCardTitle.trim().isEmpty ? null : storyCardTitle.trim(),
      meTooCount: meTooCount,
      happenedLikeMeCount: happenedLikeMeCount,
      offerCount: offerCount,
      shareCount: shareCount,
      favouriteCount: favouriteCount,
      userReactedMeToo: userReactedMeToo,
      userReactedHappenedLikeMe: userReactedHappenedLikeMe,
    );
  }

  factory _PendingAdminItem.fromJson(Map<String, dynamic> json) {
    final List<String> images = <String>[];

    void addImage(dynamic value) {
      final String path = value?.toString().trim() ?? '';
      if (path.isNotEmpty && path.toLowerCase() != 'null' && !images.contains(path)) {
        images.add(path);
      }
    }

    final dynamic defaultPhoto = json['default_photo'];
    if (defaultPhoto is Map<String, dynamic>) {
      addImage(defaultPhoto['img_path']);
    }

    final dynamic rawImages = json['images'];
    if (rawImages is List<dynamic>) {
      for (final dynamic image in rawImages) {
        if (image is Map<String, dynamic>) {
          addImage(image['img_path']);
        } else {
          addImage(image);
        }
      }
    }

    addImage(json['default_photo_img_path']);
    addImage(json['img_path']);
    addImage(json['image']);

    final String lowPrice = _readString(json, <String>['low_price', 'min_price']);
    final String highPrice = _readString(json, <String>['high_price', 'max_price']);
    final String rawPrice = _readString(json, <String>['price']);
    final String price = rawPrice.isNotEmpty
        ? rawPrice
        : (lowPrice.isNotEmpty || highPrice.isNotEmpty)
        ? '$lowPrice - $highPrice'
        : '';

    final String township = _readString(
      json,
      <String>['item_location_township', 'township_name', 'township'],
    );
    final String city = _readString(
      json,
      <String>['item_location', 'city_name', 'city'],
    );
    final String locationText = <String>[township, city]
        .where((String e) => e.trim().isNotEmpty)
        .join(' - ');

    final String storyText = _readString(
      json,
      <String>['story_text', 'storyText'],
    );

    return _PendingAdminItem(
      id: _readString(json, <String>['id', 'item_id', 'wish_id']),
      title: _readString(json, <String>['title', 'story_title', 'storyCardTitle']),
      images: images,
      description: _readString(
        json,
        <String>['description', 'deal_option_remark', 'story_text'],
      ),
      price: price,
      addedUserId: _readString(json, <String>['added_user_id', 'user_id']),
      locationText: locationText,
      catId: _readString(json, <String>['cat_id', 'category_id']),
      subCatId: _readString(json, <String>['sub_cat_id', 'subcat_id', 'subcategory_id']),
      hookPhrase: _readString(json, <String>['hook_phrase', 'hookPhrase']),
      storyTitle: _readString(json, <String>['story_title', 'storyTitle']),
      storyText: storyText,
      narratorComment: _readString(
        json,
        <String>['narrator_comment', 'narratorComment'],
      ),
      personaType: _readString(json, <String>['persona_type', 'personaType']),
      storyType: _readString(json, <String>['story_type', 'storyType']),
      needReason: _readString(json, <String>['need_reason', 'needReason']),
      hawadeetStatus: _readString(
        json,
        <String>['hawadeet_status', 'hawadeetStatus'],
      ),
      storyThemeId: _readString(
        json,
        <String>['story_theme_id', 'storyThemeId', 'theme_id'],
      ),
      roleOneLabel: _readString(
        json,
        <String>['role_one_label', 'roleOneLabel', 'speaker_one_label'],
      ),
      roleTwoLabel: _readString(
        json,
        <String>['role_two_label', 'roleTwoLabel', 'speaker_two_label'],
      ),
      dialogueOne: _readString(
        json,
        <String>['dialogue_one', 'dialogueOne', 'scene_1', 'scene1'],
      ),
      dialogueTwo: _readString(
        json,
        <String>['dialogue_two', 'dialogueTwo', 'scene_2', 'scene2'],
      ),
      storyCardTitle: _readString(
        json,
        <String>['story_card_title', 'storyCardTitle', 'card_title'],
      ),
      meTooCount: _readInt(json, <String>['me_too_count', 'meTooCount']),
      happenedLikeMeCount: _readInt(
        json,
        <String>['happened_like_me_count', 'happenedLikeMeCount', 'same_story_count'],
      ),
      offerCount: _readInt(json, <String>['offer_count', 'offerCount']),
      shareCount: _readInt(json, <String>['share_count', 'shareCount']),
      favouriteCount: _readInt(
        json,
        <String>['favourite_count', 'favorite_count', 'favouriteCount', 'favoriteCount'],
      ),
      userReactedMeToo: _readBool(
        json,
        <String>['user_reacted_me_too', 'userReactedMeToo'],
      ),
      userReactedHappenedLikeMe: _readBool(
        json,
        <String>['user_reacted_happened_like_me', 'userReactedHappenedLikeMe'],
      ),
    );
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      final String text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return '';
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    final String value = _readString(json, keys);
    return int.tryParse(value) ?? 0;
  }

  static bool _readBool(Map<String, dynamic> json, List<String> keys) {
    final String value = _readString(json, keys).toLowerCase();
    return value == '1' || value == 'true' || value == 'yes';
  }
}
