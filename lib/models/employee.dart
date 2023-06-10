import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class Employee {

  const Employee({
    required this.id,
    this.displayName,
    this.products,
  });

  final String id;
  final String? displayName;
  final List<Product>? products;

  factory Employee.fromJson(Map<String,dynamic> json) => Employee(
    id: json['id'].toString(),
    displayName: json['displayName']?.toString()
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName
  };

  Employee clone() => Employee(
    id: id,
    displayName: displayName,
    products: products?.map((e) => e.clone()).toList()
  );


  Employee copyWith({
    String? id,
    Optional<String?>? displayName,
    Optional<List<Product>?>? products
  }) => Employee(
    id: id ?? this.id,
    displayName: checkOptional(displayName, () => this.displayName),
    products: checkOptional(products, () => this.products),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Employee && id == other.id && displayName == other.displayName && products == other.products;

  @override
  int get hashCode => id.hashCode ^ displayName.hashCode ^ products.hashCode;
}
