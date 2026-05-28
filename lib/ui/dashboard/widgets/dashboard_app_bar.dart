import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:provider/provider.dart';

import '../../Contacts/contact_network_bottom_sheet.dart';
import '../../Contacts/contact_network_provider.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    Key? key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearch,
    required this.onOpenLocation,
    required this.valueHolder,
    required this.psValueHolder,
  }) : super(key: key);

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onSearch;
  final VoidCallback onOpenLocation;

  final PsValueHolder? valueHolder;
  final PsValueHolder? psValueHolder;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
      ),
      iconTheme: IconThemeData(color: PsColors.buttonColor),
      titleSpacing: 10,
      title: _TitleRow(
        searchController: searchController,
        searchFocusNode: searchFocusNode,
        onSearch: onSearch,
        onOpenLocation: onOpenLocation,
        valueHolder: valueHolder,
        psValueHolder: psValueHolder,
      ),
      actions: const <Widget>[],
    );
  }
}

class _TitleRow extends StatefulWidget {
  const _TitleRow({
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearch,
    required this.onOpenLocation,
    required this.valueHolder,
    required this.psValueHolder,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onSearch;
  final VoidCallback onOpenLocation;
  final PsValueHolder? valueHolder;
  final PsValueHolder? psValueHolder;

  @override
  State<_TitleRow> createState() => _TitleRowState();
}

class _TitleRowState extends State<_TitleRow> {
  bool _searchExpanded = false;

  void _openSearch() {
    setState(() => _searchExpanded = true);
    Future<void>.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      widget.searchFocusNode.requestFocus();
    });
  }

  void _submitSearch() {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSearch();
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.sizeOf(context).width;
    final bool compact = screenW < 380;

    return Row(
      children: [
        Expanded(
          child: Consumer<ContactNetworkProvider>(
            builder: (context, provider, _) {
              return _NetworkChip(
                count: provider.pendingCount,
                syncing: provider.isSyncing,
                hasPermission: provider.hasPermission,
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await ContactNetworkBottomSheet.show(context);
                },
              );
            },
          ),
        ),
        SizedBox(width: compact ? 7 : 9),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: _searchExpanded ? (compact ? 168 : 205) : 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(_searchExpanded ? 16 : 999),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.065),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: _searchExpanded
              ? Row(
            children: [
              const SizedBox(width: 9),
              Expanded(
                child: TextField(
                  controller: widget.searchController,
                  focusNode: widget.searchFocusNode,
                  autofocus: false,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submitSearch(),
                  onTapOutside: (_) {
                    if (widget.searchController.text.trim().isEmpty) {
                      setState(() => _searchExpanded = false);
                    }
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: Utils.getString(
                      context,
                      'home__bottom_app_bar_search',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.45),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.2,
                    ),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
              InkWell(
                onTap: _submitSearch,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.black.withOpacity(0.48),
                  ),
                ),
              ),
              if (widget.searchController.text.trim().isEmpty)
                InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() => _searchExpanded = false);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.black.withOpacity(0.35),
                    ),
                  ),
                ),
            ],
          )
              : InkWell(
            onTap: _openSearch,
            borderRadius: BorderRadius.circular(999),
            child: Icon(
              Icons.search_rounded,
              color: PsColors.primary500,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _NetworkChip extends StatelessWidget {
  const _NetworkChip({
    required this.count,
    required this.syncing,
    required this.hasPermission,
    required this.onTap,
  });

  final int count;
  final bool syncing;
  final bool hasPermission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasNew = count > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 43,
        padding: const EdgeInsetsDirectional.only(start: 9, end: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: hasNew
              ? const LinearGradient(
            colors: [Color(0xFF4FACFE), Color(0xFF4FACFE), Color(0xFF00F2FE)],
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
          )
              : const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFE9FBFF)],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
          border: Border.all(
            color: hasNew ? Colors.white.withOpacity(0.28) : const Color(0xFF63CAD6).withOpacity(0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (hasNew ? const Color(0xFF4FACFE) : Color(0xFF00F2FE)).withOpacity(hasNew ? 0.22 : 0.07),
              blurRadius: hasNew ? 18 : 13,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasNew ? Colors.white.withOpacity(0.18) : const Color(0xFF0A7EA0).withOpacity(0.10),
                  ),
                  child: Icon(
                    hasPermission ? Icons.groups_2_rounded : Icons.lock_open_rounded,
                    color: hasNew ? Colors.white : const Color(0xFF0A7EA0),
                    size: 19,
                  ),
                ),
                if (hasNew)
                  PositionedDirectional(
                    top: -6,
                    end: -6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB020),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 1.7),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Color(0xFF231307),
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasNew ? '$count أصدقاء/أقارب جدد' : 'دائرة أقاربك وأصدقاءك',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasNew ? Colors.white : const Color(0xFF0F2E57),
                  fontSize: hasNew ? 12.4 : 12,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (syncing)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: hasNew ? Colors.white : const Color(0xFF0A7EA0),
                ),
              )
            else if (!hasPermission)
              const _PermissionPulseChip(compact: true)
            else
              _AddTextChip(hasNew: hasNew),
          ],
        ),
      ),
    );
  }
}

class _PermissionPulseChip extends StatefulWidget {
  const _PermissionPulseChip({required this.compact});

  final bool compact;

  @override
  State<_PermissionPulseChip> createState() => _PermissionPulseChipState();
}

class _PermissionPulseChipState extends State<_PermissionPulseChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  late final Animation<Color?> _bg;
  late final Animation<Color?> _fg;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat(reverse: true);

    final CurvedAnimation curve = CurvedAnimation(
      parent: _pulse,
      curve: Curves.easeInOutCubic,
    );

    _scale = Tween<double>(begin: 1.0, end: 1.10).animate(curve);

    _bg = ColorTween(
      begin: Colors.white,
      end: const Color(0xFFFFF3C4),
    ).animate(curve);

    _fg = ColorTween(
      begin: const Color(0xFF007D98),
      end: const Color(0xFF6B3D00),
    ).animate(curve);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (BuildContext context, Widget? child) {
          final Color bg = _bg.value ?? Colors.white;
          final Color fg = _fg.value ?? const Color(0xFF007D98);

          return Container(
            padding: EdgeInsetsDirectional.only(
              start: widget.compact ? 8 : 9,
              end: widget.compact ? 6 : 7,
              top: widget.compact ? 4 : 5,
              bottom: widget.compact ? 4 : 5,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFFFB020).withOpacity(
                    0.30 + (_pulse.value * 0.18),
                  ),
                  blurRadius: 9 + (_pulse.value * 5),
                  spreadRadius: _pulse.value * 1.1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'إبدأ',
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w900,
                    fontSize: widget.compact ? 10.5 : 11.5,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Transform.translate(
                  offset: Offset(2.0 * _pulse.value, 0),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: fg,
                    size: widget.compact ? 13 : 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddTextChip extends StatelessWidget {
  const _AddTextChip({required this.hasNew});

  final bool hasNew;

  @override
  Widget build(BuildContext context) {
    final Color fg = hasNew ? Colors.white : const Color(0xFF0A7EA0);

    final Color bg = hasNew
        ? Colors.white.withOpacity(0.18)
        : const Color(0xFF0A7EA0).withOpacity(0.10);

    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: 10,
        end: 10,
        top: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: hasNew
              ? Colors.white.withOpacity(0.22)
              : const Color(0xFF0A7EA0).withOpacity(0.14),
        ),
      ),
      child: Text(
        'إضافة',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
          fontSize: 11.2,
          height: 1,
        ),
      ),
    );
  }
}
