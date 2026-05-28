import 'package:flutter/material.dart';

// 👈 المهم جداً: نستورد SubCategory من viewobject فقط
import 'package:taapdeel/viewobject/sub_category.dart';

class TaapdeelSubCategoryIconMapper {
  // ماب بين اسم الـ SubCategory ومسار الأيقونة 3D من الأصول
  static const Map<String, String> _icons = <String, String>{

    'امهات': 'assets/icons3d/moms.png',
    'مستلزمات الطفل': 'assets/icons3d/moms.png',
    'العنايه بالطفل': 'assets/icons3d/moms.png',
    'إكسسوارات': 'assets/icons3d/moms.png',
    'المنزل': 'assets/icons3d/Discover.png',
    'ادوات مدرسية': 'assets/icons3d/School.png',
    'كتب': 'assets/icons3d/books.png',
    'الكترونيات': 'assets/icons3d/electronics.png',
    'العاب': 'assets/icons3d/games.png',
    'رياضة': 'assets/icons3d/sports.png',
    'هوايات ومهن': 'assets/icons3d/tools.png',

    // إنجليزي (لو الـ API راجع أسماء إنجليزية)
    'Moms': 'assets/icons3d/moms.png',
    'Home': 'assets/icons3d/Discover.png',
    'School': 'assets/icons3d/School.png',
    'Books': 'assets/icons3d/books.png',
    'Electronics': 'assets/icons3d/electronics.png',
    'Games': 'assets/icons3d/games.png',
    'Sports': 'assets/icons3d/sports.png',
    'Tools': 'assets/icons3d/tools.png',
    // ...
  };

  static ImageProvider? iconFor(SubCategory sub) {
    final String name = (sub.name ?? '').trim();

    if (_icons.containsKey(name)) {
      return AssetImage(_icons[name]!);
    }

    // لو مفيش 3D icon للـ SubCategory → هنرجّع null عشان نستعمل fallback من السيرفر
    return null;
  }
}
