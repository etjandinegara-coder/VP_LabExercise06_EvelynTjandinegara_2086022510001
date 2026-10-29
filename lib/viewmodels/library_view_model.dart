import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:university_library_system_mvvm/models/book.dart';
import 'package:university_library_system_mvvm/models/book_filter.dart';
import 'package:university_library_system_mvvm/models/loan.dart';
import 'package:university_library_system_mvvm/models/loan_status.dart';
import 'package:university_library_system_mvvm/models/repositories/book_repository.dart';
import 'package:university_library_system_mvvm/models/repositories/loan_repository.dart';
import 'package:university_library_system_mvvm/models/services/fine_service.dart';

class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({
    required BookRepository bookRepository,
    required LoanRepository loanRepository,
    FineService? fineService,
  })  : _bookRepository = bookRepository,
        _loanRepository = loanRepository,
        _fineService = fineService ?? FineService();

  final BookRepository _bookRepository;
  final LoanRepository _loanRepository;
  final FineService _fineService;

  final List<Book> _books = [];
  final List<Loan> _loans = [];

  String? errorMessage;
  int _nextLoanNumber = 1;

  String _searchText = '';
  BookFilter _filter = BookFilter.all;

  List<Book> get books => List.unmodifiable(_books);
  List<Loan> get loans => List.unmodifiable(_loans);
  BookFilter get filter => _filter;

  Future<void> loadData() async {
    final loadedBooks = await _bookRepository.getBooks();
    final loadedLoans = await _loanRepository.getLoans();

    _books
      ..clear()
      ..addAll(loadedBooks);
    _loans
      ..clear()
      ..addAll(loadedLoans);

    int biggestNumber = 0;
    for (final loan in _loans) {
      final number = int.tryParse(loan.id.substring(1)) ?? 0;
      if (number > biggestNumber) {
        biggestNumber = number;
      }
    }
    _nextLoanNumber = biggestNumber + 1;

    notifyListeners();
  }

  void _saveLoans() {
    unawaited(_loanRepository.saveLoans(List.of(_loans)));
  }

  Loan? _findActiveLoan(String bookId) {
    for (final loan in _loans) {
      if (loan.bookId == bookId && loan.isActive) {
        return loan;
      }
    }
    return null;
  }

  bool isBookBorrowed(String bookId) {
    return _findActiveLoan(bookId) != null;
  }

  LoanStatus? getBookStatus(String bookId, {DateTime? now}) {
    final activeLoan = _findActiveLoan(bookId);
    if (activeLoan == null) {
      return null;
    }
    return getOverdueStatus(activeLoan, now: now);
  }

  String getBookTitle(String bookId) {
    return _books.firstWhere((book) => book.id == bookId).title;
  }

  bool borrowBook(String bookId, String studentId, {DateTime? borrowedOn}) {
    errorMessage = null;

    final bookExists = _books.any((book) => book.id == bookId);
    if (!bookExists) {
      errorMessage = 'Buku tidak ditemukan.';
      notifyListeners();
      return false;
    }

    if (isBookBorrowed(bookId)) {
      errorMessage = 'Buku sedang dipinjam.';
      notifyListeners();
      return false;
    }

    final borrowDate = _fineService.dateOnly(borrowedOn ?? DateTime.now());
    final dueDate = _fineService.calculateDueDate(borrowDate);

    _loans.add(
      Loan(
        id: 'l$_nextLoanNumber',
        bookId: bookId,
        studentId: studentId,
        borrowDate: borrowDate,
        dueDate: dueDate,
      ),
    );
    _nextLoanNumber++;

    _saveLoans();
    notifyListeners();
    return true;
  }

  bool returnBook(String loanId, {DateTime? returnedOn}) {
    errorMessage = null;

    final loanIndex = _loans.indexWhere((loan) => loan.id == loanId);
    if (loanIndex == -1) {
      errorMessage = 'Data peminjaman tidak ditemukan.';
      notifyListeners();
      return false;
    }

    final loan = _loans[loanIndex];
    if (loan.isReturned) {
      errorMessage = 'Buku sudah dikembalikan.';
      notifyListeners();
      return false;
    }

    final returnDate = _fineService.dateOnly(returnedOn ?? DateTime.now());
    _loans[loanIndex] = loan.copyWith(returnDate: returnDate);

    _saveLoans();
    notifyListeners();
    return true;
  }

  int calculateFine(Loan loan, {DateTime? now}) {
    final book = _books.firstWhere((book) => book.id == loan.bookId);
    return _fineService.calculateFine(loan, book.replacementPrice, now: now);
  }

  LoanStatus getOverdueStatus(Loan loan, {DateTime? now}) {
    return _fineService.getLoanStatus(loan, now: now);
  }

  int get totalFine {
    int total = 0;
    for (final loan in _loans) {
      total += calculateFine(loan);
    }
    return total;
  }

  void setSearchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  void setFilter(BookFilter value) {
    _filter = value;
    notifyListeners();
  }

  List<Book> get filteredBooks {
    final searchWords = _searchText.trim().toLowerCase();

    return _books.where((book) {
      final matchesSearch = searchWords.isEmpty ||
          book.title.toLowerCase().contains(searchWords) ||
          book.author.toLowerCase().contains(searchWords);

      if (!matchesSearch) {
        return false;
      }

      final bookStatus = getBookStatus(book.id);

      switch (_filter) {
        case BookFilter.all:
          return true;
        case BookFilter.available:
          return bookStatus == null;
        case BookFilter.borrowed:
          return bookStatus != null;
        case BookFilter.overdue:
          return bookStatus == LoanStatus.overdue;
        case BookFilter.missing:
          return bookStatus == LoanStatus.missing;
      }
    }).toList();
  }
}