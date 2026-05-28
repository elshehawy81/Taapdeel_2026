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

// ✅ Taapdeel Scaffold (عدّل المسار حسب مشروعك)
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';

// ✅ كارت المستخدم
import 'package:taapdeel/ui/Product/taapdeel_selectable_user_card.dart';
import '../../Product/taapdeel_selectable_user_widecard .dart';

class FollowerUserListView extends StatefulWidget {
  @override
  _FollowerUserListViewState createState() => _FollowerUserListViewState();
}

class _FollowerUserListViewState extends State<FollowerUserListView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  UserRepository? repo1;
  PsValueHolder? psValueHolder;

  bool _providerReady = false;
  late UserListProvider _userListProvider;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_providerReady) return;

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        final String? loginUserId =
        Utils.checkUserLoginId(_userListProvider.psValueHolder!);
        _userListProvider.followerUserParameterHolder.loginUserId = loginUserId;
        _userListProvider.nextUserList(_userListProvider.followerUserParameterHolder);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;

    repo1 = Provider.of<UserRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    Future<bool> _requestPop() async {
      Navigator.pop(context, true);
      return false;
    }

    return WillPopScope(
      onWillPop: _requestPop,
      child: ChangeNotifierProvider<UserListProvider>(
        create: (_) {
          final provider = UserListProvider(repo: repo1, psValueHolder: psValueHolder);

          final String? loginUserId = Utils.checkUserLoginId(provider.psValueHolder!);
          provider.followerUserParameterHolder.loginUserId = loginUserId;
          provider.loadUserList(provider.followerUserParameterHolder);

          _userListProvider = provider;
          _providerReady = true;

          return provider;
        },
        child: Consumer<UserListProvider>(
          builder: (BuildContext context, UserListProvider provider, Widget? child) {
            final list = provider.userList.data ?? <dynamic>[];

            return TaapdeelScaffold(
              appBar: AppBar(
                title: Text(Utils.getString(context, 'follower__title')),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: Stack(
                children: <Widget>[
                  RefreshIndicator(
                    onRefresh: () async {
                      provider.followerUserParameterHolder.loginUserId =
                          provider.psValueHolder!.loginUserId;
                      return provider.resetUserList(provider.followerUserParameterHolder);
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
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

                  // ✅ Loader
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
