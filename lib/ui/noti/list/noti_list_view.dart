import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/repository/noti_repository.dart';
import 'package:taapdeel/ui/common/base/ps_widget_with_appbar_no_app_bar_title.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/noti_parameter_holder.dart';
import 'package:provider/provider.dart';

import '../../../provider/noti/noti_provider.dart';
import '../../../viewobject/noti.dart';
import '../item/noti_list_item.dart';
import '../notification_routing_helper.dart';

class NotiListView extends StatefulWidget {
  @override
  _NotiListViewState createState() => _NotiListViewState();
}

class _NotiListViewState extends State<NotiListView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late NotiProvider _notiProvider;
  AnimationController? animationController;

  NotiRepository? repo1;
  PsValueHolder? psValueHolder;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: PsConfig.animation_duration, vsync: this);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final String? loginUserId = Utils.checkUserLoginId(psValueHolder!);
        final GetNotiParameterHolder holder = GetNotiParameterHolder(
          userId: loginUserId,
          deviceToken: _notiProvider.psValueHolder!.deviceToken,
        );
        _notiProvider.nextNotiList(holder.toMap());
      }
    });
  }

  @override
  void dispose() {
    animationController!.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _requestPop() {
    animationController!.reverse().then<dynamic>((void data) {
      if (!mounted) return Future<bool>.value(false);
      Navigator.pop(context, true);
      return Future<bool>.value(true);
    });
    return Future<bool>.value(false);
  }

  // ── Routing based on notification type ───────────────────────────────────
  Future<void> _handleNotiTap(BuildContext context, Noti noti) async {
    await _notiProvider.markRead(noti);

    // Type-based notifications → route directly
    if (noti.notiType != null && noti.notiType!.isNotEmpty) {
      NotificationRoutingHelper.navigateFromNoti(
        context: context,
        noti: noti,
      );
      return;
    }

    // Legacy broadcast notifications → detail view (existing behaviour)
    final dynamic returnData = await Navigator.pushNamed(
      context,
      RoutePaths.noti,
      arguments: noti,
    );

    if (returnData != null && returnData is PsValueHolder) {
      final String? loginUserId = Utils.checkUserLoginId(psValueHolder!);
      final GetNotiParameterHolder holder = GetNotiParameterHolder(
        userId: loginUserId,
        deviceToken: _notiProvider.psValueHolder!.deviceToken,
      );
      _notiProvider.resetNotiList(holder.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    repo1 = Provider.of<NotiRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    return WillPopScope(
      onWillPop: _requestPop,
      child: PsWidgetWithAppBarNoAppBarTitle<NotiProvider>(
        initProvider: () => NotiProvider(
          repo: repo1,
          psValueHolder: psValueHolder,
          limit: 30,
        ),
        onProviderReady: (NotiProvider provider) {
          final String? loginUserId = Utils.checkUserLoginId(psValueHolder!);
          final GetNotiParameterHolder holder = GetNotiParameterHolder(
            userId: loginUserId,
            deviceToken: provider.psValueHolder!.deviceToken,
          );
          provider.getNotiList(holder.toMap());
          provider.loadUnreadCount();
          _notiProvider = provider;
        },
        builder: (BuildContext context, NotiProvider provider, Widget? child) {
          final bool hasData = provider.notiList.data != null &&
              provider.notiList.data!.isNotEmpty;

          return Container(
            color: PsColors.baseColor,
            child: hasData
                ? _buildList(context, provider)
                : _buildEmptyState(context, provider),
          );
        },
      ),
    );
  }

  // ── List ─────────────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context, NotiProvider provider) {
    return Column(
      children: [
        // Mark all read button (only if there are unread items)
        if (provider.hasUnread)
          _MarkAllReadButton(
            onTap: () => provider.markAllRead(),
          ),

        Expanded(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  final GetNotiParameterHolder holder = GetNotiParameterHolder(
                    userId: provider.psValueHolder!.loginUserId,
                    deviceToken: provider.psValueHolder!.deviceToken,
                  );
                  return provider.resetNotiList(holder.toMap());
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemCount: provider.notiList.data!.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final int count = provider.notiList.data!.length;
                    final Noti noti = provider.notiList.data![index];
                    return NotiListItem(
                      animationController: animationController,
                      animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animationController!,
                          curve: Interval(
                            (1 / count) * index,
                            1.0,
                            curve: Curves.fastOutSlowIn,
                          ),
                        ),
                      ),
                      noti: noti,
                      onTap: () => _handleNotiTap(context, noti),
                    );
                  },
                ),
              ),
              PSProgressIndicator(provider.notiList.status),
            ],
          ),
        ),
      ],
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, NotiProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
            ),
            const SizedBox(height: 16),
            Text(
              Utils.getString(context, 'noti_list__no_notifications'),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.45),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                final String? loginUserId =
                Utils.checkUserLoginId(psValueHolder!);
                final GetNotiParameterHolder holder = GetNotiParameterHolder(
                  userId: loginUserId,
                  deviceToken: provider.psValueHolder!.deviceToken,
                );
                provider.getNotiList(holder.toMap());
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(Utils.getString(context, 'app__refresh')),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mark all read button ──────────────────────────────────────────────────────
class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: PsColors.baseColor,
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            Utils.getString(context, 'noti_list__mark_all_read'),
            style: TextStyle(
              fontSize: 13,
              color: PsColors.primary500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
