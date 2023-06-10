import 'package:quiver/core.dart';

import 'index.dart';

class Product {

  const Product({
    required this.id,
    this.caseId,
    this.startDate,
    this.endDate,
    this.placementDescription,
  });

  final String id;
  final String? caseId;
  final String? startDate;
  final String? endDate;
  final String? placementDescription;

  factory Product.fromJson(Map<String,dynamic> json) => Product(
    id: json['id'].toString(),
    caseId: json['caseId']?.toString(),
    startDate: json['startDate']?.toString(),
    endDate: json['endDate']?.toString(),
    placementDescription: json['placementDescription']?.toString()
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'caseId': caseId,
    'startDate': startDate,
    'endDate': endDate,
    'placementDescription': placementDescription
  };

  Product clone() => Product(
    id: id,
    caseId: caseId,
    startDate: startDate,
    endDate: endDate,
    placementDescription: placementDescription
  );


  Product copyWith({
    String? id,
    Optional<String?>? caseId,
    Optional<String?>? startDate,
    Optional<String?>? endDate,
    Optional<String?>? placementDescription
  }) => Product(
    id: id ?? this.id,
    caseId: checkOptional(caseId, () => this.caseId),
    startDate: checkOptional(startDate, () => this.startDate),
    endDate: checkOptional(endDate, () => this.endDate),
    placementDescription: checkOptional(placementDescription, () => this.placementDescription),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Product && id == other.id && caseId == other.caseId && startDate == other.startDate && endDate == other.endDate && placementDescription == other.placementDescription;

  @override
  int get hashCode => id.hashCode ^ caseId.hashCode ^ startDate.hashCode ^ endDate.hashCode ^ placementDescription.hashCode;
}
