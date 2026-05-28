import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/provider/item_location/item_location_provider.dart';
import 'package:taapdeel/repository/item_location_repository.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/item_location.dart';
import 'package:provider/provider.dart';

// Taapdeel UI
import 'package:taapdeel/ui/common/taapdeel/taapdeel_text_field.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_section_header.dart';

import '../../api/common/ps_status.dart';

class ItemLocationFirstView extends StatefulWidget {
  const ItemLocationFirstView({
    Key? key,
    this.draggableScrollController, // ✅ مهم لو هتستخدم DraggableScrollableSheet
  }) : super(key: key);

  final ScrollController? draggableScrollController;

  @override
  State<ItemLocationFirstView> createState() => _ItemLocationFirstSheetState();
}

class _ItemLocationFirstSheetState extends State<ItemLocationFirstView>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  AnimationController? _animationController;

  late ItemLocationProvider _provider;
  bool _providerInited = false;

  PsValueHolder? _valueHolder;
  ItemLocationRepository? _repo;

  final TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    // ✅ لو جاي لك ScrollController من Draggable sheet استخدمه
    _scrollController = widget.draggableScrollController ?? ScrollController();

    _scrollController.addListener(() {
      if (!_providerInited) {
        return;
      }

      if (!_scrollController.hasClients) {
        return;
      }

      final ScrollPosition position = _scrollController.position;

      if (position.pixels >= position.maxScrollExtent - 80) {
        _provider.nextItemLocationList(
          _provider.latestLocationParameterHolder.toMap(),
          Utils.checkUserLoginId(_provider.psValueHolder!),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerInited) {
      return;
    }

    _repo = Provider.of<ItemLocationRepository>(context, listen: false);
    _valueHolder = Provider.of<PsValueHolder?>(context, listen: false);

    _provider = ItemLocationProvider(
      repo: _repo,
      psValueHolder: _valueHolder,
      limit: _valueHolder?.defaultLoadingLimit ?? 30,
    );

    _provider.latestLocationParameterHolder.keyword = '';
    _provider.loadItemLocationList(
      _provider.latestLocationParameterHolder.toMap(),
      Utils.checkUserLoginId(_provider.psValueHolder!),
    );

    _providerInited = true;
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _searchTextController.dispose();

    // ✅ متقفلش controller لو هو جاي من Draggable sheet
    if (widget.draggableScrollController == null) {
      _scrollController.dispose();
    }

    if (_providerInited) {
      _provider.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ItemLocationProvider>.value(
      value: _provider,
      child: Consumer<ItemLocationProvider>(
        builder: (BuildContext context, ItemLocationProvider provider, _) {
          final List<ItemLocation> dataList =
              provider.itemLocationList.data ?? <ItemLocation>[];

          // ✅ loader بس لو مفيش بيانات
          final bool showLoader =
              (provider.itemLocationList.status == PsStatus.PROGRESS_LOADING ||
                  provider.itemLocationList.status ==
                      PsStatus.BLOCK_LOADING) &&
                  dataList.isEmpty;

          final int itemCount = dataList.length ; // +1 = كل المحافظات

          return Material(
            color: Colors.transparent,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Color(0xFFE8F4FF),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // ✅ handle صغير فوق
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 6),
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),

                  if (showLoader)
                    PSProgressIndicator(
                      provider.itemLocationList.status,
                      message: provider.itemLocationList.message,
                    ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: TaapdeelSectionHeader(
                      title: Utils.getString(context, 'select_city'),
                      leadingIcon: Icons.location_city_outlined,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TaapdeelTextField(
                      controller: _searchTextController,
                      hint: Utils.getString(
                        context,
                        'item_location__search_Gov',
                      ),
                      prefixIcon: Icons.search,
                      onChanged: (String value) {
                        provider.latestLocationParameterHolder.keyword = value;
                        provider.resetItemLocationList(
                          provider.latestLocationParameterHolder.toMap(),
                          Utils.checkUserLoginId(provider.psValueHolder!),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () {
                        return provider.resetItemLocationList(
                          provider.latestLocationParameterHolder.toMap(),
                          provider.psValueHolder!.loginUserId,
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
                          final ItemLocation loc = dataList[index];

                          final String title = loc.name ?? '';

                          final bool selected =
                              provider.psValueHolder?.locationId == (loc.id ?? '');

                          return _LocationChoiceChip(
                            title: title,
                            selected: selected,
                            isAll: false,
                            onTap: () async {
                              await provider.replaceItemLocationData(
                                loc.id ?? '',
                                loc.name ?? '',
                                loc.lat ?? PsConst.INVALID_LAT_LNG,
                                loc.lng ?? PsConst.INVALID_LAT_LNG,
                              );

                              if (context.mounted) {
                                Navigator.pop(context, loc);
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

class _LocationChoiceChip extends StatelessWidget {
  const _LocationChoiceChip({
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
                  Icons.chevron_right_rounded,
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