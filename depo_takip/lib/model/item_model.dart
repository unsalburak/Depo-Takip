

class Item {
   int itemId;
 String itemName;
   int stockQuantity;
  int shelfNumber;
   int itemModelno; // Yeni eklenen alan

  Item({
    required this.itemId,
    required this.itemName,
    required this.stockQuantity,
    required this.shelfNumber,
    required this.itemModelno,
  });

  // Map'ten Item nesnesine dönüştürme
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemId: map['item_id'],
      itemName: map['item_name'],
      stockQuantity: map['stock_quantity'],
      shelfNumber: map['shelf_number'],
      itemModelno: map['item_modelno'], // Yeni eklenen alan
    );
  }

  // Item nesnesinden Map'e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'stock_quantity': stockQuantity,
      'shelf_number': shelfNumber,
      'item_modelno': itemModelno, // Yeni eklenen alan
    };
  }
}
