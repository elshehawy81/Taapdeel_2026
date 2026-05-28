import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/dialog/confirm_dialog_view.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/delete_user_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/item_list_intent_holder.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shimmer/shimmer.dart';

import '../../../api/common/ps_status.dart';
import '../../../provider/package_bought/package_bought_transaction_provider.dart';
import '../../../repository/package_bought_transaction_history_repository.dart';
import '../../../viewobject/holder/package_transaction_holder.dart';
import '../../common/ps_frame_loading_widget.dart';
import '../../common/taapdeel/taapdeel_info_card_shell.dart';

// ✅ NEW: Unified Scaffold
import '../../common/taapdeel/taapdeel_scaffold.dart';

class MoreView extends StatefulWidget {
  const MoreView({
    Key? key,
    required this.animationController,
    required this.closeMoreContainerView,
  }) : super(key: key);

  final AnimationController? animationController;
  final Function closeMoreContainerView;

  @override
  _MoreViewState createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  bool isConnectedToInternet = false;

  PsValueHolder? valueHolder;
  UserProvider? userProvider;
  UserRepository? userRepository;
  PackageTranscationHistoryProvider? packageTranscationHistoryProvider;

  @override
  void initState() {
    super.initState();

    // ✅ Forward animation مرة واحدة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.animationController?.forward();
    });

    // ✅ checkConnection خارج build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    final bool onValue = await Utils.checkInternetConnectivity();
    if (!mounted) return;
    setState(() {
      isConnectedToInternet = onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;

    userRepository = Provider.of<UserRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);

    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
      parent: widget.animationController!,
      curve: const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn),
    ));

    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<UserProvider>(
          lazy: false,
          create: (BuildContext context) {
            userProvider =
                UserProvider(repo: userRepository, psValueHolder: valueHolder);
            return userProvider!;
          },
        ),

        // ✅ IMPORTANT: Provider ده كان ناقص وبيسبب ProviderNotFoundException
        ChangeNotifierProvider<PackageTranscationHistoryProvider>(
          lazy: false,
          create: (BuildContext context) {
            final PsValueHolder vh =
            Provider.of<PsValueHolder>(context, listen: false);

            final PackageTranscationHistoryRepository repo =
            Provider.of<PackageTranscationHistoryRepository>(context,
                listen: false);

            packageTranscationHistoryProvider =
                PackageTranscationHistoryProvider(
                  repo: repo,
                  psValueHolder: vh,
                );

            // ✅ لو Guest أو loginUserId فاضي: متعملش load
            final String? uid = vh.loginUserId;
            if (uid != null && uid.isNotEmpty) {
              final PackgageBoughtTransactionParameterHolder holder =
              PackgageBoughtTransactionParameterHolder(userId: uid);

              packageTranscationHistoryProvider!
                  .loadBuyAdTransactionList(holder);
            }

            return packageTranscationHistoryProvider!;
          },
        ),
      ],
      child: Consumer<UserProvider>(
        builder:
            (BuildContext context, UserProvider userProvider, Widget? child) {
          final String? uid = userProvider.psValueHolder?.loginUserId;

          // ✅ Unified UI wrapper
          return TaapdeelScaffold(
            // مهم جداً: عشان الكروت عندك فيها margin 16 already
            padding: EdgeInsets.zero,
            safeTop: true,
            safeBottom: true,

            body: AnimatedBuilder(
              animation: widget.animationController!,
              builder: (BuildContext context, Widget? _) {
                return FadeTransition(
                  opacity: animation,
                  child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 100 * (1.0 - animation.value), 0.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          // ===================== Posts =====================
                          MoreSectionHeader(
                            title: Utils.getString(context, 'more__post_title'),
                            icon: Icons.inventory_2_outlined,
                          ),

                          MoreMenuTile(
                            title: Utils.getString(
                                context, 'more__pending_post_title'),
                            subtitle:
                            Utils.getString(context, 'more__pending_list'),
                            icon: Icons.hourglass_bottom_rounded,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RoutePaths.userItemListForProfile,
                                arguments: ItemListIntentHolder(
                                  userId: uid,
                                  status: '0',
                                  title: Utils.getString(
                                      context, 'more__pending_post_title'),
                                ),
                              );
                            },
                          ),

                          MoreMenuTile(
                            title: Utils.getString(
                                context, 'more__active_post_title'),
                            subtitle: Utils.getString(
                                context, 'more__search_active_post'),
                            icon: Icons.check_circle_outline_rounded,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RoutePaths.userItemListForProfile,
                                arguments: ItemListIntentHolder(
                                  userId: uid,
                                  status: '1',
                                  title: Utils.getString(
                                      context, 'more__active_post_title'),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: PsDimens.space6),

                          // ===================== Payments / Ads =====================
                          MoreMenuTile(
                            title: Utils.getString(context,
                                'profile__package_transaction_history'),
                            subtitle: Utils.getString(context,
                                'more__package_transaction_subtitle'),
                            icon: Icons.receipt_long_rounded,
                            onTap: () => Navigator.pushNamed(context,
                                RoutePaths.packageTransactionHistoryList),
                          ),

                          MoreMenuTile(
                            title: Utils.getString(
                                context, 'more__paid_ads_title'),
                            subtitle: Utils.getString(
                                context, 'more__paid_ads_promote_list'),
                            icon: Icons.campaign_outlined,
                            onTap: () => Navigator.pushNamed(
                                context, RoutePaths.paidAdItemList),
                          ),

                          MoreMenuTile(
                            title:
                            Utils.getString(context, 'more__favourite_title'),
                            subtitle:
                            Utils.getString(context, 'more__favourite_post'),
                            icon: Icons.favorite_border_rounded,
                            onTap: () => Navigator.pushNamed(
                                context, RoutePaths.favouriteProductList),
                          ),

                          const SizedBox(height: PsDimens.space10),

                          // ===================== Activity =====================
                          MoreSectionHeader(
                            title:
                            Utils.getString(context, 'more__activity_title'),
                            icon: Icons.auto_graph_rounded,
                          ),

                          MoreMenuTile(
                            title: Utils.getString(context, 'more__offer_title'),
                            subtitle:
                            Utils.getString(context, 'more__offer_list'),
                            icon: Icons.local_offer_outlined,
                            onTap: () => Navigator.pushNamed(
                                context, RoutePaths.offerList),
                          ),

                          MoreMenuTile(
                            title:
                            Utils.getString(context, 'more__follower_title'),
                            subtitle: Utils.getString(
                                context, 'more__follower_user'),
                            icon: Icons.people_outline_rounded,
                            onTap: () => Navigator.pushNamed(
                                context, RoutePaths.followerUserList),
                          ),

                          MoreMenuTile(
                            title: Utils.getString(
                                context, 'more__following_title'),
                            subtitle: Utils.getString(
                                context, 'more__following_user'),
                            icon: Icons.person_add_alt_rounded,
                            onTap: () => Navigator.pushNamed(
                                context, RoutePaths.followingUserList),
                          ),

                          MoreMenuTile(
                            title: Utils.getString(
                                context, 'more__history_title'),
                            subtitle: Utils.getString(
                                context, 'more__history_browse'),
                            icon: Icons.history_rounded,
                            onTap: () => Navigator.pushNamed(
                                context, RoutePaths.historyList),
                          ),

                          const SizedBox(height: PsDimens.space10),

                          // ===================== Settings & Privacy =====================
                          MoreSectionHeader(
                            title: Utils.getString(
                                context, 'more__setting_and_privacy_title'),
                            icon: Icons.lock_outline_rounded,
                          ),

                          if (Utils.showUI(valueHolder!.blockedFeatureDisabled))
                            MoreMenuTile(
                              title: Utils.getString(
                                  context, 'more__block_user_title'),
                              subtitle: Utils.getString(
                                  context, 'more__block_user_list'),
                              icon: Icons.block_outlined,
                              onTap: () => Navigator.pushNamed(
                                  context, RoutePaths.blockUserList),
                            ),

                          MoreMenuTile(
                            title: Utils.getString(
                                context, 'more__report_item_title'),
                            subtitle: Utils.getString(
                                context, 'more__report_item_list'),
                            icon: Icons.report_gmailerrorred_outlined,
                            onTap: () => Navigator.pushNamed(
                                context, RoutePaths.reportItemList),
                          ),

                          _MoreDeactivateAccWidget(
                            userProvider: userProvider,
                            closeMoreContainerView:
                            widget.closeMoreContainerView,
                          ),

                          MoreMenuTile(
                            title:
                            Utils.getString(context, 'setting__toolbar_name'),
                            subtitle:
                            Utils.getString(context, 'more__app_setting'),
                            icon: Icons.settings_outlined,
                            onTap: () => Navigator.pushNamed(
                                context, RoutePaths.setting),
                          ),

                          const SizedBox(height: PsDimens.space10),

                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// Premium UI Widgets (unchanged)
// ============================================================

class MoreSectionHeader extends StatelessWidget {
  const MoreSectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color:
                (PsColors.activeColor ?? PsColors.baseColor)
                    .withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: PsColors.textColor1,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PsColors.textColor1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PsColors.textColor3,
                      height: 1.2,
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

class MoreMenuTile extends StatelessWidget {
  const MoreMenuTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.badgeText,
    this.badgeColor,
    this.isDestructive = false,
    this.margin = const EdgeInsets.fromLTRB(16, 6, 16, 0),
  }) : super(key: key);

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData? icon;

  final String? badgeText;
  final Color? badgeColor;

  final bool isDestructive;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final Color iconBg =
    (PsColors.activeColor ?? PsColors.baseColor).withOpacity(0.10);
    final Color? titleColor =
    isDestructive ? Colors.redAccent : PsColors.textColor1;
    final Color? subColor = PsColors.textColor3;

    return TaapdeelInfoCardShell(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      withBlur: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: titleColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (badgeText != null &&
                              badgeText!.isNotEmpty) ...<Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: (badgeColor ??
                                    (PsColors.activeColor ??
                                        PsColors.baseColor))
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                badgeText!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: badgeColor ??
                                      (PsColors.activeColor ??
                                          PsColors.baseColor),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Icon(Icons.chevron_right_rounded,
                              color: PsColors.textColor3, size: 22),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subColor,
                          height: 1.25,
                        ),
                      ),
                    ],
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

class _MoreDeactivateAccWidget extends StatelessWidget {
  const _MoreDeactivateAccWidget({
    required this.userProvider,
    required this.closeMoreContainerView,
  });

  final UserProvider userProvider;
  final Function closeMoreContainerView;

  @override
  Widget build(BuildContext context) {
    return MoreMenuTile(
      title: Utils.getString(context, 'more__deactivate_account_title'),
      subtitle: Utils.getString(
          context, 'more__recover_account_after_deactivate'),
      icon: Icons.no_accounts_outlined,
      isDestructive: true,
      onTap: () {
        showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialogView(
              description: Utils.getString(
                  context, 'profile__deactivate_confirm_text'),
              leftButtonText: Utils.getString(context, 'dialog__cancel'),
              rightButtonText: Utils.getString(context, 'dialog__ok'),
              onAgreeTap: () async {
                Navigator.of(context).pop();
                await PsProgressDialog.showDialog(context);

                final DeleteUserHolder deleteUserHolder = DeleteUserHolder(
                    userId: userProvider.psValueHolder!.loginUserId);

                final PsResource<ApiStatus> apiStatus =
                await userProvider.postDeleteUser(deleteUserHolder.toMap());

                PsProgressDialog.dismissDialog();

                if (apiStatus.data != null) {
                  closeMoreContainerView();
                } else {
                  showDialog<dynamic>(
                    context: context,
                    builder: (BuildContext context) {
                      return ErrorDialog(message: apiStatus.message);
                    },
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
