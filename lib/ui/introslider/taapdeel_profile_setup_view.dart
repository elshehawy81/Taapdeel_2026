import 'dart:ui' as ui; // (ar_DZ, en_US)

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';
import 'package:taapdeel/provider/item_location/item_location_provider.dart';
import 'package:taapdeel/provider/language/language_provider.dart';
import 'package:taapdeel/repository/item_location_repository.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_card.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_glass_bottom_sheet.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_text_field.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/language.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/location_parameter_holder.dart';
import 'package:taapdeel/viewobject/item_location.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../location/item_location_first_view.dart';
import '../location/item_location_township_first_view.dart';

class TaapdeelPickerOption {
  final String id;
  final String titleKey;
  final String? subtitleKey;
  final String? emoji;

  const TaapdeelPickerOption({
    required this.id,
    required this.titleKey,
    this.subtitleKey,
    this.emoji,
  });
}

/// ======================================================
/// ✅ Standard BottomSheet Picker (same UI for gender/age/etc)
/// ======================================================
/// Call this from anywhere to open the same standardized picker UI.
/// Requires TaapdeelGlassBottomSheet + TaapdeelButton to exist in your project.
Future<void> showTaapdeelStandardPicker({
  required BuildContext context,
  required String title,
  required List<TaapdeelPickerOption> options,
  required int initialSelectedIndex,
  required void Function(int selectedIndex) onConfirm,
  required VoidCallback onClear,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (ctx) {
      return SafeArea(
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: TaapdeelGlassBottomSheet(
            child: TaapdeelStandardPickerSheet(
              title: title,
              options: options,
              initialSelectedIndex: initialSelectedIndex,
              onConfirm: (idx) {
                onConfirm(idx);
                Navigator.of(ctx).pop();
              },
              onClear: () {
                onClear();
                Navigator.of(ctx).pop();
              },
            ),
          ),
        ),
      );
    },
  );
}

/// ✅ The actual sheet UI
class TaapdeelStandardPickerSheet extends StatefulWidget {
  const TaapdeelStandardPickerSheet({
    Key? key,
    required this.title,
    required this.options,
    required this.initialSelectedIndex,
    required this.onConfirm,
    required this.onClear,
  }) : super(key: key);

  final String title;
  final List<TaapdeelPickerOption> options;
  final int initialSelectedIndex;
  final void Function(int selectedIndex) onConfirm;
  final VoidCallback onClear;

  @override
  State<TaapdeelStandardPickerSheet> createState() =>
      _TaapdeelStandardPickerSheetState();
}

