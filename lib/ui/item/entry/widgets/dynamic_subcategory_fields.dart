import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_dropdown.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_standard_grid_picker.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_standard_picker.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_text_field.dart';

/// ===============================
/// Dynamic Fields Engine (Step 3)
/// ===============================
/// ✅ UI متوافق مع Taapdeel components.
/// ✅ البراند: BottomSheet باستخدام TaapdeelGlassBottomSheet + اختيار عبر TaapdeelChip
/// ✅ Dropdowns: TaapdeelDropdown
///
/// ✅ UPDATED: Layout -> كل حقلين في سطر (2 columns) تلقائيًا
/// - العناوين (section title) و الـ toggles و date picker و message boxes = Full width
///
/// ✅ FIXED/IMPROVED:
/// - منع إعادة إنشاء TextEditingController في كل build (كان بيكسر الفوكس ويصفّر النص أحيانًا)
/// - cache controllers per field + dispose
/// - Autocomplete بدون إعادة تعيين text كل rebuild (منع jump للـ cursor)
/// - لو initialValues اتغيرت (Edit) نعمل sync لو نفس التصنيف الفرعي

enum BrandPickerMode { autoComplete, bottomSheet }

/// ✅ UPDATED: Brands for 30 categories (and keeps existing ones)
const Map<String, List<String>> kBrandsBySubCategoryGroup =
<String, List<String>>{
  // ======================
  // 📚 BOOKS (NEW)
  // ======================
  'كتب أطفال': <String>[
    'Scholastic',
    'DK (Dorling Kindersley)',
    'Usborne',
    'Penguin Random House Children\'s',
    'HarperCollins Children\'s',
    'Egmont',
    'Walker Books',
    'Candlewick',
    'Oxford Children\'s',
    'Ladybird',
  ],
  'كتب إسلامية': <String>[
    'دار السلام',
    'Darussalam',
    'IIPH (International Islamic Publishing House)',
    'Dar Al-Manarah',
    'Safar Publications',
    'Kube Publishing',
    'Turath Publishing',
    'Al-Hidaayah',
    'Ta-Ha Publishers',
    'المعارف',
  ],
  'تطوير الذات والتربية': <String>[
    'HarperOne',
    'Hay House',
    'Penguin Random House',
    'Simon & Schuster',
    'Hachette',
    'Macmillan',
    'Bloomsbury',
    'Wiley',
    'Harvard Business Review Press',
    'Pearson',
  ],
  'لغات': <String>[
    'Oxford University Press',
    'Cambridge University Press',
    'Pearson',
    'Macmillan Education',
    'Collins',
    'Longman',
    'National Geographic Learning',
    'Barron\'s',
    'Kaplan',
    'Berlitz',
  ],
  'الكومبيوتر والتكنولوجيا': <String>[
    'O\'Reilly',
    'Packt',
    'No Starch Press',
    'Manning',
    'Apress',
    'Addison-Wesley',
    'Microsoft Press',
    'Wiley',
    'Pearson',
    'MIT Press',
  ],
  'العلوم': <String>[
    'National Geographic',
    'DK',
    'Smithsonian',
    'Oxford University Press',
    'Cambridge University Press',
    'MIT Press',
    'Pearson',
    'Elsevier',
    'Springer',
    'Nature Portfolio',
  ],

  // ======================
  // 🧸 GAMES & TOYS (NEW)
  // ======================
  'ألعاب أطفال': <String>[
    'LEGO',
    'Fisher-Price',
    'Hasbro',
    'Mattel',
    'Playmobil',
    'Melissa & Doug',
    'VTech',
    'LeapFrog',
    'Ravensburger',
    'Spin Master',
  ],
  'ألعاب خارجية': <String>[
    'Decathlon',
    'Nerf',
    'Intex',
    'Bestway',
    'Little Tikes',
    'Radio Flyer',
    'Step2',
    'Power Wheels',
    'Razor',
    'Franklin Sports',
  ],
  'العاب ورقية': <String>[
    'UNO (Mattel)',
    'Hasbro Gaming',
    'Ravensburger',
    'Asmodee',
    'Exploding Kittens',
    'Cartamundi',
    'Bicycle',
    'Devir',
    'Fantasy Flight Games',
    'Kosmos',
  ],
  'العاب تعليمية': <String>[
    'LeapFrog',
    'VTech',
    'Osmo',
    'ThinkFun',
    'SmartGames',
    'Learning Resources',
    'Educational Insights',
    'Melissa & Doug',
    'Clementoni',
    'National Geographic Kids',
  ],
  'سكوتر – عجلة أطفال': <String>[
    'Micro',
    'Razor',
    'Globber',
    'Decathlon',
    'Hudora',
    'Disney',
    'Smoby',
    'Chicco',
    'Oxelo',
    'Scoot & Ride',
  ],

  // ======================
  // 📱 ELECTRONICS (NEW)
  // ======================
  'موبايلات وتابلت': <String>[
    'Apple',
    'Samsung',
    'Huawei',
    'Xiaomi',
    'Oppo',
    'Realme',
    'Honor',
    'OnePlus',
    'Lenovo',
    'Nokia',
  ],
  'شرائح اتصال': <String>[
    'Vodafone',
    'Orange',
    'Etisalat',
    'WE',
    'Ooredoo',
    'Zain',
    'STC',
    'du',
    'Mobily',
    'Virgin Mobile',
  ],
  'كاميرات': <String>[
    'Canon',
    'Nikon',
    'Sony',
    'Fujifilm',
    'Panasonic',
    'GoPro',
    'DJI',
    'Olympus (OM System)',
    'Leica',
    'Insta360',
  ],
  'إكسسوارات إلكترونية': <String>[
    'Anker',
    'UGREEN',
    'Belkin',
    'Baseus',
    'Spigen',
    'Samsung',
    'Apple',
    'JBL',
    'Logitech',
    'TP-Link',
  ],
  'لاب توب – اكسسوارات': <String>[
    'Logitech',
    'Anker',
    'UGREEN',
    'Belkin',
    'Baseus',
    'Razer',
    'HP',
    'Dell',
    'Lenovo',
    'Microsoft',
  ],
  'أجهزة (كمبيوتر – شاشات)': <String>[
    'Dell',
    'HP',
    'Lenovo',
    'ASUS',
    'Acer',
    'Samsung',
    'LG',
    'MSI',
    'AOC',
    'Philips',
  ],

  // ======================
  // 🧵 HOBBIES (NEW)
  // ======================
  'اشغال يدوية': <String>[
    'Cricut',
    'Brother',
    'Singer',
    'DMC',
    'Faber-Castell',
    'Staedtler',
    'UHU',
    'Mod Podge',
    'Aleene\'s',
    '3M',
  ],
  'الصيد': <String>[
    'Shimano',
    'Daiwa',
    'Abu Garcia',
    'Penn',
    'Rapala',
    'Berkley',
    'Okuma',
    'Salmo',
    'Mustad',
    'Garmin',
  ],
  'ادوات طبية': <String>[
    'Omron',
    'Beurer',
    'Braun',
    'Microlife',
    'Rossmax',
    'Accu-Chek',
    'OneTouch',
    'Littmann',
    'Philips',
    'Medisana',
  ],
  'السيارات': <String>[
    'Toyota',
    'Hyundai',
    'Kia',
    'Nissan',
    'Chevrolet',
    'Ford',
    'BMW',
    'Mercedes-Benz',
    'Honda',
    'Volkswagen',
  ],
  'هندسة': <String>[
    'Bosch',
    'DEWALT',
    'Makita',
    'Stanley',
    'Black+Decker',
    'Hilti',
    'Milwaukee',
    'Metabo',
    'Einhell',
    'Total',
  ],
  'أدوات فنية': <String>[
    'Faber-Castell',
    'Staedtler',
    'Winsor & Newton',
    'Sakura',
    'Canson',
    'Derwent',
    'Mont Marte',
    'Talens',
    'Crayola',
    'Prismacolor',
  ],
  'خياطة وتطريز': <String>[
    'Singer',
    'Brother',
    'Janome',
    'Juki',
    'Bernina',
    'Pfaff',
    'DMC',
    'Madeira',
    'Gutermann',
    'Prym',
  ],

  // ======================
  // 🏠 HOME (NEW)
  // ======================
  'العناية بالمنزل': <String>[
    'Dettol',
    'Clorox',
    'Mr. Muscle',
    'Finish',
    'Persil',
    'Ariel',
    'Fairy',
    'Lysol',
    'Vileda',
    'Scotch-Brite',
  ],
  'شنط سفر': <String>[
    'Samsonite',
    'American Tourister',
    'Delsey',
    'Tumi',
    'Travelpro',
    'IT Luggage',
    'Antler',
    'Carlton',
    'Kamiliant',
    'Eastpak',
  ],
  'المطبخ والمائدة': <String>[
    'Tefal',
    'Moulinex',
    'Philips',
    'Braun',
    'Kenwood',
    'Bosch',
    'IKEA',
    'Luminarc',
    'Pyrex',
    'Arshia',
  ],
  'ديكور المنزل': <String>[
    'IKEA',
    'JYSK',
    'Home Centre',
    'Pottery Barn',
    'Zara Home',
    'H&M Home',
    'Home Box',
    'Homes r Us',
    'Habitat',
    'Dunelm',
  ],
  'اجهزة منزلية': <String>[
    'Samsung',
    'LG',
    'Bosch',
    'Siemens',
    'Toshiba',
    'Sharp',
    'Whirlpool',
    'Electrolux',
    'Zanussi',
    'Hoover',
  ],
  'مفروشات': <String>[
    'IKEA',
    'JYSK',
    'Home Centre',
    'Zara Home',
    'H&M Home',
    'Dunlopillo',
    'IKEA (Mattresses)',
    'Cottonil (Bedding)',
    'Marks & Spencer Home',
    'Pierre Cardin Home',
  ],

  // ======================
  // ✅ EXISTING GROUPS (kept as-is)
  // ======================
  'مستلزمات الطفل': <String>[
    'Chicco',
    'Philips Avent',
    'Pampers',
    'Huggies',
    'Babyjem',
    'Tommee Tippee',
    'Fisher-Price',
    'Graco',
    'Nuk',
    'Baby Love',
  ],
  'ملابس وأحذية': <String>[
    'Nike',
    'Adidas',
    'Puma',
    'Zara',
    'H&M',
    'LC Waikiki',
    'Defacto',
    'Pull&Bear',
    'Reebok',
    'Skechers',
  ],
  'إكسسوارات': <String>[
    'Ray-Ban',
    'Fossil',
    'Daniel Wellington',
    'Casio',
    'Guess',
    'Swatch',
    'Michael Kors',
    'Tommy Hilfiger',
    'Police',
    'Aldo',
  ],
  'العناية الشخصية': <String>[
    'Nivea',
    'Dove',
    'Garnier',
    'L\'Oréal',
    'Pantene',
    'Head & Shoulders',
    'Vaseline',
    'Gillette',
    'Rexona',
    'Johnson\'s',
  ],
  'أجهزة رياضية': <String>[
    'Decathlon',
    'Adidas',
    'Nike',
    'Reebok',
    'Bowflex',
    'NordicTrack',
    'Domyos',
    'York',
    'Everlast',
    'ProForm',
  ],
  'تنس طاولة': <String>[
    'Butterfly',
    'Stiga',
    'Donic',
    'DHS',
    'Joola',
    'Tibhar',
    'Cornilleau',
    'Killerspin',
    'Yasaka',
    'Xiom',
  ],
  'أدوات سباحة': <String>[
    'Speedo',
    'Arena',
    'TYR',
    'Zoggs',
    'Nike Swim',
    'Adidas Swim',
    'Intex',
    'Bestway',
    'Aqua Sphere',
    'Head',
  ],
  'تنس': <String>[
    'Wilson',
    'Babolat',
    'Head',
    'Yonex',
    'Prince',
    'Dunlop',
    'Tecnifibre',
    'Slazenger',
    'Lotto',
    'Nike',
  ],
  'اسكواش': <String>[
    'Dunlop',
    'Tecnifibre',
    'Head',
    'Prince',
    'Wilson',
    'Karakal',
    'Eye Rackets',
    'Salming',
    'Black Knight',
    'Harrow',
  ],
  'أدوات مكتبية': <String>[
    'Faber-Castell',
    'Staedtler',
    'Maped',
    'Pilot',
    'Bic',
    'Casio',
    'HP',
    'Canon',
    'Sharp',
    'Deli',
  ],
  'الزي المدرسي': <String>[
    'LC Waikiki',
    'Defacto',
    'Mothercare',
    'Marks & Spencer',
    'H&M',
    'Max',
    'Zara Kids',
    'Adidas',
    'Nike',
    'Local Brands',
  ],
  'شنط مدرسية': <String>[
    'Jansport',
    'Nike',
    'Adidas',
    'Puma',
    'American Tourister',
    'Samsonite',
    'Eastpak',
    'Reebok',
    'Fila',
    'Disney',
  ],
  'كتب مدرسية وخارجية': <String>[
    'Longman',
    'Oxford',
    'Cambridge',
    'Pearson',
    'Macmillan',
    'Collins',
    'الوزارة (مصري)',
    'Scholastic',
    'Al-Shamel',
    'Nahdet Misr',
  ],
  'أزياء تنكرية': <String>[
    'Disney',
    'Marvel',
    'DC Comics',
    'Rubie\'s',
    'Smiffys',
    'Party City',
    'Hasbro',
    'Barbie',
    'Paw Patrol',
    'Frozen',
  ],
  'ملابس أولاد': <String>[
    'Nike',
    'Adidas',
    'Zara Kids',
    'H&M Kids',
    'LC Waikiki',
    'Defacto',
    'Puma',
    'GAP Kids',
    'Carter\'s',
    'Mothercare',
  ],
  'أحذية رجالي': <String>[
    'Nike',
    'Adidas',
    'Clarks',
    'Ecco',
    'Skechers',
    'Timberland',
    'Aldo',
    'CAT',
    'Geox',
    'Rockport',
  ],
  'أحذية أولاد': <String>[
    'Nike',
    'Adidas',
    'Puma',
    'Skechers',
    'Reebok',
    'Clarks',
    'Crocs',
    'Geox',
    'H&M',
    'LC Waikiki',
  ],
  'ملابس رجالي': <String>[
    'Zara',
    'H&M',
    'LC Waikiki',
    'Defacto',
    'Adidas',
    'Nike',
    'Tommy Hilfiger',
    'Calvin Klein',
    'Boss',
    'Pull&Bear',
  ],
  'روايات وقصص': <String>[
    'Penguin',
    'HarperCollins',
    'Bloomsbury',
    'Random House',
    'دار الشروق',
    'دار نهضة مصر',
    'مكتبة جرير',
    'عصير الكتب',
    'كلمات',
    'آفاق',
  ],
  'ألعاب ذكاء وألغاز': <String>[
    'ThinkFun',
    'Ravensburger',
    'SmartGames',
    'Hasbro',
    'Melissa & Doug',
    'Clementoni',
    'Gigamic',
    'Goliath',
    'Spin Master',
    'Educational Insights',
  ],
  'ليجو وبازل': <String>[
    'LEGO',
    'LEGO Technic',
    'Ravensburger',
    'Clementoni',
    'Educa',
    'Hape',
    'BanBao',
    'Mega Bloks',
    'CubicFun',
    'Playmobil',
  ],
  'ألعاب إلكترونية': <String>[
    'Sony PlayStation',
    'Microsoft Xbox',
    'Nintendo',
    'Oculus',
    'HTC Vive',
    'Valve',
    'Ubisoft',
    'EA',
    'Activision',
    'Bandai Namco',
  ],
  'أجهزة ذكية': <String>[
    'Apple',
    'Samsung',
    'Huawei',
    'Xiaomi',
    'Oppo',
    'Realme',
    'Honor',
    'Fitbit',
    'Amazfit',
    'Google',
  ],
};

