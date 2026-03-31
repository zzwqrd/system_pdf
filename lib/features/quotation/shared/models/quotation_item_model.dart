class QuotationItem {
  final int? id;
  final int? quotationId;
  final String name;
  final double quantity;
  final double unitPrice;
  final String? priceNotes;
  final double total;
  final int sortOrder;

  QuotationItem({
    this.id,
    this.quotationId,
    required this.name,
    this.quantity = 1,
    this.unitPrice = 0,
    this.priceNotes,
    double? total,
    this.sortOrder = 0,
  }) : total = total ?? (quantity * unitPrice);

  factory QuotationItem.fromMap(Map<String, dynamic> map) {
    return QuotationItem(
      id: map['id'] as int?,
      quotationId: map['quotation_id'] as int?,
      name: map['name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0,
      priceNotes: map['price_notes'] as String?,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (quotationId != null) 'quotation_id': quotationId,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'price_notes': priceNotes,
      'total': total,
      'sort_order': sortOrder,
    };
  }

  QuotationItem copyWith({
    int? id,
    int? quotationId,
    String? name,
    double? quantity,
    double? unitPrice,
    String? priceNotes,
    double? total,
    int? sortOrder,
  }) {
    return QuotationItem(
      id: id ?? this.id,
      quotationId: quotationId ?? this.quotationId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      priceNotes: priceNotes ?? this.priceNotes,
      total: total ?? this.total,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
