class Book {
  final String id;
  final String title;
  final String author;
  final int replacementPrice;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.replacementPrice,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      replacementPrice: json['replacementPrice'] as int,
    );
  }
}