import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/delete_task/delete_task_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/delete_task_repository.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/dialog/confirm_dialog_view.dart';
import 'package:taapdeel/ui/common/dialog/share_app_dialog.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/user_logout_parameter_holder.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:http/http.dart' as http;


import '../../../paymob_payment/ui/pakages_screen/packages_screen.dart';
import '../../../constant/ps_constants.dart';
import '../../user/admin/admin_pending_products_review_view.dart';

// ─────────────────────────────────────────────────────────────
// ألوان design-system التطبيق (مركزية وسهلة التعديل)
// ─────────────────────────────────────────────────────────────
class _DC {
  static const Color navy      = Color(0xFF002851);
  static const Color blue      = Color(0xFF1A4A8A);
  static const Color teal      = Color(0xFF0096C7);
  static const Color tealLight = Color(0xFF00B4D8);

  // icon container backgrounds
  static const Color bgBlue   = Color(0xFFE6F1FB);
  static const Color bgTeal   = Color(0xFFE1F5EE);
  static const Color bgAmber  = Color(0xFFFAEEDA);
  static const Color bgPurple = Color(0xFFEEEDFE);
  static const Color bgRed    = Color(0xFFFCEBEB);

  // icon foreground colors
  static const Color fgBlue   = Color(0xFF185FA5);
  static const Color fgTeal   = Color(0xFF0F6E56);
  static const Color fgAmber  = Color(0xFF854F0B);
  static const Color fgPurple = Color(0xFF534AB7);
  static const Color fgRed    = Color(0xFFE24B4A);

  static const Color gold     = Color(0xFFFFD26F);
  static const Color divider  = Color(0xFFF0F0F0);
  static const Color itemText = Color(0xFF1A2A4A);
}

