import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/user/user_list_provider.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/user_intent_holder.dart';
import 'package:provider/provider.dart';

import '../../Product/taapdeel_selectable_user_widecard .dart';

// ✅ Taapdeel Scaffold
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';

class DetailFollowingUserListView extends StatefulWidget {
  const DetailFollowingUserListView({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;

  @override
  _DetailFollowingUserListViewState createState() {
    return _DetailFollowingUserListViewState();
  }
}

class _DetailFollowingUserListViewState extends State<DetailFollowingUserListView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // ✅ avoid late crash
  bool _providerReady = false;
  late UserListProvider _userListProvider;

  AnimationController? animationController;

  UserRepository? repo1;
  PsValueHolder? psValueHolder;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    _scrollController.addListener(() {
      if (!_providerReady) return;

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        // ✅ Pagination
        final String? loginUserId =
        Utils.checkUserLoginId(_userListProvider.psValueHolder!);

        _userListProvider.followingUserParameterHolder.loginUserId = loginUserId;
        _userListProvider.nextUserList(_userListProvider.followingUserParameterHolder);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _requestPop() async {
      await animationController?.reverse();
      if (!mounted) return false;
      Navigator.pop(context, true);
      return true;
    }

    timeDilation = 1.0;
    repo1 = Provider.of<UserRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    return WillPopScope(
      onWillPop: _requestPop,
      child: ChangeNotifierProvider<UserListProvider>(
        create: (_) {
          final provider = UserListProvider(repo: repo1, psValueHolder: psValueHolder);

          // ✅ Detail: load following of this widget.userId
          provider.followingUserParameterHolder.loginUserId = widget.userId;
          provider.loadUserList(provider.followingUserParameterHolder);

          _userListProvider = provider;
          _providerReady = true;

          return provider;
        },
        child: Consumer<UserListProvider>(
          builder: (BuildContext context, UserListProvider provider, Widget? child) {
            final list = provider.userList.data ?? <dynamic>[];

            return TaapdeelScaffold(
              safeTop: true,
              padding: EdgeInsets.zero,
              appBar: AppBar(
                title: Text(Utils.getString(context, 'following__title')),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: Stack(
                children: <Widget>[
                  RefreshIndicator(
                    onRefresh: () async {
                      provider.followingUserParameterHolder.loginUserId = widget.userId;
                      return provider.resetUserList(provider.followingUserParameterHolder);
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            PsDimens.space16,
                            PsDimens.space12,
                            PsDimens.space16,
                            PsDimens.space16,
                          ),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                if (list.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                final user = list[index];

                                final String id = (user.userId ?? '').toString();
                                final String name = (user.userName ?? '').toString();
                                final String code = (user.code ?? '').toString();

                                final String heroTag =
                                    '$code${PsConst.HERO_TAG__IMAGE}';

                                final String? imagePath =
                                (user.userProfilePhoto != null &&
                                    user.userProfilePhoto.toString().trim().isNotEmpty)
                                    ? user.userProfilePhoto.toString().trim()
                                    : null;

                                final String? gender =
                                (user.userGender ?? '').toString().trim().isEmpty
                                    ? null
                                    : user.userGender.toString().trim();

                                final String? ageRange =
                                (user.userAge ?? '').toString().trim().isEmpty
                                    ? null
                                    : user.userAge.toString().trim();

                                return TaapdeelSelectableUserWidecard(
                                  compact: true,
                                  width: double.infinity,
                                  userId: id,
                                  name: name,
                                  photoHeroTag: heroTag,
                                  imagePath: imagePath,
                                  gender: gender,
                                  ageRange: ageRange,
                                  selected: false,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      RoutePaths.userDetail,
                                      arguments: UserIntentHolder(
                                        userId: id,
                                        userName: name,
                                      ),
                                    );
                                  },
                                  itemsCount: null,
                                );
                              },
                              childCount: list.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  PSProgressIndicator(provider.userList.status),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
