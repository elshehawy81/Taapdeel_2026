import 'package:flutter/foundation.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import '../models/intro_models.dart';

class PersonaResolver {
  static IntroPersonaKey resolve(PsValueHolder? h, {bool debugLogs = false}) {
    final String genderRaw =
    (tryReadString(h, 'userGender', debugLogs: debugLogs) ?? '')
        .trim()
        .toLowerCase();

    final String ageRangeRaw =
    (tryReadString(h, 'userAgeRange', debugLogs: debugLogs) ?? '').trim();

    final int age = ageFromRange(ageRangeRaw);

    final bool isMale = genderRaw == 'male';
    final bool isFemale = genderRaw == 'female';
    final bool older = age >= 23;

    late final IntroPersonaKey result;

    if (!isMale && !isFemale) {
      // fallback لو لسه مفيش بيانات
      result = IntroPersonaKey.male23Plus;
    } else if (isMale && older) {
      result = IntroPersonaKey.male23Plus;
    } else if (isMale && !older) {
      result = IntroPersonaKey.maleUnder23;
    } else if (isFemale && older) {
      result = IntroPersonaKey.female23Plus;
    } else {
      result = IntroPersonaKey.femaleUnder23;
    }

    return result;
  }

  static int ageFromRange(String range) {
    final s = range.trim();
    if (s.isEmpty) return 0;

    if (s.endsWith('+')) {
      return int.tryParse(s.replaceAll('+', '').trim()) ?? 0;
    }

    if (s.endsWith('-') && s.length <= 3) {
      return int.tryParse(s.replaceAll('-', '').trim()) ?? 0;
    }

    final parts = s.split('-').map((e) => e.trim()).toList();
    if (parts.isNotEmpty) {
      return int.tryParse(parts.first) ?? 0;
    }
    return 0;
  }

  static String? tryReadString(
      PsValueHolder? h,
      String fieldName, {
        bool debugLogs = false,
      }) {
    if (h == null) return null;

    // 0) direct property access (الأهم عندك)
    try {
      final dynamic d = h;

      // تطبيع أسماء شائعة
      final List<String> candidates = <String>[
        fieldName,
        _toCamel(fieldName),
        _toSnake(fieldName),
      ].toSet().toList();

      for (final name in candidates) {
        try {
          // ignore: avoid_dynamic_calls
          final dynamic v = d
              .toJson; // بس عشان نلمس d ونضمن إنه dynamic فعلاً (مش ضروري)
        } catch (_) {}

        try {
          // ignore: avoid_dynamic_calls
          final dynamic v = (d as dynamic).__getattr__(name);
          // مش هيشتغل في Dart، بس هنسيبه catch
          if (v is String && v.trim().isNotEmpty) {
            if (debugLogs) debugPrint('✅ $fieldName via getattr($name) = $v');
            return v.trim();
          }
        } catch (_) {}

        try {
          // ✅ الطريقة الصحيحة: نجرب access معروف بالاسمين اللي نعرفهم
          if (name == 'userGender') {
            // ignore: avoid_dynamic_calls
            final dynamic v = (d as dynamic).userGender;
            if (v is String && v.trim().isNotEmpty) {
              if (debugLogs) debugPrint('✅ $fieldName via .userGender = $v');
              return v.trim();
            }
          }
          if (name == 'userAgeRange') {
            // ignore: avoid_dynamic_calls
            final dynamic v = (d as dynamic).userAgeRange;
            if (v is String && v.trim().isNotEmpty) {
              if (debugLogs) debugPrint('✅ $fieldName via .userAgeRange = $v');
              return v.trim();
            }
          }

          // fallback لأي property تانية بالـ dynamic (لو موجودة بنفس الاسم)
          // ignore: avoid_dynamic_calls
          final dynamic v = (d as dynamic)
              .toJson; // touch
          // ignore: avoid_dynamic_calls
          final dynamic vv = (d as dynamic);
          // ignore: unnecessary_statements
          vv;
        } catch (_) {}
      }
    } catch (_) {}



    // 3) index operator
    try {
      final dynamic d = h;
      // ignore: avoid_dynamic_calls
      final dynamic v = d[fieldName];
      if (v is String && v.trim().isNotEmpty) {
        if (debugLogs) debugPrint('✅ $fieldName via [] = $v');
        return v.trim();
      }
    } catch (_) {}

    if (debugLogs) debugPrint('❌ $fieldName not found');
    return null;
  }

  static String _toSnake(String s) {
    // userAgeRange -> user_age_range
    final reg = RegExp(r'([a-z0-9])([A-Z])');
    return s.replaceAllMapped(reg, (m) => '${m[1]}_${m[2]}').toLowerCase();
  }

  static String _toCamel(String s) {
    // user_age_range -> userAgeRange
    if (!s.contains('_')) return s;
    final parts = s.split('_');
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join();
  }
}
