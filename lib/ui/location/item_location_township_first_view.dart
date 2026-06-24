import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/provider/item_location_township/item_location_township_provider.dart';
import 'package:taapdeel/repository/item_location_township_repository.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/item_location_township.dart';
import 'package:provider/provider.dart';

// Taapdeel UI
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_text_field.dart';
// لو مش موجودة عندك احذفها واستبدلها بـ Text
import 'package:taapdeel/ui/common/taapdeel/taapdeel_section_header.dart';

import '../../api/common/ps_status.dart';

class ItemLocationTownshipFirstView extends StatefulWidget {
  const ItemLocationTownshipFirstView({
    Key? key,
    required this.cityId,
  }) : super(key: key);

  final String cityId;

  @override
  _ItemLocationTownshipFirstViewState createState() =>
      _ItemLocationTownshipFirstViewState();
}

class _ItemLocationTownshipFirstViewState extends State<ItemLocationTownshipFirstView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  AnimationController? _animationController;

  late ItemLocationTownshipProvider _provider;
  bool _providerInited = false;

  PsValueHolder? _valueHolder;
  ItemLocationTownshipRepository? _repo;

  final TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    _scrollController.addListener(() {
      if (!_providerInited) return;

      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _provider.nextItemLocationTownshipListByCityId(
          _provider.latestLocationParameterHolder.toMap(),
          Utils.checkUserLoginId(_provider.psValueHolder!),
          widget.cityId,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_providerInited) return;

    _repo = Provider.of<ItemLocationTownshipRepository>(context);
    _valueHolder = Provider.of<PsValueHolder?>(context);

    _provider = ItemLocationTownshipProvider(
      repo: _repo,
      psValueHolder: _valueHolder,
      limit: _valueHolder?.defaultLoadingLimit ?? 30,
    );

    _provider.latestLocationParameterHolder.keyword = '';
    _provider.loadItemLocationTownshipListByCityId(
      _provider.latestLocationParameterHolder.toMap(),
      Utils.checkUserLoginId(_provider.psValueHolder!),
      widget.cityId,
    );

    _providerInited = true;
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _scrollController.dispose();
    _searchTextController.dispose();
    if (_providerInited) {
      _provider.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ItemLocationTownshipProvider>.value(
      value: _provider,
      child: Consumer<ItemLocationTownshipProvider>(
        builder: (BuildContext context, ItemLocationTownshipProvider provider, _) {
          final ThemeData theme = Theme.of(context);

          final List<ItemLocationTownship> dataList =
              provider.itemLocationTownshipList.data ?? <ItemLocationTownship>[];

          final bool showLoader =
              (provider.itemLocationTownshipList.status == PsStatus.PROGRESS_LOADING ||
                  provider.itemLocationTownshipList.status == PsStatus.BLOCK_LOADING) &&
                  dataList.isEmpty;

          final int itemCount = dataList.length ; // +1 = كل المناطق

          return TaapdeelScaffold(
            safeTop: true,
            safeBottom: true,
            padding: EdgeInsets.zero,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFFE8F4FF), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (showLoader)
                    PSProgressIndicator(
                      provider.itemLocationTownshipList.status,
                      message: provider.itemLocationTownshipList.message,
                    ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: TaapdeelSectionHeader(
                      title: Utils.getString(context, 'item_location__select_township'),
                      leadingIcon: Icons.map_outlined,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TaapdeelTextField(
                      controller: _searchTextController,
                      hint: Utils.getString(context, 'item_location__search_city'),
                      prefixIcon: Icons.search,
                      onChanged: (String value) {
                        provider.latestLocationParameterHolder.keyword = value;
                        provider.resetItemLocationTownshipListByCityId(
                          provider.latestLocationParameterHolder.toMap(),
                          Utils.checkUserLoginId(provider.psValueHolder!),
                          widget.cityId,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () {
                        return provider.resetItemLocationTownshipListByCityId(
                          provider.latestLocationParameterHolder.toMap(),
                          provider.psValueHolder!.loginUserId,
                          widget.cityId,
                        );
                      },
                      child: GridView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: dataList.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.85,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final ItemLocationTownship township = dataList[index];

                          final String title = township.townshipName ?? '';

                          final bool selected =
                              provider.psValueHolder?.locationTownshipId == (township.id ?? '');

                          return _TownshipChoiceChip(
                            title: title,
                            selected: selected,
                            isAll: false,
                            onTap: () async {
                              await provider.replaceItemLocationTownshipData(
                                township.id ?? '',
                                widget.cityId,
                                township.townshipName ?? '',
                                township.lat ?? PsConst.INVALID_LAT_LNG,
                                township.lng ?? PsConst.INVALID_LAT_LNG,
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                          );
                        },
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

}
class _TownshipChoiceChip extends StatelessWidget {
  const _TownshipChoiceChip({
    required this.title,
    required this.selected,
    required this.isAll,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final bool isAll;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFF0C587A);
  static const Color _accent = Color(0xFF24A9C4);
  static const Color _textDark = Color(0xFF12313F);
  static const Color _softIconBg = Color(0xFFEAF8FC);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: selected
                ? const LinearGradient(
              colors: <Color>[
                _primary,
                _accent,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            )
                : null,
            color: selected ? null : Colors.white.withValues(alpha: 0.78),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0)
                  : _primary.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: selected
                    ? _primary.withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.045),
                blurRadius: selected ? 14 : 9,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.18)
                      : _softIconBg,
                ),
                child: Icon(
                  isAll ? Icons.public_rounded : Icons.location_on_rounded,
                  size: 16,
                  color: selected ? Colors.white : _primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    color: selected ? Colors.white : _textDark,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: selected
                    ? const Icon(
                  Icons.check_circle_rounded,
                  key: ValueKey<String>('selected'),
                  size: 19,
                  color: Colors.white,
                )
                    : Icon(
                  Icons.radio_button_unchecked,
                  key: const ValueKey<String>('normal'),
                  size: 18,
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}