// ─────────────────────────────────────────────────────────────
// DashboardDrawer — الكلاس الرئيسي
// ─────────────────────────────────────────────────────────────
class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({
    Key? key,
    required this.userRepository,
    required this.deleteTaskRepository,
    required this.valueHolder,
    required this.onSelectIndex,
    required this.onLogoutSuccess,
  }) : super(key: key);

  final UserRepository?      userRepository;
  final DeleteTaskRepository? deleteTaskRepository;
  final PsValueHolder?        valueHolder;
  final void Function(String title, int index) onSelectIndex;
  final void Function()       onLogoutSuccess;

  bool get _isLoggedIn =>
      valueHolder?.loginUserId != null && valueHolder!.loginUserId != '';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<UserProvider>(
            lazy: false,
            create: (_) => UserProvider(repo: userRepository, psValueHolder: valueHolder),
          ),
          ChangeNotifierProvider<DeleteTaskProvider?>(
            lazy: false,
            create: (_) => DeleteTaskProvider(repo: deleteTaskRepository, psValueHolder: valueHolder),
          ),
        ],
        child: Consumer2<UserProvider, DeleteTaskProvider?>(
          builder: (context, provider, deleteTaskProvider, _) {
            final bool loggedIn =
                provider.psValueHolder?.loginUserId != null &&
                    provider.psValueHolder!.loginUserId != '';

            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                // ── Header ──────────────────────────────────────
                _DrawerHeaderWidget(
                  loginUserId:   provider.psValueHolder?.loginUserId ?? '',
                  loginUserName: provider.psValueHolder?.loginUserName ?? '',
                ),

                // ── زر شراء الطلبات ──────────────────────────────
              /*  _CtaButton(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (_) => PackagesScreen(afterPayment: false),
                    ),
                  ),
                ),*/

                // ── قسم: الرئيسية ─────────────────────────────────
                _SectionLabel(Utils.getString(context, 'home__drawer_menu_home')),
                _DrawerMenuWidget(
                  icon:    Icons.home_outlined,
                  iconBg:  _DC.bgBlue,
                  iconFg:  _DC.fgBlue,
                  title:   Utils.getString(context, 'home__drawer_menu_home'),
                  index:   PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
                  onTap:   (t, i) { Navigator.pop(context); onSelectIndex(t, i); },
                ),
                const _Divider(),

                // ── قسم: معلومات المستخدم ─────────────────────────
                _SectionLabel(Utils.getString(context, 'home__menu_drawer_user_info')),
                _DrawerMenuWidget(
                  icon:   Icons.person_outline,
                  iconBg: _DC.bgTeal,
                  iconFg: _DC.fgTeal,
                  title:  Utils.getString(context, 'home__menu_drawer_profile'),
                  index:  PsConst.REQUEST_CODE__MENU_SELECT_WHICH_USER_FRAGMENT,
                  onTap:  (t, i) {
                    Navigator.pop(context);
                    final computed = (valueHolder?.userIdToVerify == null ||
                        valueHolder!.userIdToVerify == '')
                        ? Utils.getString(context, 'home__menu_drawer_profile')
                        : Utils.getString(context, 'home__bottom_app_bar_verify_email');
                    onSelectIndex(computed, i);
                  },
                ),
                if (loggedIn) ...[
                  _DrawerMenuWidget(
                    icon:   Icons.favorite_border,
                    iconBg: _DC.bgAmber,
                    iconFg: _DC.fgAmber,
                    title:  Utils.getString(context, 'home__menu_drawer_favourite'),
                    index:  PsConst.REQUEST_CODE__MENU_FAVOURITE_FRAGMENT,
                    onTap:  (t, i) { Navigator.pop(context); onSelectIndex(t, i); },
                  ),
                  _DrawerMenuWidget(
                    icon:   Icons.notifications_none_outlined,
                    iconBg: _DC.bgPurple,
                    iconFg: _DC.fgPurple,
                    title:  'التنبيهات',
                    index:  -1001,
                    onTap:  (t, i) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RoutePaths.notiList);
                    },
                  ),
                  _AdminPendingProductsMenuGate(
                    adminUserId: provider.psValueHolder?.loginUserId ?? '',
                  ),
                  _LogoutTile(
                    onTap: () async {
                      final BuildContext rootContext =
                          Navigator.of(context, rootNavigator: true).context;

                      final String description = Utils.getString(
                        context,
                        'home__logout_dialog_description',
                      );
                      final String cancelText = Utils.getString(
                        context,
                        'home__logout_dialog_cancel_button',
                      );
                      final String okText = Utils.getString(
                        context,
                        'home__logout_dialog_ok_button',
                      );

                      Navigator.pop(context);

                      await Future<void>.delayed(Duration.zero);

                      showDialog<dynamic>(
                        context: rootContext,
                        builder: (BuildContext dialogContext) => ConfirmDialogView(
                          description:     description,
                          leftButtonText:  cancelText,
                          rightButtonText: okText,
                          onAgreeTap: () async {
                            Navigator.pop(dialogContext);
                            await _doLogout(rootContext, provider, deleteTaskProvider);
                          },
                        ),
                      );
                    },
                    title: Utils.getString(context, 'home__menu_drawer_logout'),
                  ),
                ],
                const _Divider(),

                // ── قسم: التطبيق ──────────────────────────────────
                _SectionLabel(Utils.getString(context, 'home__menu_drawer_app')),
                _DrawerMenuWidget(
                  icon:   Icons.settings_outlined,
                  iconBg: _DC.bgBlue,
                  iconFg: _DC.fgBlue,
                  title:  Utils.getString(context, 'home__menu_drawer_setting'),
                  index:  PsConst.REQUEST_CODE__MENU_SETTING_FRAGMENT,
                  onTap:  (t, i) { Navigator.pop(context); onSelectIndex(t, i); },
                ),
                _ShareTile(
                  title: Utils.getString(context, 'home__menu_drawer_share_this_app'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog<dynamic>(
                      context: context,
                      builder: (_) => ShareAppDialog(
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    );
                  },
                ),
                _DrawerMenuWidget(
                  icon:   FontAwesome.question_circle_o,
                  iconBg: _DC.bgAmber,
                  iconFg: _DC.fgAmber,
                  title:  Utils.getString(context, 'setting__faq'),
                  index:  PsConst.REQUEST_CODE__MENU_FAQ_PAGES_FRAGMENT,
                  onTap:  (t, i) { Navigator.pop(context); onSelectIndex(t, i); },
                ),
                _DrawerMenuWidget(
                  icon:   Icons.headset_mic_outlined,
                  iconBg: _DC.bgTeal,
                  iconFg: _DC.fgTeal,
                  title:  Utils.getString(context, 'home__menu_drawer_contact_us'),
                  index:  PsConst.REQUEST_CODE__MENU_CONTACT_US_FRAGMENT,
                  onTap:  (t, i) { Navigator.pop(context); onSelectIndex(t, i); },
                ),
                _DrawerMenuWidget(
                  icon:   Icons.description_outlined,
                  iconBg: _DC.bgPurple,
                  iconFg: _DC.fgPurple,
                  title:  Utils.getString(context, 'terms_and_condition__toolbar_name'),
                  index:  PsConst.REQUEST_CODE__MENU_TERMS_AND_CONDITION_FRAGMENT,
                  onTap:  (t, i) { Navigator.pop(context); onSelectIndex(t, i); },
                ),
                _RateTile(
                  title:     Utils.getString(context, 'home__menu_drawer_rate_this_app'),
                  valueHolder: valueHolder,
                  onTap:     () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _doLogout(
      BuildContext context,
      UserProvider provider,
      DeleteTaskProvider? deleteTaskProvider,
      ) async {
    bool dialogShown = false;

    try {
      await PsProgressDialog.showDialog(context);
      dialogShown = true;

      final String loginUserId = provider.psValueHolder?.loginUserId ?? '';
      if (loginUserId.isNotEmpty) {
        final UserLogoutHolder holder = UserLogoutHolder(userId: loginUserId);
        await provider.userLogout(holder.toMap());
      }
    } catch (_) {
      // حتى لو API logout فشل، لازم نمسح الجلسة محليًا حتى لا يظل المستخدم logged in.
    } finally {
      if (dialogShown) {
        PsProgressDialog.dismissDialog();
      }

      await _clearSession(provider, deleteTaskProvider);

      final bool forceLogin = provider.psValueHolder?.isForceLogin == true;

      // مهم جدًا:
      // onLogoutSuccess في DashboardView يعمل setState.
      // لذلك لازم يتنفذ قبل أي تنقل؛ لأن التنقل بـ removeUntil
      // يزيل HomeView من الشجرة، وبعدها أي setState داخله يسبب صفحة بيضاء / crash.
      onLogoutSuccess();

      if (!context.mounted) {
        return;
      }

      if (forceLogin) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutePaths.login_container,
              (_) => false,
        );
        return;
      }

      // لو التطبيق يسمح بالتصفح كزائر، رجّع المستخدم للصفحة الرئيسية بعد تسجيل الخروج.
      onSelectIndex(
        Utils.getString(context, 'home__drawer_menu_home'),
        PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
      );
    }
  }

  Future<void> _clearSession(
      UserProvider provider,
      DeleteTaskProvider? deleteTaskProvider,
      ) async {
    await provider.replaceLoginUserId('');
    await provider.replaceLoginUserName('');
    await deleteTaskProvider?.deleteTask();
    await GoogleSignIn().signOut();
    await fb_auth.FirebaseAuth.instance.signOut();
  }
}