class DynamicSubCategoryFields extends StatefulWidget {
  const DynamicSubCategoryFields({
    Key? key,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.onChanged,
    this.initialValues = const <String, dynamic>{},
  }) : super(key: key);

  final String? subCategoryId;
  final String? subCategoryName;

  /// القيم الحالية (لو Edit)
  final Map<String, dynamic> initialValues;

  /// بيرجع Map كامل بعد أي تغيير
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<DynamicSubCategoryFields> createState() =>
      _DynamicSubCategoryFieldsState();
}

class _DynamicSubCategoryFieldsState extends State<DynamicSubCategoryFields> {
  late Map<String, dynamic> _values;

  /// ✅ cache controllers per field key (fix focus + text reset)
  final Map<String, TextEditingController> _controllers =
  <String, TextEditingController>{};

  /// ✅ اختر طريقة البراند هنا:
  /// - BrandPickerMode.bottomSheet (افضل UX للموبايل)
  /// - BrandPickerMode.autoComplete (اقتراحات أثناء الكتابة)
  final BrandPickerMode brandPickerMode = BrandPickerMode.bottomSheet;

  @override
  void initState() {
    super.initState();
    _values = <String, dynamic>{...widget.initialValues};
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DynamicSubCategoryFields oldWidget) {
    super.didUpdateWidget(oldWidget);

    // لو التصنيف الفرعي اتغير: امسح القيم السابقة وابدأ جديد
    final String oldKey =
    _normalize(oldWidget.subCategoryName ?? oldWidget.subCategoryId ?? '');
    final String newKey =
    _normalize(widget.subCategoryName ?? widget.subCategoryId ?? '');

    if (oldKey != newKey) {
      _values = <String, dynamic>{};
      _clearControllers(); // ✅ important
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(_values);
      });
      return;
    }

    // ✅ لو نفس التصنيف، لكن initialValues اتغيرت (Edit -> refresh)
    if (!mapEquals(oldWidget.initialValues, widget.initialValues)) {
      _values = <String, dynamic>{...widget.initialValues};
      _syncControllersFromValues();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(_values);
      });
    }
  }

  void _clearControllers() {
    for (final TextEditingController c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
  }

  TextEditingController _getCtrl(String keyName) {
    final TextEditingController ctrl =
    _controllers.putIfAbsent(keyName, () => TextEditingController());
    final String desired = (_values[keyName] ?? '').toString();

    // ✅ only update controller text if different (avoid cursor jumping)
    if (ctrl.text != desired) {
      ctrl.text = desired;
      ctrl.selection = TextSelection.fromPosition(
        TextPosition(offset: ctrl.text.length),
      );
    }
    return ctrl;
  }

  void _syncControllersFromValues() {
    for (final MapEntry<String, dynamic> e in _values.entries) {
      final String k = e.key;
      if (_controllers.containsKey(k)) {
        _getCtrl(k); // will sync text safely
      }
    }
  }

  String _normalize(String s) {
    return s
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('–', '-') // normalize dash
        .replaceAll('—', '-');
  }

  void _setValue(String key, dynamic val) {
    setState(() {
      if (val == null || (val is String && val.trim().isEmpty)) {
        _values.remove(key);
        // ✅ keep controller but clear text (so UI matches)
        if (_controllers.containsKey(key)) {
          _controllers[key]!.text = '';
        }
      } else {
        _values[key] = val;
        if (_controllers.containsKey(key)) {
          final TextEditingController c = _controllers[key]!;
          final String desired = val.toString();
          if (c.text != desired) {
            c.text = desired;
            c.selection = TextSelection.fromPosition(
              TextPosition(offset: c.text.length),
            );
          }
        }
      }
    });
    widget.onChanged(_values);
  }

  /// ---------- Brand Resolver ----------
  String? _resolveBrandGroupKey(String normalizedSubKey) {
    bool hasAny(List<String> needles) =>
        needles.any((n) => normalizedSubKey.contains(_normalize(n)));

    // =============================
    // ✅ NEW 30 Categories mapping
    // =============================

    // 📚 Books
    if (hasAny(<String>['كتب اطفال', 'كتب أطفال'])) return 'كتب أطفال';
    if (hasAny(<String>[
      'كتب اسلاميه',
      'كتب اسلامية',
      'كتب إسلامية',
      'اسلامية'
    ])) return 'كتب إسلامية';
    if (hasAny(<String>['تطوير الذات', 'التربية', 'تربيه'])) {
      return 'تطوير الذات والتربية';
    }
    if (hasAny(<String>['لغات', 'لغة'])) return 'لغات';
    if (hasAny(<String>[
      'الكومبيوتر',
      'الكمبيوتر',
      'تكنولوجيا',
      'التكنولوجيا',
      'تقنيه',
      'تقنية'
    ])) return 'الكومبيوتر والتكنولوجيا';
    if (hasAny(<String>['العلوم', 'علم'])) return 'العلوم';

    // 🧸 Games & Toys
    if (hasAny(<String>['العاب اطفال', 'ألعاب أطفال'])) return 'ألعاب أطفال';
    if (hasAny(<String>['العاب خارجية', 'ألعاب خارجية', 'خارجيه'])) {
      return 'ألعاب خارجية';
    }
    if (hasAny(<String>['العاب ورقيه', 'ألعاب ورقية', 'ورقيه', 'ورقية'])) {
      return 'العاب ورقية';
    }
    if (hasAny(<String>[
      'العاب تعليمية',
      'ألعاب تعليمية',
      'تعليميه',
      'تعليمية'
    ])) return 'العاب تعليمية';
    if (hasAny(<String>['سكوتر', 'عجلة', 'عجله'])) return 'سكوتر – عجلة أطفال';

    // 📱 Electronics
    if (hasAny(<String>['موبايلات', 'موبايل', 'تابلت', 'tablet', 'mobile'])) {
      return 'موبايلات وتابلت';
    }
    if (hasAny(<String>['شرائح', 'شريحة', 'شرايح', 'sim'])) return 'شرائح اتصال';
    if (hasAny(<String>['كاميرات', 'كاميرا', 'camera'])) return 'كاميرات';
    if (hasAny(<String>[
      'اكسسوارات الكترونية',
      'إكسسوارات إلكترونية',
      'اكسسوارات إلكترونية',
      'الكترونيات',
      'الكترونية'
    ])) {
      return 'إكسسوارات إلكترونية';
    }
    if (hasAny(<String>[
      'لاب توب - اكسسوارات',
      'لاب توب – اكسسوارات',
      'لاب توب',
      'اكسسوارات لاب',
      'laptop accessories'
    ])) {
      return 'لاب توب – اكسسوارات';
    }
    if (hasAny(<String>[
      'اجهزة (كمبيوتر',
      'أجهزة (كمبيوتر',
      'كمبيوتر - شاشات',
      'كمبيوتر – شاشات',
      'شاشات',
      'monitors'
    ])) {
      return 'أجهزة (كمبيوتر – شاشات)';
    }

    // 🧵 Hobbies
    if (hasAny(<String>['اشغال يدوية', 'أشغال يدوية', 'handmade'])) {
      return 'اشغال يدوية';
    }
    if (hasAny(<String>['الصيد', 'صيد'])) return 'الصيد';
    if (hasAny(<String>['ادوات طبية', 'أدوات طبية', 'medical'])) {
      return 'ادوات طبية';
    }
    if (hasAny(<String>['السيارات', 'سياره', 'سيارة'])) return 'السيارات';
    if (hasAny(<String>['هندسة', 'هندسه', 'tools'])) return 'هندسة';
    if (hasAny(<String>['ادوات فنية', 'أدوات فنية', 'فنية', 'رسم', 'art'])) {
      return 'أدوات فنية';
    }
    if (hasAny(<String>['خياطة', 'تطريز', 'sewing'])) return 'خياطة وتطريز';

    // 🏠 Home
    if (hasAny(<String>['العناية بالمنزل', 'العنايه بالمنزل', 'cleaning'])) {
      return 'العناية بالمنزل';
    }
    if (hasAny(<String>['شنط سفر', 'travel'])) return 'شنط سفر';
    if (hasAny(<String>['المطبخ', 'المائدة', 'المائده'])) {
      return 'المطبخ والمائدة';
    }
    if (hasAny(<String>['ديكور المنزل', 'ديكور'])) return 'ديكور المنزل';
    if (hasAny(<String>['اجهزة منزلية', 'أجهزة منزلية', 'اجهزه منزليه'])) {
      return 'اجهزة منزلية';
    }
    if (hasAny(<String>['مفروشات'])) return 'مفروشات';

    // =============================
    // ✅ Existing old mappings
    // =============================
    if (hasAny(<String>['مستلزمات الطفل'])) return 'مستلزمات الطفل';

    // تخصيصات أدق
    if (hasAny(<String>['ملابس اولاد'])) return 'ملابس أولاد';
    if (hasAny(<String>['ملابس رجالي'])) return 'ملابس رجالي';
    if (hasAny(<String>['احذيه رجالي', 'أحذية رجالي'])) return 'أحذية رجالي';
    if (hasAny(<String>['احذيه اولاد', 'أحذية أولاد'])) return 'أحذية أولاد';

    // عام ملابس/أحذية
    if (hasAny(<String>['ملابس', 'احذيه', 'أحذية', 'حذاء'])) {
      return 'ملابس وأحذية';
    }

    if (hasAny(<String>['اكسسوارات', 'إكسسوارات'])) return 'إكسسوارات';
    if (hasAny(<String>['العنايه الشخصيه', 'العناية الشخصية'])) {
      return 'العناية الشخصية';
    }

    if (hasAny(<String>['اجهزه رياضيه', 'أجهزة رياضية'])) return 'أجهزة رياضية';
    if (hasAny(<String>['تنس طاوله', 'تنس طاولة'])) return 'تنس طاولة';
    if (hasAny(<String>['سباحه', 'أدوات سباحة'])) return 'أدوات سباحة';

    // Tennis vs Squash
    if (hasAny(<String>['اسكواش', 'سكواش', 'squash'])) return 'اسكواش';
    if (hasAny(<String>['تنس'])) return 'تنس';

    if (hasAny(<String>['ادوات مكتبيه', 'أدوات مكتبية', 'مكتبيه'])) {
      return 'أدوات مكتبية';
    }
    if (hasAny(<String>['الزي المدرسي'])) return 'الزي المدرسي';
    if (hasAny(<String>['شنط مدرس', 'شنط مدرسية'])) return 'شنط مدرسية';

    if (hasAny(<String>['كتب مدرسية', 'خارجية'])) return 'كتب مدرسية وخارجية';
    if (hasAny(<String>['روايات', 'قصص'])) return 'روايات وقصص';

    if (hasAny(<String>['ازياء تنكرية', 'أزياء تنكرية'])) return 'أزياء تنكرية';

    if (hasAny(<String>['العاب ذكاء', 'ألغاز'])) return 'ألعاب ذكاء وألغاز';
    if (hasAny(<String>['ليجو', 'بازل'])) return 'ليجو وبازل';
    if (hasAny(<String>[
      'بلايستيشن',
      'playstation',
      'vr',
      'العاب الكترونيه',
      'ألعاب إلكترونية'
    ])) return 'ألعاب إلكترونية';

    if (hasAny(<String>['اجهزه ذكيه', 'أجهزة ذكية', 'smart'])) {
      return 'أجهزة ذكية';
    }

    return null;
  }

  List<String> _brandsForCurrentSubCategory() {
    final String key = _normalize(widget.subCategoryName ?? '');
    final String? group = _resolveBrandGroupKey(key);
    if (group == null) return const <String>[];
    return kBrandsBySubCategoryGroup[group] ?? const <String>[];
  }

  // ============================================================
  // ✅ NEW: Layout helper -> كل حقلين في سطر + Full width rules
  // ============================================================
  List<Widget> _pairFields(List<Widget> fields) {
    final List<Widget> out = <Widget>[];

    int i = 0;
    while (i < fields.length) {
      final Widget a = fields[i];

      // 1) Full width item -> add and move by 1 only
      if (_isFullWidth(a)) {
        out.add(a);
        i += 1;
        continue;
      }

      // 2) If no second item -> single row + spacer
      if (i + 1 >= fields.length) {
        out.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: a),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        );
        i += 1;
        continue;
      }

      final Widget b = fields[i + 1];

      // 3) Second item is full width -> show first alone, then second as full width
      if (_isFullWidth(b)) {
        out.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: a),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        );
        out.add(b);
        i += 2;
        continue;
      }

      // 4) Normal pair
      out.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: a),
            const SizedBox(width: 12),
            Expanded(child: b),
          ],
        ),
      );
      i += 2;
    }

    return out;
  }

  /// ✅ decide which widgets should stay full-width
  bool _isFullWidth(Widget w) {
    // Section titles are Padding(Text...)
    if (w is Padding) return true;

    // The "select subcategory first" message box is Container with grey border
    if (w is Container) {
      final Decoration? d = w.decoration;
      if (d is BoxDecoration) {
        final Color? c = d.color;
        if (c != null && c.opacity <= 0.15) return true;
      }
    }

    // Our toggle/date picker are Containers with padding/shadow -> keep full-width
    // (we mark them via Key in builders below)
    final Key? k = w.key;
    if (k is ValueKey<String>) {
      if (k.value.startsWith('full:')) return true;
    }

    return false;
  }

  Widget _brandField({
    required String keyName,
    required String label,
    String? hint,
    TextInputType? keyboardType,
  })
  {
    final List<String> brands = _brandsForCurrentSubCategory();
    final TextEditingController ctrl = _getCtrl(keyName);

    // لو مفيش براندات مرتبطة => حقل نص عادي
    if (brands.isEmpty) {
      return _textField(
        keyName: keyName,
        label: label,
        hint: hint ?? '',
        keyboardType: keyboardType,
      );
    }

    if (brandPickerMode == BrandPickerMode.autoComplete) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Autocomplete<String>(
          initialValue: TextEditingValue(text: ctrl.text),
          optionsBuilder: (TextEditingValue v) {
            final String q = v.text.trim().toLowerCase();
            if (q.isEmpty) return brands.take(10);
            return brands.where((b) => b.toLowerCase().contains(q)).take(10);
          },
          onSelected: (String v) => _setValue(keyName, v),
          fieldViewBuilder: (context, textCtrl, focusNode, onSubmit) {
            // ✅ لا تعيد تعيين text هنا كل مرة (بيعمل cursor jump)
            if (textCtrl.text != ctrl.text) {
              textCtrl.text = ctrl.text;
              textCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: textCtrl.text.length),
              );
            }

            return TaapdeelTextField(
              controller: textCtrl,
              label: label,
              hint: hint ?? '',
              keyboardType: keyboardType,
              textInputAction: TextInputAction.next,
              onChanged: (v) => _setValue(keyName, v.trim()),
            );
          },
        ),
      );
    }

    // ✅ BottomSheet mode (TaapdeelGlassBottomSheet)
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final String? selected = await showTaapdeelStandardGridPicker<String>(
            context: context,
            title: label,
            options: brands,
            selectedId: (_values[keyName] ?? '').toString(),
            idGetter: (String v) => v,
            labelGetter: (String v) => v,
          );

          if (selected != null) {
            _setValue(keyName, selected);
          }
        },

        child: IgnorePointer(
          child: TaapdeelTextField(
            controller: ctrl,
            label: label,
            hint: hint ?? 'اختر من القائمة',
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }

  Widget _standardPickerField({
    required String keyName,
    required String label,
    required List<String> items,
    String? hint,
  }) {
    final TextEditingController ctrl = _getCtrl(keyName);
    final String currentValue = (_values[keyName] ?? '').toString();

    final List<TaapdeelPickerOption> options = items
        .map(
          (e) => TaapdeelPickerOption(
        id: e,
            title: e,
      ),
    )
        .toList();

    int initialIndex = 0;
    final int foundIndex = items.indexOf(currentValue);
    if (foundIndex != -1) {
      initialIndex = foundIndex;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showTaapdeelStandardPicker(
            context: context,
            title: label,
            options: options,
            initialSelectedIndex: initialIndex,
            onConfirm: (int selectedIndex) {
              _setValue(keyName, items[selectedIndex]);
            },
            onClear: () {
              _setValue(keyName, '');
            },
          );
        },
        child: IgnorePointer(
          child: TaapdeelTextField(
            controller: ctrl,
            label: label,
            hint: hint ?? 'اختر',
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }

  /// ---------- UI Widgets ----------

  Widget _textField({
    required String keyName,
    required String label,
    String? hint,
    TextInputType? keyboardType,
  }) {
    final TextEditingController ctrl = _getCtrl(keyName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TaapdeelTextField(
        controller: ctrl,
        label: label,
        hint: hint ?? '',
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        onChanged: (v) => _setValue(keyName, v.trim()),
      ),
    );
  }

  Widget _dropdown({
    required String keyName,
    required String label,
    required List<String> items,
    String? hint,
  }) {
    final String? current =
    (_values[keyName] is String) ? _values[keyName] as String : null;
    final String? value =
    (current != null && current.trim().isNotEmpty && items.contains(current))
        ? current
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TaapdeelDropdown<String>(
        label: label,
        hint: hint,
        items: items,
        value: value,
        itemLabelBuilder: (String v) => v,
        onChanged: (String? v) => _setValue(keyName, v),
      ),
    );
  }

  Widget _toggle({
    required String keyName,
    required String label,
    String? subtitle,
  }) {
    final bool val =
    (_values[keyName] is bool) ? _values[keyName] as bool : false;

    return Container(
      key: ValueKey<String>('full:toggle:$keyName'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F2E57),
                  ),
                ),
                if (subtitle != null && subtitle.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F2E57).withOpacity(0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: val,
            onChanged: (bool v) => _setValue(keyName, v),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(String keyName, {String label = 'تاريخ'}) async {
    final DateTime now = DateTime.now();
    final DateTime first = DateTime(now.year - 10);
    final DateTime last = DateTime(now.year + 10);

    DateTime initial = now;
    final String? existing =
    (_values[keyName] is String) ? _values[keyName] as String : null;
    if (existing != null && existing.contains('-')) {
      try {
        initial = DateTime.parse(existing);
      } catch (_) {}
    }

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );

    if (selected != null) {
      final String formatted =
          '${selected.year.toString().padLeft(4, '0')}-'
          '${selected.month.toString().padLeft(2, '0')}-'
          '${selected.day.toString().padLeft(2, '0')}';
      _setValue(keyName, formatted);
    }
  }

  Widget _datePicker({
    required String keyName,
    required String label,
    String? hint,
  }) {
    final String value = (_values[keyName] ?? '').toString();

    return Container(
      key: ValueKey<String>('full:date:$keyName'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _pickDate(keyName, label: label),
        child: Row(
          children: <Widget>[
            const Icon(Icons.date_range_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F2E57),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isNotEmpty ? value : (hint ?? 'اضغط لاختيار التاريخ'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F2E57).withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  /// ---------- Resolver ----------
  List<Widget> _buildFieldsForSubCategory() {
    final String subName = widget.subCategoryName ?? '';
    final String key = _normalize(subName);

    // لو مفيش subcategory مختارة
    if (key.isEmpty) {
      return <Widget>[
        Container(
          key: const ValueKey<String>('full:empty_message'),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.25)),
          ),
          child: Text(
            'اختر تصنيف فرعي أولاً لعرض الحقول الخاصة به.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ];
    }

    bool hasAny(List<String> needles) =>
        needles.any((n) => key.contains(_normalize(n)));

    // =============================
    // 👶 مستلزمات الطفل
    // =============================
    if (hasAny(<String>['مستلزمات الطفل'])) {
      return <Widget>[
      //  _sectionTitle('👶 مستلزمات الطفل'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر البراند'),
        _standardPickerField(
          keyName: 'kid_age_range',
          label: 'العمر المناسب',
          hint: 'اختر',
          items: const <String>[
            '0-6 شهور',
            '6-12 شهر',
            '1-3 سنوات',
            '3-6 سنوات',
            '6-9 سنوات',
            '9-12 سنة',
            '+12'
          ],
        ),
      ];
    }

    // =============================
    // 💍 إكسسوارات
    // =============================
    if (hasAny(<String>['اكسسوارات', 'إكسسوارات'])) {
      return <Widget>[
       // _sectionTitle('💍 إكسسوارات'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر البراند'),
      ];
    }

    // =============================
    // 🧴 العناية الشخصية
    // =============================
    if (hasAny(<String>['العنايه الشخصيه', 'العناية الشخصية'])) {
      return <Widget>[
       // _sectionTitle('🧴 العناية الشخصية'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر البراند'),
      ];
    }

    // =============================
    // 🏋️ أجهزة رياضية
    // =============================
    if (hasAny(<String>['اجهزه رياضيه', 'أجهزة رياضية'])) {
      return <Widget>[
       // _sectionTitle('🏋️ أجهزة رياضية'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر البراند'),
      ];
    }

    // =============================
    // 🏓 تنس طاولة
    // =============================
    if (hasAny(<String>['تنس طاوله', 'تنس طاولة'])) {
      return <Widget>[
       // _sectionTitle('🏓 تنس طاولة'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر البراند'),

      ];
    }

    // =============================
    // 🏊 أدوات سباحة
    // =============================
    if (hasAny(<String>['سباحه', 'أدوات سباحة'])) {
      return <Widget>[
        //_sectionTitle('🏊 أدوات سباحة'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر البراند'),
        _textField(keyName: 'size', label: 'المقاس'),
      ];
    }

    // =============================
    // 🎾 تنس / 🏸 اسكواش
    // =============================
    if (hasAny(<String>['تنس', 'اسكواش', 'سكواش', 'squash'])) {
      return <Widget>[
       // _sectionTitle('🎾 تنس / 🏸 اسكواش'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر البراند'),

        _textField(keyName: 'size_or_weight', label: 'المقاس / الوزن'),

      ];
    }

    // =============================
    // ✏️ أدوات مكتبية
    // =============================
    if (hasAny(<String>['ادوات مكتبيه', 'أدوات مكتبية', 'مكتبيه'])) {
      return <Widget>[
        //_sectionTitle('✏️ أدوات مكتبية'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر البراند'),

      ];
    }

    // =============================
    // 🎒 الزي المدرسي
    // =============================
    if (hasAny(<String>['الزي المدرسي'])) {
      return <Widget>[
       // _sectionTitle('🎒 الزي المدرسي'),
        _standardPickerField(
          keyName: 'education_stage',
          label: 'المرحلة التعليمية',
          hint: 'اختر',
          items: const <String>['KG', 'ابتدائي', 'إعدادي', 'ثانوي'],
        ),
        _textField(keyName: 'size', label: 'المقاس'),

        _textField(keyName: 'school_optional', label: 'المدرسة (اختياري)'),
      ];
    }

    // =============================
    // 🎒 شنط مدرسية
    // =============================
    if (hasAny(<String>['شنط مدرس', 'شنط مدرسية'])) {
      return <Widget>[
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر البراند'),

      ];
    }

    // =============================
    // 📚 كتب
    // =============================
    if (hasAny(<String>[
      'كتاب',
      'كتب',
      'روايات',
      'قصص',
      'لغات',
      'تطوير الذات',
      'التربية',
      'اسلامية',
      'إسلامية',
      'الكومبيوتر',
      'الكمبيوتر',
      'التكنولوجيا',
      'العلوم'
    ])) {
      final List<Widget> fields = <Widget>[
       // _sectionTitle('📚 معلومات الكتاب'),
        _standardPickerField(
          keyName: 'language',
          label: 'اللغة',
          hint: 'اختر',
          items: const <String>['عربي', 'English', 'Français', 'Deutsch', 'أخرى'],
        ),
        _brandField(keyName: 'brand', label: 'دار/براند', hint: 'اختر من القائمة'),
      ];

      if (hasAny(<String>['كتب اطفال', 'كتب أطفال'])) {
        fields.addAll(<Widget>[
          _standardPickerField(
            keyName: 'kid_age_range',
            label: 'العمر المناسب',
            hint: 'اختر',
            items: const <String>['0-3', '3-6', '6-9', '9-12', '+12'],
          ),
          _toggle(keyName: 'illustrated', label: 'مصورة؟ ✔️'),
        ]);
      }

      if (hasAny(<String>['كتب اسلاميه', 'كتب اسلامية', 'كتب إسلامية'])) {
        fields.addAll(<Widget>[
          _standardPickerField(
            keyName: 'islamic_field',
            label: 'المجال',
            hint: 'اختر',
            items: const <String>['فقه', 'تفسير', 'حديث', 'سيرة', 'عقيدة', 'أخرى'],
          ),
        ]);
      }

      if (hasAny(<String>['كتب مدرسية', 'خارجية'])) {
        fields.addAll(<Widget>[
          _textField(
            keyName: 'grade',
            label: 'الصف الدراسي',
            hint: 'مثال: 6 ابتدائي',
          ),
          _standardPickerField(
            keyName: 'curriculum',
            label: 'المنهج',
            hint: 'اختر',
            items: const <String>['مصري', 'دولي', 'IG', 'American', 'IB', 'أخرى'],
          ),
        ]);
      }


      return fields;
    }

    // =============================
    // 🧩 ألعاب / ليجو / بازل / سكوتر...
    // =============================
    if (hasAny(<String>[
      'العاب',
      'ألعاب',
      'ليجو',
      'بازل',
      'الغاز',
      'ألغاز',
      'ورقيه',
      'ورقية',
      'سكوتر',
      'عجله',
      'عجلة'
    ])) {
      final List<Widget> fields = <Widget>[
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر من القائمة'),
      ];



      return fields;
    }

    // =============================
    // 📱 موبايلات / تابلت
    // =============================
    if (hasAny(<String>['موبايل', 'موبايلات', 'تابلت', 'tablet', 'mobile'])) {
      return <Widget>[
       // _sectionTitle('📱 موبايلات وتابلت'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر من القائمة'),

        _textField(
          keyName: 'battery_health',
          label: 'حالة البطارية',
          hint: 'مثال: 90%',
        ),
      ];
    }

    // =============================
    // 📶 شرائح اتصال
    // =============================
    if (hasAny(<String>['شريحه', 'شرائح', 'شرايح', 'sim'])) {
      return <Widget>[
       // _sectionTitle('📶 شرائح اتصال'),
        _brandField(keyName: 'brand', label: 'الشركة', hint: 'اختر من القائمة'),
        _textField(
          keyName: 'plan',
          label: 'الباقة (اختياري)',
          hint: 'مثال: 20GB / مكالمات',
        ),
      ];
    }

    // =============================
    // 📷 كاميرات
    // =============================
    if (hasAny(<String>['كاميرا', 'كاميرات', 'camera'])) {
      return <Widget>[
       // _sectionTitle('📷 كاميرات'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر من القائمة'),
      ];
    }

    // =============================
    // 🔌 إكسسوارات إلكترونية
    // =============================
    if (hasAny(<String>['إكسسوارات إلكترونية', 'اكسسوارات الكترونية', 'الكترونيات'])) {
      return <Widget>[
       // _sectionTitle('🔌 إكسسوارات إلكترونية'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر من القائمة'),

      ];
    }

    // =============================
    // 💻 لاب توب / كمبيوتر / شاشات
    // =============================
    if (hasAny(<String>['لاب', 'laptop', 'كمبيوتر', 'computer', 'شاشات', 'monitors'])) {
      return <Widget>[
       // _sectionTitle('💻 أجهزة كمبيوتر / لاب توب / شاشات'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر من القائمة'),
      ];
    }

    // =============================
    // ⌚ أجهزة ذكية
    // =============================
    if (hasAny(<String>['اجهزه ذكيه', 'أجهزة ذكية', 'smart'])) {
      return <Widget>[
        //_sectionTitle('⌚ أجهزة ذكية'),
        _brandField(keyName: 'brand', label: 'براند', hint: 'اختر من القائمة'),

      ];
    }

    // =============================
    // 🎮 ألعاب إلكترونية (لوحدها)
    // =============================
    if (hasAny(<String>[
      'بلايستيشن',
      'playstation',
      'vr',
      'العاب الكترونيه',
      'ألعاب إلكترونية'
    ])) {
      return <Widget>[
       // _sectionTitle('🎮 ألعاب إلكترونية'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر من القائمة'),
        _standardPickerField(
          keyName: 'platform',
          label: 'المنصة',
          hint: 'اختر',
          items: const <String>['PS4', 'PS5', 'VR', 'PC', 'Xbox', 'Switch', 'أخرى'],
        ),
      ];
    }

    // =============================
    // 🚗 سيارات
    // =============================
    if (hasAny(<String>['السيارات', 'سياره', 'سيارة'])) {
      return <Widget>[
       // _sectionTitle('🚗 السيارات'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر من القائمة'),
      ];
    }

    // =============================
    // 🧵 اشغال يدوية / خياطة / أدوات فنية / هندسة / صيد / أدوات طبية
    // =============================
    if (hasAny(<String>[
      'اشغال يدوية',
      'خياطة',
      'تطريز',
      'ادوات فنية',
      'هندسة',
      'الصيد',
      'ادوات طبية'
    ])) {
      return <Widget>[
       // _sectionTitle('🧰 تفاصيل إضافية'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر من القائمة'),

      ];
    }

    // =============================
    // 🏠 أجهزة منزلية / مفروشات / مطبخ / ديكور / عناية بالمنزل / شنط سفر
    // =============================
    if (hasAny(<String>[
      'اجهزه منزليه',
      'أجهزة منزلية',
      'مفروشات',
      'المطبخ',
      'المائده',
      'ديكور',
      'ديكور المنزل',
      'العنايه بالمنزل',
      'العناية بالمنزل',
      'شنط سفر'
    ])) {
      final List<Widget> fields = <Widget>[
       // _sectionTitle('🏠 تفاصيل إضافية'),
        _brandField(keyName: 'brand', label: 'البراند', hint: 'اختر من القائمة'),
      ];

      return fields;
    }

    // =============================
    // Default (Fallback
    // =============================
    return <Widget>[
     // _sectionTitle('حقول إضافية (اختياري)'),
      _brandField(keyName: 'brand', label: 'البراند (اختياري)', hint: 'اختر/اكتب'),
      _textField(keyName: 'type', label: ' المواصفات (اختياري)'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> rawFields = _buildFieldsForSubCategory();
    final List<Widget> fields = _pairFields(rawFields);

    // Debug (اختياري)
    // final String pretty = const JsonEncoder.withIndent('  ').convert(_values);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: PsDimens.space12),
        ...fields,
        const SizedBox(height: PsDimens.space8),
      ],
    );
  }
}
