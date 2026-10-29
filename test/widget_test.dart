import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:university_library_system_mvvm/models/book.dart';
import 'package:university_library_system_mvvm/models/loan.dart';
import 'package:university_library_system_mvvm/models/repositories/book_repository.dart';
import 'package:university_library_system_mvvm/models/repositories/loan_repository.dart';
import 'package:university_library_system_mvvm/viewmodels/library_view_model.dart';
import 'package:university_library_system_mvvm/views/library_screen.dart';

class FakeBookRepository implements BookRepository {
  @override
  Future<List<Book>> getBooks() async => const [
    Book(id: 'b001', title: 'Dasar Flutter', author: 'A', replacementPrice: 100000),
    Book(id: 'b002', title: 'Dart Lanjutan', author: 'B', replacementPrice: 80000),
  ];
}

class FakeLoanRepository implements LoanRepository {
  @override
  Future<List<Loan>> getLoans() async => [
    Loan(
      id: 'l1',
      bookId: 'b001',
      studentId: 's1',
      borrowDate: DateTime(2026, 10, 1),
      dueDate: DateTime(2026, 10, 8),
    ),
  ];

  @override
  Future<void> saveLoans(List<Loan> loans) async {}
}

void main() {
  testWidgets('katalog menampilkan buku dan status pinjam', (tester) async {
    final vm = LibraryViewModel(
      bookRepository: FakeBookRepository(),
      loanRepository: FakeLoanRepository(),
    );
    await vm.loadData();

    await tester.pumpWidget(MaterialApp(
      home: LibraryScreen(viewModel: vm),
    ));

    expect(find.text('Dasar Flutter'), findsOneWidget);
    expect(find.text('Dart Lanjutan'), findsOneWidget);

    expect(find.text('Dipinjam'), findsOneWidget);
    expect(find.text('Borrow'), findsOneWidget);
  });

  testWidgets('menekan Borrow mengubah tombol dan UI ikut berubah', (tester) async {
    final vm = LibraryViewModel(
      bookRepository: FakeBookRepository(),
      loanRepository: FakeLoanRepository(),
    );
    await vm.loadData();

    await tester.pumpWidget(MaterialApp(
      home: LibraryScreen(viewModel: vm),
    ));

    await tester.tap(find.text('Borrow'));
    await tester.pump();

    expect(find.text('Borrow'), findsNothing);
    expect(find.text('Dipinjam'), findsNWidgets(2));
    expect(vm.isBookBorrowed('b002'), true);
  });

  testWidgets('menampilkan pesan saat buku yang sama dipinjam lagi', (tester) async {
    final vm = LibraryViewModel(
      bookRepository: FakeBookRepository(),
      loanRepository: FakeLoanRepository(),
    );
    await vm.loadData();

    await tester.pumpWidget(MaterialApp(
      home: LibraryScreen(viewModel: vm),
    ));

    final success = vm.borrowBook('b001', 's1');
    await tester.pump();

    expect(success, false);
    expect(vm.errorMessage, 'Buku sedang dipinjam.');
  });
}