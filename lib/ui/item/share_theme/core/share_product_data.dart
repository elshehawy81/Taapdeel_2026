import 'dart:convert';

import 'package:taapdeel/viewobject/product.dart';

String shareSafeString(dynamic value) {
  final String text = (value ?? '').toString().trim();
  if (text.toLowerCase() == 'null') return '';
  return text;
}

bool shareHas(dynamic value) => shareSafeString(value).isNotEmpty;

int shareToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString().trim()) ?? 0;
}

Map<String, dynamic> shareParseMap(dynamic raw) {
  try {
    if (raw == null) return <String, dynamic>{};
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);

    final String text = shareSafeString(raw);
    if (text.isEmpty) return <String, dynamic>{};

    final dynamic decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } catch (_) {}

  return <String, dynamic>{};
}

bool shareBoolFromRaw(dynamic raw, List<String> keys) {
  final Map<String, dynamic> map = shareParseMap(raw);

  for (final String key in keys) {
    if (!map.containsKey(key)) continue;

    final dynamic value = map[key];
    if (value is bool) return value;

    final String text = shareSafeString(value).toLowerCase();
    if (text == '1' || text == 'true' || text == 'yes') return true;
  }

  return false;
}

String shareValueFromMap(Map<String, dynamic> map, List<String> keys) {
  for (final String key in keys) {
    if (!map.containsKey(key)) continue;

    final dynamic value = map[key];
    if (value == null) continue;

    if (value is Map) {
      final dynamic name = value['name'] ?? value['title'] ?? value['label'];
      if (shareHas(name)) return shareSafeString(name);

      final dynamic id = value['id'] ?? value['value'] ?? value['code'];
      if (shareHas(id)) return shareSafeString(id);
    }

    if (shareHas(value)) return shareSafeString(value);
  }

  return '';
}

class ShareProductData {
  const ShareProductData({
    required this.title,
    required this.price,
    required this.condition,
    required this.usage,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.brand,
    required this.link,
    required this.category,
    required this.categoryId,
    required this.subCategory,
    required this.subCategoryId,
    required this.isFree,
    required this.isNew,
    required this.condId,
    required this.usageId,
  });

  final String title;
  final String price;
  final String condition;
  final String usage;
  final String location;
  final String description;
  final String imageUrl;
  final String brand;
  final String link;
  final String category;
  final String categoryId;
  final String subCategory;
  final String subCategoryId;
  final bool isFree;
  final bool isNew;
  final int condId;
  final int usageId;

  int get stars {
    switch (condId) {
      case 1:
      case 2:
        return 5;
      case 3:
      case 4:
        return 4;
      case 5:
        return 3;
      case 6:
        return 2;
      default:
        return 4;
    }
  }

  factory ShareProductData.from(Product product, String imageUrl, String link) {
    final dynamic d = product as dynamic;
    final dynamic highlightRaw = d.highlightInformation ?? d.highlight_info;
    final Map<String, dynamic> highlightMap = shareParseMap(highlightRaw);

    final bool isFree = shareBoolFromRaw(
      highlightRaw,
      const <String>['is_free', 'free'],
    );

    final bool isNew = shareBoolFromRaw(
      highlightRaw,
      const <String>['is_new', 'new'],
    );

    final String rawPrice = shareSafeString(product.price);
    String price = '';
    if (isFree || rawPrice == '0' || rawPrice.toLowerCase() == 'free') {
      price = 'مجاني';
    } else if (shareHas(rawPrice)) {
      price = rawPrice;
    }

    final String town = shareSafeString(product.itemLocationTownship?.townshipName);
    final String area = shareSafeString(product.itemLocation?.name);

    String location = '';
    if (shareHas(town) && shareHas(area)) {
      location = '$town، $area';
    } else if (shareHas(town)) {
      location = town;
    } else if (shareHas(area)) {
      location = area;
    }

    final String brand = shareValueFromMap(
      highlightMap,
      const <String>['brand', 'brand_name', 'brandName', 'brand_id', 'brandId'],
    );

    String category = '';
    String categoryId = '';
    String subCategory = '';
    String subCategoryId = '';

    try {
      category = shareSafeString(
        d.category?.name ??
            d.category?.catName ??
            d.category?.cat_name ??
            d.catName ??
            d.cat_name,
      );
    } catch (_) {}

    try {
      categoryId = shareSafeString(
        d.catId ??
            d.cat_id ??
            d.categoryId ??
            d.category_id ??
            d.category?.id,
      );
    } catch (_) {}

    try {
      subCategory = shareSafeString(
        d.subCategory?.name ??
            d.sub_category?.name ??
            d.subCategory?.subCatName ??
            d.sub_category?.sub_cat_name,
      );
    } catch (_) {}

    try {
      subCategoryId = shareSafeString(
        d.subCatId ??
            d.sub_cat_id ??
            d.subCategoryId ??
            d.sub_category_id ??
            d.subCategory?.id ??
            d.sub_category?.id,
      );
    } catch (_) {}

    return ShareProductData(
      title: shareSafeString(product.title),
      price: price,
      condition: shareSafeString(product.conditionOfItem?.name),
      usage: shareSafeString(product.itemType?.name),
      location: location,
      description: shareSafeString(product.description),
      imageUrl: imageUrl,
      brand: brand,
      link: link,
      category: category,
      categoryId: categoryId,
      subCategory: subCategory,
      subCategoryId: subCategoryId,
      isFree: isFree,
      isNew: isNew,
      condId: shareToInt(
        d.conditionOfItemId ?? d.condition_id ?? product.conditionOfItemId,
      ),
      usageId: shareToInt(
        d.itemTypeId ?? d.item_type_id ?? product.itemTypeId,
      ),
    );
  }
}
