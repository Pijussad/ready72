/// A real store listing matched to a curated catalogue product.
///
/// Only price, store, title and URL come from the offer. Weight, calories,
/// shelf life and allergens stay on the curated product because the carry and
/// safety guardrails depend on them.
class OfferMatch {
  const OfferMatch({
    required this.offerId,
    required this.store,
    required this.name,
    required this.priceEur,
    required this.url,
    required this.pack,
  });

  final String offerId;
  final String store;
  final String name;
  final double priceEur;
  final String url;
  final String pack;

  factory OfferMatch.fromJson(Map<String, dynamic> json) => OfferMatch(
    offerId: json['offerId'] as String,
    store: json['store'] as String,
    name: json['name'] as String,
    priceEur: (json['priceEur'] as num).toDouble(),
    url: json['url'] as String,
    pack: (json['pack'] as String?) ?? '',
  );
}
