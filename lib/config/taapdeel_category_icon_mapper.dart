import 'package:flutter/material.dart';
import 'package:taapdeel/viewobject/category.dart';

/// يربط كل Category بأيقونة 3D من الـ assets
class TaapdeelCategoryIconMapper {
  // ✅ حسب الـ catId (الأفضل لو IDs ثابتة من الـ Backend)
  static const Map<String, String> _iconById = <String, String>{
    // مثال:
    // '1': 'assets/icons3d/kids.png',
    // '2': 'assets/icons3d/furniture.png',
    // '3': 'assets/icons3d/mobiles.png',
  };

  // ✅ Fallback حسب اسم الفئة (Arabic / English)
  static const Map<String, String> _iconByName = <String, String>{
    // عربي
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
  };

  /// يرجّع ImageProvider للأيقونة المناسبة أو null لو مفيش
  static ImageProvider? iconFor(Category cat) {
    // 1) جرّب حسب الـ ID
    final String? id = cat.catId;
    if (id != null && _iconById.containsKey(id)) {
      return AssetImage(_iconById[id]!);
    }

    // 2) جرّب حسب الاسم (normalize)
    final String name = (cat.catName ?? '').trim().toLowerCase();

    if (name.isNotEmpty) {
      // شيل التشكيل/مسافات إضافية بسيطة لو حابب
      final String normalized = name
          .replaceAll('أ', 'ا')
          .replaceAll('إ', 'ا')
          .replaceAll('آ', 'ا')
          .replaceAll('ى', 'ي');

      // دور في الماب بالـ key المناسب
      final String? path = _iconByName[normalized] ?? _iconByName[name];
      if (path != null) {
        return AssetImage(path);
      }
    }

    // 3) لو مفيش أيقونة معرّفة → null (الكارت يشتغل بدون Icon أو تحط default)
    return null;
  }
}
