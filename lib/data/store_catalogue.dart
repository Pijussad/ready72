import 'dart:convert';

import 'package:flutter/services.dart';

/// A real, buyable store product captured from a public store page.
///
/// Price and URL are exact as observed on the scrape date. Nutrition, pack
/// weight, shelf life and role are estimates / retrieval hints.
class StoreOffer {
  const StoreOffer({
    required this.id,
    required this.store,
    required this.name,
    required this.priceEur,
    required this.url,
    required this.category,
    required this.role,
    required this.tags,
    required this.pack,
    required this.image,
  });

  final String id;
  final String store;
  final String name;
  final double priceEur;
  final String url;
  final String category;
  final String role;
  final List<String> tags;
  final String pack;
  final String? image;

  String get storeLabel {
    switch (store) {
      case 'barbora':
        return 'Barbora';
      case 'decathlon':
        return 'Decathlon';
      case 'eurovaistine':
        return 'Eurovaistinė';
      case 'rimi':
        return 'Rimi';
      default:
        return store;
    }
  }

  factory StoreOffer.fromJson(Map<String, dynamic> json) => StoreOffer(
    id: json['id'] as String,
    store: json['store'] as String,
    name: json['name'] as String,
    priceEur: (json['price'] as num).toDouble(),
    url: json['url'] as String,
    category: (json['category'] as String?) ?? '',
    role: (json['role'] as String?) ?? 'other',
    tags: ((json['tags'] as List?) ?? const []).cast<String>(),
    pack: (json['pack'] as String?) ?? '',
    image: json['image'] as String?,
  );
}

/// Loads the generated store database and provides local retrieval. The AI
/// only ever sees a shortlist from here; prices are always read from this
/// database, never invented by the model.
class StoreCatalogue {
  StoreCatalogue._(this.offers, this.meta);

  final List<StoreOffer> offers;
  final Map<String, dynamic> meta;

  static StoreCatalogue? _instance;

  static Future<StoreCatalogue> load({AssetBundle? bundle}) async {
    if (_instance != null) return _instance!;
    final b = bundle ?? rootBundle;
    final products =
        jsonDecode(await b.loadString('assets/catalogue/products.json'))
            as Map<String, dynamic>;
    final meta =
        jsonDecode(await b.loadString('assets/catalogue/meta.json'))
            as Map<String, dynamic>;
    final offers = (products['products'] as List)
        .map((row) => StoreOffer.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
    return _instance = StoreCatalogue._(offers, meta);
  }

  Map<String, int> get storeCounts {
    final counts = <String, int>{};
    for (final offer in offers) {
      counts[offer.store] = (counts[offer.store] ?? 0) + 1;
    }
    return counts;
  }

  List<StoreOffer> search(
    String query, {
    Set<String> stores = const {},
    int limit = 60,
  }) {
    final normalized = _normalize(query);
    final tokens = normalized.split(RegExp(r'\s+')).where((t) => t.length > 1);
    final filtered = offers.where(
      (offer) => stores.isEmpty || stores.contains(offer.store),
    );
    if (tokens.isEmpty) {
      return filtered.take(limit).toList(growable: false);
    }
    final scored = <(int, StoreOffer)>[];
    for (final offer in filtered) {
      final haystack = _normalize(
        '${offer.name} ${offer.category} ${offer.role}',
      );
      var score = 0;
      for (final token in tokens) {
        if (haystack.contains(token)) score++;
      }
      if (score > 0) scored.add((score, offer));
    }
    scored.sort((a, b) {
      final byScore = b.$1.compareTo(a.$1);
      if (byScore != 0) return byScore;
      return a.$2.priceEur.compareTo(b.$2.priceEur);
    });
    return scored.take(limit).map((entry) => entry.$2).toList(growable: false);
  }

  List<StoreOffer> forRole(String role, {int limit = 40}) {
    return offers
        .where((offer) => offer.role == role)
        .take(limit)
        .toList(growable: false);
  }

  static String _normalize(String value) {
    const map = {
      'ą': 'a',
      'č': 'c',
      'ę': 'e',
      'ė': 'e',
      'į': 'i',
      'š': 's',
      'ų': 'u',
      'ū': 'u',
      'ž': 'z',
    };
    final buffer = StringBuffer();
    for (final rune in value.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      buffer.write(map[char] ?? char);
    }
    return buffer.toString();
  }
}
