import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
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

// ✅ الكارت
import 'package:taapdeel/ui/Product/taapdeel_selectable_user_card.dart';
import '../../Product/taapdeel_selectable_user_widecard .dart';

class FollowingUserListView extends StatefulWidget {
  @override
  _FollowingUserListViewState createState() => _FollowingUserListViewState();
}

class _FollowingUserListViewState extends State<FollowingUserListView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  UserRepository? repo1;
  PsValueHolder? psValueHolder;

  // ✅ Guard to avoid late init crash
  bool _providerReady = false;
  late UserListProvider _userListProvider;

  @override
  void initState() {
    super.initState();

    // ✅ Pagination (safe)
    _scrollController.addListener(() {
      if (!_providerReady) return;

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        final String? loginUserId =
        Utils.checkUserLoginId(_userListProvider.psValueHolder!);
        _userListProvider.followingUserParameterHolder.loginUserId = loginUserId;
        _userListProvider
            .nextUserList(_userListProvider.followingUserParameterHolder);
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

          // ✅ load first page
          final String? loginUserId = Utils.checkUserLoginId(provider.psValueHolder!);
          provider.followingUserParameterHolder.loginUserId = loginUserId;
          provider.loadUserList(provider.followingUserParameterHolder);

          _userListProvider = provider;
          _providerReady = true;

          return provider;
        },
        child: Consumer<UserListProvider>(
          builder: (BuildContext context, UserListProvider provider, Widget? child) {
            final users = provider.userList.data ?? <dynamic>[];

            return TaapdeelScaffold(
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
                      provider.followingUserParameterHolder.loginUserId =
                          provider.psValueHolder!.loginUserId;
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
                                if (users.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                final u = users[index];

                                final String id = (u.userId ?? '').toString();
                                final String name = (u.userName ?? '').toString();
                                final String code = (u.code ?? '').toString();
                                final String heroTag = '$code${PsConst.HERO_TAG__IMAGE}';

                                final String? imagePath =
                                (u.userProfilePhoto != null &&
                                    u.userProfilePhoto.toString().trim().isNotEmpty)
                                    ? u.userProfilePhoto.toString().trim()
                                    : null;

                                final String? gender =
                                (u.userGender ?? '').toString().trim().isEmpty
                                    ? null
                                    : u.userGender.toString().trim();

                                final String? ageRange =
                                (u.userAge ?? '').toString().trim().isEmpty
                                    ? null
                                    : u.userAge.toString().trim();

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
                                );
                              },
                              childCount: users.length,
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
