import 'package:flutter/material.dart';
import 'package:university_library_system_mvvm/models/book_filter.dart';
import 'package:university_library_system_mvvm/viewmodels/library_view_model.dart';
import 'package:university_library_system_mvvm/views/book_card.dart';
import 'package:university_library_system_mvvm/views/borrowed_books_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key, required this.viewModel});

  final LibraryViewModel viewModel;

  // Anggap mahasiswa ini yang sedang login
  static const String studentId = 's1';

  // Hanya mengubah nama filter menjadi tulisan di layar
  String _getFilterLabel(BookFilter filter) {
    switch (filter) {
      case BookFilter.all:
        return 'Semua';
      case BookFilter.available:
        return 'Available';
      case BookFilter.borrowed:
        return 'Borrowed';
      case BookFilter.overdue:
        return 'Overdue';
      case BookFilter.missing:
        return 'Missing';
    }
  }

  void _onBorrowPressed(BuildContext context, String bookId) {
    final success = viewModel.borrowBook(bookId, studentId);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Gagal meminjam')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perpustakaan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BorrowedBooksScreen(viewModel: viewModel),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          final books = viewModel.filteredBooks;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: TextField(
                  onChanged: viewModel.setSearchText,
                  decoration: const InputDecoration(
                    hintText: 'Cari judul atau penulis',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    for (final filter in BookFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_getFilterLabel(filter)),
                          selected: viewModel.filter == filter,
                          onSelected: (selected) => viewModel.setFilter(filter),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: books.isEmpty
                    ? const Center(child: Text('Tidak ada buku ditemukan'))
                    : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];

                    return BookCard(
                      book: book,
                      isBorrowed: viewModel.isBookBorrowed(book.id),
                      status: viewModel.getBookStatus(book.id),
                      onBorrow: () => _onBorrowPressed(context, book.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}