class _TaapdeelStandardPickerSheetState
    extends State<TaapdeelStandardPickerSheet> {
  static const Color _strongBlue = Color(0xFF0FA3A6);

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final double maxHeight = MediaQuery.of(context).size.height * 0.70;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Title
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              widget.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // List
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: List<Widget>.generate(widget.options.length, (int i) {
                  final TaapdeelPickerOption o = widget.options[i];
                  final bool selected = (i == _selectedIndex);

                  final String title = o.titleKey.tr();
                  final String subtitle =
                  (o.subtitleKey ?? '').trim().isEmpty ? '' : o.subtitleKey!.tr();

                  return InkWell(
                    onTap: () => setState(() => _selectedIndex = i),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.60),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? _strongBlue.withValues(alpha: 0.55)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          if (o.emoji != null && o.emoji!.isNotEmpty) ...<Widget>[
                            Text(o.emoji!, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: selected ? _strongBlue : null,
                                  ),
                                ),
                                if (subtitle.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      subtitle,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle, color: _strongBlue, size: 22),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Actions
          Row(
            children: <Widget>[
              Expanded(
                child: TaapdeelButton(
                  label: 'cancel'.tr(),
                  isPrimary: false,
                  isExpanded: true,
                  onPressed: widget.onClear,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TaapdeelButton(
                  label: 'confirmation'.tr(),
                  isPrimary: true,
                  isExpanded: true,
                  onPressed: () {
                    if (_selectedIndex < 0 || _selectedIndex >= widget.options.length) {
                      // لو مفيش اختيار، اعتبره Clear (أو سيبه زي ما تحب)
                      widget.onClear();
                      return;
                    }
                    widget.onConfirm(_selectedIndex);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

/// Location controllers & holder
LocationParameterHolder locationParameterHolder =
LocationParameterHolder().getDefaultParameterHolder();

final TextEditingController searchCityNameController = TextEditingController();
final TextEditingController searchTownshipNameController =
TextEditingController();

class TaapdeelProfileSetupView extends StatefulWidget {
  const TaapdeelProfileSetupView({
    Key? key,
    this.nextRoute = RoutePaths.CategoryView,
    this.requireGenderAge = true,
  }) : super(key: key);

  final String nextRoute;
  final bool requireGenderAge;

  @override
  State<TaapdeelProfileSetupView> createState() =>
      _TaapdeelProfileSetupViewState();
}

class _TaapdeelProfileSetupViewState extends State<TaapdeelProfileSetupView>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;

  PsValueHolder? _psValueHolder;

  /// Did user choose sub location (township)?
  String _isSubLocation = '0';

  /// profile info
  String _selectedGender = ''; // 'male' | 'female'
  String _selectedAgeRange = ''; // id from _ageOptions

  /// ✅ Language (UI helper only)
  bool _isEnglish = false; // default Arabic

  static const Color _strongBlue = Color(0xFF1D4ED8);

  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  static const String _logoAsset = 'assets/images/Taapdeel_logo.png';

  /// ✅ All options use translation keys (NO inline strings)
  List<TaapdeelPickerOption> get _genderOptions =>
      const <TaapdeelPickerOption>[
        TaapdeelPickerOption(
          id: 'male',
          titleKey: 'profile_setup.gender_male',
        ),
        TaapdeelPickerOption(
          id: 'female',
          titleKey: 'profile_setup.gender_female',
        ),
      ];

  List<TaapdeelPickerOption> get _ageOptions => const <TaapdeelPickerOption>[
    TaapdeelPickerOption(
      id: '12-',
      titleKey: 'profile_setup.age_u12',
    ),
    TaapdeelPickerOption(
      id: '12-15',
      titleKey: 'profile_setup.age_12_15',
    ),
    TaapdeelPickerOption(
      id: '16-22',
      titleKey: 'profile_setup.age_16_22',
    ),
    TaapdeelPickerOption(
      id: '23-35',
      titleKey: 'profile_setup.age_23_35',
    ),
    TaapdeelPickerOption(
      id: '36-50',
      titleKey: 'profile_setup.age_36_50',
    ),
    TaapdeelPickerOption(
      id: '50+',
      titleKey: 'profile_setup.age_50_plus',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    // ✅ Arabic default (ar_DZ) and safe fallback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final Locale? current = EasyLocalization.of(context)?.locale;
      final List<Locale> supported =
          EasyLocalization.of(context)?.supportedLocales ??
              context.supportedLocales;

      final bool isSupported = current != null && supported.contains(current);

      if (!isSupported) {
        await _applyLanguage(false, silent: true); // force ar_DZ
        return;
      }

      setState(() {
        _isEnglish = (current.languageCode.toLowerCase() == 'en');
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  /// ============================================
  /// ✅ Locale safety: use ar_DZ / en_US (matches ar-DZ.json / en-US.json)
  /// ============================================
  Locale _pickSupportedLocale({required bool toEnglish}) {
    final List<Locale> supported =
        EasyLocalization.of(context)?.supportedLocales ??
            context.supportedLocales;

    final Locale target =
    toEnglish ? const Locale('en', 'US') : const Locale('ar', 'DZ');

    // 1) exact match (language + country)
    for (final Locale l in supported) {
      if ((l.languageCode.toLowerCase() ==
          target.languageCode.toLowerCase()) &&
          ((l.countryCode ?? '').toLowerCase() ==
              (target.countryCode ?? '').toLowerCase())) {
        return l;
      }
    }

    // 2) fallback by languageCode
    for (final Locale l in supported) {
      if (l.languageCode.toLowerCase() == target.languageCode.toLowerCase()) {
        return l;
      }
    }

    // 3) fallback: first supported
    return supported.isNotEmpty ? supported.first : const Locale('ar', 'DZ');
  }

  Future<void> _applyLanguage(bool toEnglish, {bool silent = false}) async {
    final Locale safeLocale = _pickSupportedLocale(toEnglish: toEnglish);

    // ✅ apply locale (EasyLocalization persists it if saveLocale=true in main)
    await context.setLocale(safeLocale);

    // ✅ Persist in your app storage (LanguageRepository)
    try {
      final LanguageProvider langProvider =
      Provider.of<LanguageProvider>(context, listen: false);

      // ✅ pick exact Language object ar_DZ / en_US (NOT only languageCode)
      Language chosen = PsConfig.defaultLanguage;

      for (final Language l in PsConfig.psSupportedLanguageList) {
        final String code = (l.languageCode ?? '').toLowerCase();
        final String cc = (l.countryCode ?? '').toLowerCase();
        if (code == safeLocale.languageCode.toLowerCase() &&
            cc == (safeLocale.countryCode ?? '').toLowerCase()) {
          chosen = l;
          break;
        }
      }

      await langProvider.addLanguage(chosen);

      // ✅ very important: prevent server/default from overriding later
      await langProvider.replaceUserChangesLocalLanguage(true);
    } catch (_) {}

    final bool en = safeLocale.languageCode.toLowerCase() == 'en';
    if (mounted) setState(() => _isEnglish = en);
  }

  /// ✅ Mini toggle (small pill top) - all labels from JSON
  Widget _buildMiniLanguageToggle() {
    final bool en = _isEnglish;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _miniLangChip(
            active: !en,
            labelKey: 'profile_setup.toggle_ar',
            tooltipKey: 'profile_setup.toggle_ar_tooltip',
            onTap: () => _applyLanguage(false),
          ),
          const SizedBox(width: 6),
          _miniLangChip(
            active: en,
            labelKey: 'profile_setup.toggle_en',
            tooltipKey: 'profile_setup.toggle_en_tooltip',
            onTap: () => _applyLanguage(true),
          ),
        ],
      ),
    );
  }

  Widget _miniLangChip({
    required bool active,
    required String labelKey,
    required String tooltipKey,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltipKey.tr(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? _strongBlue.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active
                  ? _strongBlue.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.10),
            ),
          ),
          child: Text(
            labelKey.tr(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: active ? _strongBlue : Colors.black.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ItemLocationRepository itemLocationRepo =
    Provider.of<ItemLocationRepository>(context, listen: false);

    _psValueHolder = Provider.of<PsValueHolder>(context, listen: false);

    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ItemLocationProvider>(
          lazy: false,
          create: (BuildContext ctx) {
            final ItemLocationProvider provider = ItemLocationProvider(
              repo: itemLocationRepo,
              psValueHolder: _psValueHolder,
            );
            return provider;
          },
        ),
      ],
      child: TaapdeelScaffold(
        safeTop: true,
        safeBottom: true,
        padding: EdgeInsets.zero,
        bottom: Builder(
          builder: (BuildContext context) {
            final ItemLocationProvider locationProvider =
            Provider.of<ItemLocationProvider>(context, listen: false);

            return Material(
              type: MaterialType.transparency, // ✅ يمنع أي خلفية
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TaapdeelButton(
                      label: 'profile_setup.intro_tour'.tr(),
                      isPrimary: true,
                      isExpanded: true,
                      onPressed: () =>
                          _onGoIntroPressed(context, locationProvider),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        body: Consumer<ItemLocationProvider>(
          builder: (BuildContext ctx, ItemLocationProvider locationProvider, _) {
            final ThemeData theme = Theme.of(context);
            final ColorScheme colorScheme = theme.colorScheme;

            final PsValueHolder valueHolder = _psValueHolder!;

            // City
            if (valueHolder.locationId != null && valueHolder.locationId != '') {
              searchCityNameController.text = valueHolder.locactionName ?? '';
              locationProvider.itemLocationId = valueHolder.locationId;
              locationProvider.itemLocationName = valueHolder.locactionName;
              locationProvider.itemLocationLat = valueHolder.locationLat;
              locationProvider.itemLocationLng = valueHolder.locationLng;
            }

            // Township
            if (valueHolder.locationTownshipId != '') {
              searchTownshipNameController.text =
                  valueHolder.locationTownshipName;
              locationProvider.itemLocationTownshipId =
                  valueHolder.locationTownshipId;
              locationProvider.itemLocationTownshipName =
                  valueHolder.locationTownshipName;
              locationProvider.itemLocationTownshipLat =
                  valueHolder.locationTownshipLat;
              locationProvider.itemLocationTownshipLng =
                  valueHolder.locationTownshipLng;
              _isSubLocation = PsConst.ONE;
            } else {
              _isSubLocation = '0';
            }

            // Gender/Age from ValueHolder
            try {
              if (_selectedGender.isEmpty &&
                  (valueHolder as dynamic).userGender != null) {
                _selectedGender = (valueHolder as dynamic).userGender as String;
              }
              if (_selectedAgeRange.isEmpty &&
                  (valueHolder as dynamic).userAgeRange != null) {
                _selectedAgeRange =
                (valueHolder as dynamic).userAgeRange as String;
              }
            } catch (_) {}

            final TaapdeelPickerOption? selectedGenderOpt = _genderOptions
                .where((o) => o.id == _selectedGender)
                .cast<TaapdeelPickerOption?>()
                .firstWhere((o) => o != null, orElse: () => null);

            final TaapdeelPickerOption? selectedAgeOpt = _ageOptions
                .where((o) => o.id == _selectedAgeRange)
                .cast<TaapdeelPickerOption?>()
                .firstWhere((o) => o != null, orElse: () => null);

            _genderController.text =
            (selectedGenderOpt?.titleKey ?? '').isEmpty
                ? ''
                : selectedGenderOpt!.titleKey.tr();

            _ageController.text = (selectedAgeOpt?.titleKey ?? '').isNotEmpty
                ? selectedAgeOpt!.titleKey.tr()
                : '';

            return Directionality(
              textDirection:
              _isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl,
              child: Stack(
                children: <Widget>[
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          PsDimens.space16,
                          PsDimens.space16,
                          PsDimens.space16,
                          24, // ✅ بدل 92
                        ),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: 80),
                            _buildTopLogo(theme),
                            const SizedBox(height: 8),
                            Text(
                              'profile_setup.title_hint'.tr(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.70),
                              ),
                            ),
                            const SizedBox(height: 60),
                            TaapdeelCard(
                              body: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  _buildGenderAgeRow(theme, colorScheme),
                                  const SizedBox(height: 14),
                                  Text(
                                    'profile_setup.location'.tr(),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildLocationRow(context, locationProvider),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),

                  // ✅ Small toggle on top
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 16,
                        end: 16,
                        top: 10,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.topEnd,
                       // child: _buildMiniLanguageToggle(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopLogo(ThemeData theme) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),

          child: Image.asset(
            _logoAsset,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildDirectLoginLink() {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          Navigator.pushNamed(context, RoutePaths.login_container);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            'profile_setup.direct_login'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: _strongBlue,
              decoration: TextDecoration.underline,
              decorationThickness: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderAgeRow(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'profile_setup.gender'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              TaapdeelTextField(
                controller: _genderController,
                hint: 'profile_setup.choose'.tr(),
                readOnly: true,
                onTap: _openGenderSheet,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'profile_setup.age_range'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              TaapdeelTextField(
                controller: _ageController,
                hint: 'profile_setup.choose'.tr(),
                readOnly: true,
                onTap: _openAgeSheet,
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _indexOfId(List<TaapdeelPickerOption> options, String selectedId) {
    for (int i = 0; i < options.length; i++) {
      if (options[i].id == selectedId) return i;
    }
    return -1;
  }

  Future<void> _openGenderSheet() async {
    final int initial = _indexOfId(_genderOptions, _selectedGender);

    await showTaapdeelStandardPicker(
      context: context,
      title: 'profile_setup.sheet_choose_gender'.tr(),
      options: _genderOptions,
      initialSelectedIndex: initial,
      onConfirm: (int selectedIndex) {
        setState(() {
          _selectedGender = _genderOptions[selectedIndex].id;
          _genderController.text = _genderOptions[selectedIndex].titleKey.tr();
        });
      },
      onClear: () {
        setState(() {
          _selectedGender = '';
          _genderController.text = '';
        });
      },
    );
  }

  Future<void> _openAgeSheet() async {
    final int initial = _indexOfId(_ageOptions, _selectedAgeRange);

    await showTaapdeelStandardPicker(
      context: context,
      title: 'profile_setup.sheet_choose_age'.tr(),
      options: _ageOptions,
      initialSelectedIndex: initial,
      onConfirm: (int selectedIndex) {
        setState(() {
          _selectedAgeRange = _ageOptions[selectedIndex].id;
          _ageController.text = _ageOptions[selectedIndex].titleKey.tr();
        });
      },
      onClear: () {
        setState(() {
          _selectedAgeRange = '';
          _ageController.text = '';
        });
      },
    );
  }

  /// ✅ BottomSheet Helper (MAX 75% height)
  Future<T?> _openSheet75<T>({required Widget child}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: child,
          ),
        );
      },
    );
  }

  /// Location row
  Widget _buildLocationRow(BuildContext context, ItemLocationProvider provider) {
    return SizedBox(
      height: 52,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: TaapdeelTextField(
              controller: searchCityNameController,
              hint: 'profile_setup.governorate'.tr(),
              readOnly: true,
              onTap: () => _pickCityOnly(context, provider),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TaapdeelTextField(
              controller: searchTownshipNameController,
              hint: 'profile_setup.area'.tr(),
              readOnly: true,
              onTap: () => _pickTownshipOnly(context, provider),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCityOnly(
      BuildContext context, ItemLocationProvider provider) async {
    final PsValueHolder valueHolder = _psValueHolder!;

    final ItemLocation? cityResult = await _openSheet75<ItemLocation?>(
      child: const ItemLocationFirstView(),
    );

    if (cityResult == null) {
      setState(() {
        if (valueHolder.locationId != null &&
            valueHolder.locationId!.isNotEmpty) {
          provider.itemLocationId = valueHolder.locationId;
          provider.itemLocationName = valueHolder.locactionName;
          provider.itemLocationLat = valueHolder.locationLat;
          provider.itemLocationLng = valueHolder.locationLng;
          searchCityNameController.text = valueHolder.locactionName ?? '';
        } else {
          provider.itemLocationId = '';
          provider.itemLocationName =
              Utils.getString(context, 'product_list__location_all');
          provider.itemLocationLat = '';
          provider.itemLocationLng = '';
          searchCityNameController.text = '';
        }
      });
      return;
    }

    provider.itemLocationId = cityResult.id;
    provider.itemLocationName = cityResult.name;
    provider.itemLocationLat = cityResult.lat;
    provider.itemLocationLng = cityResult.lng;

    setState(() {
      searchCityNameController.text = cityResult.name ?? '';

      // reset township when city changes
      searchTownshipNameController.text = '';
      provider.itemLocationTownshipId = '';
      provider.itemLocationTownshipName = '';
      provider.itemLocationTownshipLat = '';
      provider.itemLocationTownshipLng = '';
      _isSubLocation = '0';
    });
  }

  Future<void> _pickTownshipOnly(
      BuildContext context, ItemLocationProvider provider) async {
    if (provider.itemLocationId == null || provider.itemLocationId!.isEmpty) {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: 'profile_setup.select_governorate_first'.tr(),
          );
        },
      );
      return;
    }

    final PsValueHolder valueHolder = _psValueHolder!;

    await _openSheet75<void>(
      child: ItemLocationTownshipFirstView(cityId: provider.itemLocationId!),
    );

    setState(() {
      if (valueHolder.locationTownshipId != null &&
          valueHolder.locationTownshipId!.isNotEmpty) {
        provider.itemLocationTownshipId = valueHolder.locationTownshipId;
        provider.itemLocationTownshipName = valueHolder.locationTownshipName;
        provider.itemLocationTownshipLat = valueHolder.locationTownshipLat;
        provider.itemLocationTownshipLng = valueHolder.locationTownshipLng;

        searchTownshipNameController.text =
            valueHolder.locationTownshipName ?? '';
        _isSubLocation = PsConst.ONE;
      } else {
        provider.itemLocationTownshipId = '';
        provider.itemLocationTownshipName = '';
        provider.itemLocationTownshipLat = '';
        provider.itemLocationTownshipLng = '';
        searchTownshipNameController.text = '';
        _isSubLocation = '0';
      }
    });
  }

  bool _validateProfileInputs(
      BuildContext context, ItemLocationProvider locationProvider) {
    if (locationProvider.itemLocationId == null ||
        locationProvider.itemLocationId == '') {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, 'item_location__select_city'),
          );
        },
      );
      return false;
    }

    if (locationProvider.itemLocationTownshipId == null ||
        locationProvider.itemLocationTownshipId!.isEmpty) {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: 'profile_setup.please_select_area'.tr(),
          );
        },
      );
      return false;
    }

    if (widget.requireGenderAge) {
      if (_selectedGender.isEmpty) {
        showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: 'profile_setup.please_choose_gender'.tr(),
            );
          },
        );
        return false;
      }
      if (_selectedAgeRange.isEmpty) {
        showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: 'profile_setup.please_choose_age'.tr(),
            );
          },
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _saveProfileInputs(ItemLocationProvider locationProvider) async {
    await locationProvider.replaceItemLocationData(
      locationProvider.itemLocationId!,
      locationProvider.itemLocationName!,
      locationProvider.itemLocationLat!,
      locationProvider.itemLocationLng!,
    );

    await locationProvider.replaceItemLocationTownshipData(
      locationProvider.itemLocationTownshipId!,
      locationProvider.itemLocationId!,
      locationProvider.itemLocationTownshipName ??
          searchTownshipNameController.text,
      locationProvider.itemLocationTownshipLat!,
      locationProvider.itemLocationTownshipLng!,
    );

    await locationProvider.replaceIsSubLocation(_isSubLocation);

    final PsSharedPreferences prefs = PsSharedPreferences.instance;
    if (_selectedGender.isNotEmpty) {
      await prefs.replaceUserGender(_selectedGender);
    }
    if (_selectedAgeRange.isNotEmpty) {
      await prefs.replaceUserAgeRange(_selectedAgeRange);
    }
    await prefs.replaceIsUserAlreadyChoose(true);
  }

  Future<void> _onGoIntroPressed(
      BuildContext context, ItemLocationProvider locationProvider) async {
    if (!_validateProfileInputs(context, locationProvider)) {
      return;
    }

    await _saveProfileInputs(locationProvider);

    Navigator.pushReplacementNamed(context, RoutePaths.introSlider);
  }

  Future<void> _onGoCategoryPressed(
      BuildContext context, ItemLocationProvider locationProvider) async {
    if (!_validateProfileInputs(context, locationProvider)) {
      return;
    }

    await _saveProfileInputs(locationProvider);

    Navigator.pushReplacementNamed(
      context,
      RoutePaths.CategoryView,
      arguments: <String, dynamic>{
        'onTap': null,
        'onBoarding': true,
        'Discover': false,
      },
    );
  }
}
