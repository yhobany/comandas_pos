class Sale {
  int? id;
  DateTime date;
  double totalAmount;
  String? ticketNumber;

  Sale({
    this.id,
    required this.date,
    required this.totalAmount,
    this.ticketNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'total_amount': totalAmount,
      'ticket_number': ticketNumber,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      date: DateTime.parse(map['date']),
      totalAmount: (map['total_amount'] as num).toDouble(),
      ticketNumber: map['ticket_number']?.toString(),
    );
  }
}