// ─────────────────────────────────────────────────────────────
// _DrawerHeaderWidget — Header مع gradient + بيانات المستخدم
// ─────────────────────────────────────────────────────────────
class _DrawerHeaderWidget extends StatelessWidget {
  const _DrawerHeaderWidget({
    required this.loginUserId,
    required this.loginUserName,
  });

  final String loginUserId;
  final String loginUserName;

  bool get _isLoggedIn => loginUserId.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_DC.navy, _DC.blue, _DC.teal],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo + اسم التطبيق ───────────────────────────
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/images/Taapdeel_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Utils.getString(context, 'app_name'),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── بيانات المستخدم (لو logged in) ──────────────
              if (_isLoggedIn) ...[
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [_DC.tealLight, _DC.teal],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        loginUserName.isNotEmpty
                            ? loginUserName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loginUserName.isNotEmpty ? loginUserName : '---',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Utils.getString(context, 'home__menu_drawer_profile'),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Guest state
                Text(
                  Utils.getString(context, 'login__title'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _CtaButton — زر شراء طلبات تبديل
// ─────────────────────────────────────────────────────────────
class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_DC.navy, _DC.blue],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _DC.tealLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.arrow_forward, color: Colors.white, size: 13),
              ),
              /* const SizedBox(width: 8),
              const Text(
                'شراء طلبات تبديل',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _SectionLabel — عنوان القسم
// ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _DC.teal,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _Divider — فاصل خفيف
// ─────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: _DC.divider,
      indent: 16,
      endIndent: 16,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _DrawerMenuWidget — عنصر القائمة الأساسي
// ─────────────────────────────────────────────────────────────
class _DrawerMenuWidget extends StatelessWidget {
  const _DrawerMenuWidget({
    Key? key,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  final IconData icon;
  final Color    iconBg;
  final Color    iconFg;
  final String   title;
  final Function(String title, int index) onTap;
  final int      index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: _IconContainer(bg: iconBg, fg: iconFg, icon: icon),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _DC.itemText,
        ),
      ),
      trailing: Icon(
        Icons.chevron_left,
        size: 18,
        color: Colors.grey.shade400,
      ),
      onTap: () => onTap(title, index),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _IconContainer — Container الأيقونة الملوّن
// ─────────────────────────────────────────────────────────────
class _IconContainer extends StatelessWidget {
  const _IconContainer({
    required this.bg,
    required this.fg,
    required this.icon,
  });

  final Color    bg;
  final Color    fg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: fg, size: 18),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// _AdminPendingProductsMenuGate — يظهر رابط مراجعة المنتجات للأدمن فقط
// ─────────────────────────────────────────────────────────────
class _AdminPendingProductsMenuGate extends StatefulWidget {
  const _AdminPendingProductsMenuGate({required this.adminUserId});

  final String adminUserId;

  @override
  State<_AdminPendingProductsMenuGate> createState() =>
      _AdminPendingProductsMenuGateState();
}

class _AdminPendingProductsMenuGateState
    extends State<_AdminPendingProductsMenuGate> {
  bool _loading = true;
  bool _isAdmin = false;

  String get _serverBase {
    String base = PsConfig.ps_app_url.trim();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    base = base.replaceFirst(RegExp(r'/index\.php/?$'), '');
    return base;
  }

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  @override
  void didUpdateWidget(covariant _AdminPendingProductsMenuGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adminUserId != widget.adminUserId) {
      _checkAdminAccess();
    }
  }

  Future<void> _checkAdminAccess() async {
    final String userId = widget.adminUserId.trim();

    if (userId.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _isAdmin = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _isAdmin = false;
    });

    try {
      final http.Response response = await http.post(
        Uri.parse('$_serverBase/index.php/rest/items/is_sys_admin/api_key/teampsisthebest1'),
        body: <String, String>{'admin_user_id': userId},
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode != 200) {
        setState(() {
          _loading = false;
          _isAdmin = false;
        });
        return;
      }

      final dynamic decoded = jsonDecode(response.body);
      final dynamic rawValue = decoded is Map<String, dynamic>
          ? decoded['is_sys_admin'] ??
          decoded['is_admin'] ??
          (decoded['data'] is Map<String, dynamic>
              ? decoded['data']['is_sys_admin'] ?? decoded['data']['is_admin']
              : null)
          : null;

      setState(() {
        _loading = false;
        _isAdmin = rawValue?.toString() == '1';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _isAdmin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_isAdmin) {
      return const SizedBox.shrink();
    }

    return _DrawerMenuWidget(
      icon: Icons.admin_panel_settings_rounded,
      iconBg: _DC.bgPurple,
      iconFg: _DC.fgPurple,
      title: 'مراجعة المنتجات المنتظرة',
      index: -9001,
      onTap: (_, __) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute<Widget>(
            builder: (_) => const AdminPendingProductsReviewView(),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _LogoutTile — عنصر تسجيل الخروج (destructive style)
// ─────────────────────────────────────────────────────────────
class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap, required this.title});
  final VoidCallback onTap;
  final String       title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: const _IconContainer(
        bg:   _DC.bgRed,
        fg:   _DC.fgRed,
        icon: Icons.power_settings_new,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _DC.fgRed,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _ShareTile — مشاركة التطبيق
// ─────────────────────────────────────────────────────────────
class _ShareTile extends StatelessWidget {
  const _ShareTile({required this.title, required this.onTap});
  final String       title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: const _IconContainer(
        bg:   _DC.bgTeal,
        fg:   _DC.fgTeal,
        icon: Icons.share_outlined,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _DC.itemText,
        ),
      ),
      trailing: Icon(Icons.chevron_left, size: 18, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _RateTile — تقييم التطبيق
// ─────────────────────────────────────────────────────────────
class _RateTile extends StatelessWidget {
  const _RateTile({
    required this.title,
    required this.onTap,
    required this.valueHolder,
  });
  final String        title;
  final VoidCallback  onTap;
  final PsValueHolder? valueHolder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: const _IconContainer(
        bg:   _DC.bgAmber,
        fg:   _DC.fgAmber,
        icon: Icons.star_outline,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _DC.itemText,
        ),
      ),
      trailing: Icon(Icons.chevron_left, size: 18, color: Colors.grey.shade400),
      onTap: () {
        onTap();
        if (Platform.isIOS) {
          Utils.launchAppStoreURL(iOSAppId: valueHolder?.iosAppStoreId, writeReview: true);
        } else {
          Utils.launchURL();
        }
      },
    );
  }
}