import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:university_library_system_mvvm/models/book.dart';

abstract class BookRepository {
  Future<List<Book>> getBooks();
}

class AssetBookRepository implements BookRepository {
  @override
  Future<List<Book>> getBooks() async {
    final jsonText = await rootBundle.loadString('json/books.json');
    final jsonList = jsonDecode(jsonText) as List;

    return jsonList
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}