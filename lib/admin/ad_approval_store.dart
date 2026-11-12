import 'dart:typed_data';

import 'package:flutter/foundation.dart';

enum AdStatus { awaitingApproval, approved, rejected, sold }

class AdListing {
  const AdListing({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.location,
    required this.seller,
    required this.description,
    required this.isPaid,
    required this.createdAt,
    this.sellerEmail = '',
    this.sellerPhone = '',
    this.photos = const [],
    this.status = AdStatus.awaitingApproval,
  });

  final String id;
  final String title;
  final String category;
  final String price;
  final String location;
  final String seller;
  final String description;
  final bool isPaid;
  final DateTime createdAt;
  final String sellerEmail;
  final String sellerPhone;
  final List<Uint8List> photos;
  final AdStatus status;

  AdListing copyWith({AdStatus? status}) => AdListing(
        id: id,
        title: title,
        category: category,
        price: price,
        location: location,
        seller: seller,
        description: description,
        isPaid: isPaid,
        createdAt: createdAt,
        sellerEmail: sellerEmail,
        sellerPhone: sellerPhone,
        photos: photos,
        status: status ?? this.status,
      );
}

class AdApprovalStore {
  AdApprovalStore._();

  static final ValueNotifier<List<AdListing>> listings = ValueNotifier([]);

  static void submit(AdListing listing) {
    listings.value = [listing, ...listings.value];
  }

  static void updateStatus(String id, AdStatus status) {
    listings.value = [
      for (final listing in listings.value)
        if (listing.id == id) listing.copyWith(status: status) else listing,
    ];
  }

  static void remove(String id) {
    listings.value = listings.value.where((listing) => listing.id != id).toList();
  }
}
