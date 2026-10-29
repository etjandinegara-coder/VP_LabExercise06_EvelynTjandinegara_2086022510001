class Loan {
  final String id;
  final String bookId;
  final String studentId;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;

  const Loan({
    required this.id,
    required this.bookId,
    required this.studentId,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
  });

  bool get isReturned => returnDate != null;
  bool get isActive => returnDate == null;

  Loan copyWith({
    String? id,
    String? bookId,
    String? studentId,
    DateTime? borrowDate,
    DateTime? dueDate,
    DateTime? returnDate,
  }) {
    return Loan(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      studentId: studentId ?? this.studentId,
      borrowDate: borrowDate ?? this.borrowDate,
      dueDate: dueDate ?? this.dueDate,
      returnDate: returnDate ?? this.returnDate,
    );
  }

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      studentId: json['studentId'] as String,
      borrowDate: DateTime.parse(json['borrowDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      returnDate: json['returnDate'] == null
          ? null
          : DateTime.parse(json['returnDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'studentId': studentId,
      'borrowDate': borrowDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
    };
  }
}