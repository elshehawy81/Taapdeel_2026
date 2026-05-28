import 'package:flutter/material.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/provider/chat/buyer_chat_history_list_provider.dart';
import 'package:taapdeel/provider/mainBuyer_provider.dart';
import 'package:taapdeel/ui/chat/list/swap_request_grouping_helper.dart';
import 'package:taapdeel/ui/chat/list/swap_request_ui_status_helper.dart';
import 'package:taapdeel/ui/chat/list/widgets/swap_requests_carousel_section.dart';
import 'package:taapdeel/ui/chat/list/widgets/swap_requests_products_picker_section.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/chat_history.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/chat_history_parameter_holder.dart';
import 'package:provider/provider.dart';

import '../enum/user_type.dart';

class ChatBuyerListView extends StatefulWidget {
  const ChatBuyerListView({
    Key? key,
    required this.animationController,
    @required this.provider,
  }) : super(key: key);

  final AnimationController? animationController;
  final BuyerChatHistoryListProvider? provider;

  @override
  _ChatBuyerListViewState createState() => _ChatBuyerListViewState(provider!);
}

class _ChatBuyerListViewState extends State<ChatBuyerListView>
    with SingleTickerProviderStateMixin {
  _ChatBuyerListViewState(this.provider);

  final ScrollController _scrollController = ScrollController();

  BuyerChatHistoryListProvider provider;
  late AnimationController animationController;
  Animation<double>? animation;

  late PsValueHolder psValueHolder;
  ChatHistoryParameterHolder? holder;

  SwapUiStatus _selectedFilter = SwapUiStatus.all;
  String? _selectedGroupKey;

  @override
  void dispose() {
    _scrollController.dispose();
    animationController.dispose();
    animation = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: PsConfig.animation_duration,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      psValueHolder = Provider.of<PsValueHolder>(context, listen: false);
      holder = ChatHistoryParameterHolder().getBuyerHistoryList();
      holder!.getBuyerHistoryList().userId = psValueHolder.loginUserId;

      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          holder!.getBuyerHistoryList().userId = psValueHolder.loginUserId;
          provider.resetShowProgress(true);
          provider.nextChatHistoryList(holder);
        }
      });

      MainBuyerProvider.of(context, listen: false).getSentList(context, provider);
      MainBuyerProvider.of(context, listen: false).resetindex();
    });
  }

  @override
  Widget build(BuildContext context) {
    psValueHolder = Provider.of<PsValueHolder>(context);
    holder ??= ChatHistoryParameterHolder().getBuyerHistoryList();
    holder!.getBuyerHistoryList().userId = psValueHolder.loginUserId;

    final List<ChatHistory> allRequests =
    MainBuyerProvider.of(context).allRequests();

    final Map<SwapUiStatus, int> filterCounts =
    SwapRequestUiStatusHelper.buildFilterCounts(
      requests: allRequests,
      userType: UserType.buyer,
    );

    final List<ChatHistory> filteredRequests =
    SwapRequestUiStatusHelper.filterRequests(
      requests: allRequests,
      userType: UserType.buyer,
      selectedFilter: _selectedFilter,
    );

    final List<GroupedSwapRequests> groupedRequests =
    SwapRequestGroupingHelper.groupRequests(
      requests: filteredRequests,
      userType: UserType.buyer,
    );

    final String? effectiveSelectedGroupKey =
    _resolveSelectedGroupKey(groupedRequests);
    final GroupedSwapRequests? selectedGroup = _findSelectedGroup(
      groupedRequests,
      effectiveSelectedGroupKey,
    );

    final List<ChatHistory> selectedRequests = selectedGroup == null
        ? <ChatHistory>[]
        : SwapRequestUiStatusHelper.sortRequestsByVisualPriority(
      requests: selectedGroup.requests,
      userType: UserType.buyer,
    );

    return Scaffold(
      backgroundColor: PsColors.baseColor,
      body: MainBuyerProvider.of(context).loading
          ? Center(
        child: CircularProgressIndicator(
          color: PsColors.activeColor,
        ),
      )
          : RefreshIndicator(
        onRefresh: () {
          provider.resetShowProgress(true);
          MainBuyerProvider.of(context, listen: false)
              .getSentList(context, provider);
          return provider.getReceivedList();
        },
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          children: <Widget>[
            _FilterSection(
              selectedFilter: _selectedFilter,
              options: SwapRequestUiStatusHelper.filterOptionsFor(
                UserType.buyer,
              ),
              counts: filterCounts,
              onSelected: (SwapUiStatus status) {
                setState(() {
                  _selectedFilter = status;
                  _selectedGroupKey = null;
                });
              },
            ),
            const SizedBox(height: 15),
            if (groupedRequests.isEmpty)
              _EmptyStateCard(
                title: 'لا توجد طلبات مرسلة',
                subtitle: _selectedFilter == SwapUiStatus.all
                    ? Utils.getString(context, 'no__items')
                    : 'لا توجد طلبات ضمن الفلتر المحدد حاليًا',
              )
            else ...<Widget>[
              SwapRequestsProductsPickerSection(
                groups: groupedRequests,
                userType: UserType.buyer,
                selectedGroupKey: effectiveSelectedGroupKey,
                title: 'المنتجات التي أرسلت بها طلبات',
                emptyText: 'لا توجد منتجات عليها طلبات ضمن هذا الفلتر',
                onSelected: (GroupedSwapRequests group) {
                  setState(() {
                    _selectedGroupKey = group.groupKey;
                  });
                },
              ),
              const SizedBox(height: 12),
              SwapRequestsCarouselSection(
                requests: selectedRequests,
                userType: UserType.buyer,
                providerB: provider,
                sectionTitle: selectedGroup == null
                    ? 'تفاصيل الطلبات'
                    : 'طلبات "${(selectedGroup.anchorProduct.title ?? '').trim().isEmpty ? 'هذا المنتج' : selectedGroup.anchorProduct.title!.trim()}"',
                emptyTitle: 'لا توجد طلبات لعرضها',
                emptySubtitle:
                'اختر منتجًا آخر من الأعلى أو جرّب تغيير الفلتر',
              ),
            ],
            if (provider.showProgress) ...<Widget>[
              const SizedBox(height: 12),
              PSProgressIndicator(provider.chatHistoryList.status),
            ],
          ],
        ),
      ),
    );
  }

  String? _resolveSelectedGroupKey(List<GroupedSwapRequests> groups) {
    if (groups.isEmpty) {
      if (_selectedGroupKey != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _selectedGroupKey = null;
          });
        });
      }
      return null;
    }

    final bool stillExists = _selectedGroupKey != null &&
        groups.any((GroupedSwapRequests g) => g.groupKey == _selectedGroupKey);

    final String resolvedKey =
    stillExists ? _selectedGroupKey! : groups.first.groupKey;

    if (_selectedGroupKey != resolvedKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedGroupKey = resolvedKey;
        });
      });
    }

    return resolvedKey;
  }

  GroupedSwapRequests? _findSelectedGroup(
      List<GroupedSwapRequests> groups,
      String? selectedKey,
      ) {
    if (groups.isEmpty || selectedKey == null) {
      return null;
    }

    for (final GroupedSwapRequests group in groups) {
      if (group.groupKey == selectedKey) {
        return group;
      }
    }
    return null;
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    Key? key,
    required this.selectedFilter,
    required this.options,
    required this.counts,
    required this.onSelected,
  }) : super(key: key);

  final SwapUiStatus selectedFilter;
  final List<SwapUiStatusOption> options;
  final Map<SwapUiStatus, int> counts;
  final ValueChanged<SwapUiStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final SwapUiStatusOption option = options[index];
          final bool isSelected = option.status == selectedFilter;
          final int count = SwapRequestUiStatusHelper.countForOption(
            option: option,
            counts: counts,
          );
          final bool isEmpty = count == 0;

          final _FilterPalette palette = _paletteFor(
            status: option.status,
            isEmpty: isEmpty,
          );

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onSelected(option.status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? palette.activeBg : palette.idleBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? palette.activeBorder : palette.idleBorder,
                  width: 1.1,
                ),
                boxShadow: isSelected && !isEmpty
                    ? <BoxShadow>[
                  BoxShadow(
                    color: palette.activeBorder.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : <BoxShadow>[],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    option.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                      isSelected ? palette.activeFg : palette.idleFg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? palette.badgeActiveBg
                          : palette.badgeIdleBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? palette.badgeActiveFg
                            : palette.badgeIdleFg,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _FilterPalette _paletteFor({
    required SwapUiStatus status,
    required bool isEmpty,
  }) {
    if (isEmpty) {
      return const _FilterPalette(
        activeBg: Color(0xFFF5F7FA),
        activeBorder: Color(0xFFD9E0E7),
        activeFg: Color(0xFF98A2B3),
        idleBg: Color(0xFFF8FAFC),
        idleBorder: Color(0xFFE4E7EC),
        idleFg: Color(0xFF98A2B3),
        badgeActiveBg: Color(0xFFECEFF3),
        badgeActiveFg: Color(0xFF98A2B3),
        badgeIdleBg: Color(0xFFECEFF3),
        badgeIdleFg: Color(0xFF98A2B3),
      );
    }

    switch (status) {
      case SwapUiStatus.all:
        return const _FilterPalette(
          activeBg: Color(0xFF18AEBB),
          activeBorder: Color(0xFF18AEBB),
          activeFg: Colors.white,
          idleBg: Colors.white,
          idleBorder: Color(0xFFD5DAE1),
          idleFg: Color(0xFF344054),
          badgeActiveBg: Color(0xFFFFFFFF),
          badgeActiveFg: Color(0xFF18AEBB),
          badgeIdleBg: Color(0xFFEAF6F8),
          badgeIdleFg: Color(0xFF0F6E76),
        );
      case SwapUiStatus.waitingYourReply:
        return const _FilterPalette(
          activeBg: Color(0xFFFFF4E5),
          activeBorder: Color(0xFFB26A00),
          activeFg: Color(0xFFB26A00),
          idleBg: Colors.white,
          idleBorder: Color(0xFFD5DAE1),
          idleFg: Color(0xFF344054),
          badgeActiveBg: Color(0xFFB26A00),
          badgeActiveFg: Colors.white,
          badgeIdleBg: Color(0xFFFFF4E5),
          badgeIdleFg: Color(0xFFB26A00),
        );
      case SwapUiStatus.waitingOtherSide:
        return const _FilterPalette(
          activeBg: Color(0xFFFFF4E5),
          activeBorder: Color(0xFFB26A00),
          activeFg: Color(0xFFB26A00),
          idleBg: Colors.white,
          idleBorder: Color(0xFFD5DAE1),
          idleFg: Color(0xFF344054),
          badgeActiveBg: Color(0xFFB26A00),
          badgeActiveFg: Colors.white,
          badgeIdleBg: Color(0xFFFFF4E5),
          badgeIdleFg: Color(0xFFB26A00),
        );
      case SwapUiStatus.inProgress:
        return const _FilterPalette(
          activeBg: Color(0xFFEAFBF1),
          activeBorder: Color(0xFF1D7A46),
          activeFg: Color(0xFF1D7A46),
          idleBg: Colors.white,
          idleBorder: Color(0xFFD5DAE1),
          idleFg: Color(0xFF344054),
          badgeActiveBg: Color(0xFF1D7A46),
          badgeActiveFg: Colors.white,
          badgeIdleBg: Color(0xFFEAFBF1),
          badgeIdleFg: Color(0xFF1D7A46),
        );
      case SwapUiStatus.completed:
        return const _FilterPalette(
          activeBg: Color(0xFFF1EDFF),
          activeBorder: Color(0xFF6941C6),
          activeFg: Color(0xFF6941C6),
          idleBg: Colors.white,
          idleBorder: Color(0xFFD5DAE1),
          idleFg: Color(0xFF344054),
          badgeActiveBg: Color(0xFF6941C6),
          badgeActiveFg: Colors.white,
          badgeIdleBg: Color(0xFFF1EDFF),
          badgeIdleFg: Color(0xFF6941C6),
        );
      case SwapUiStatus.cancelledOrRejected:
        return const _FilterPalette(
          activeBg: Color(0xFFFDECEC),
          activeBorder: Color(0xFFB42318),
          activeFg: Color(0xFFB42318),
          idleBg: Colors.white,
          idleBorder: Color(0xFFD5DAE1),
          idleFg: Color(0xFF344054),
          badgeActiveBg: Color(0xFFB42318),
          badgeActiveFg: Colors.white,
          badgeIdleBg: Color(0xFFFDECEC),
          badgeIdleFg: Color(0xFFB42318),
        );
    }
  }
}

class _FilterPalette {
  const _FilterPalette({
    required this.activeBg,
    required this.activeBorder,
    required this.activeFg,
    required this.idleBg,
    required this.idleBorder,
    required this.idleFg,
    required this.badgeActiveBg,
    required this.badgeActiveFg,
    required this.badgeIdleBg,
    required this.badgeIdleFg,
  });

  final Color activeBg;
  final Color activeBorder;
  final Color activeFg;
  final Color idleBg;
  final Color idleBorder;
  final Color idleFg;
  final Color badgeActiveBg;
  final Color badgeActiveFg;
  final Color badgeIdleBg;
  final Color badgeIdleFg;
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD7E8EE),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7FA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFD3EDF1),
              ),
            ),
            child: const Icon(
              Icons.outbox_outlined,
              color: Color(0xFF149EB7),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF163F57),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6A7F8F),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}