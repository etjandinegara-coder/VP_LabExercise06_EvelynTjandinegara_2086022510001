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
    Book(id: 'b001', title: 'Menu Sehari-hari & Akhir Pekan Volume 1', author: 'Yasa Boga', replacementPrice: 109000),
    Book(id: 'b002', title: 'Menu Sehari-hari & Akhir Pekan Volume 2', author: 'Yasa Boga', replacementPrice: 109000),
    Book(id: 'b003', title: 'Menu Sehari-hari & Akhir Pekan Volume 3', author: 'Yasa Boga', replacementPrice: 109000),
    Book(id: 'b004', title: '53 Resep + Step by Step Cookies dan Camilan Renyah dari Dapur Sisca Soewitomo', author: 'Sisca Soewitomo', replacementPrice: 129000),
    Book(id: 'b005', title: 'Simple & Easy Baking with Chef Flo', author: 'Chef Flo', replacementPrice: 145000),
  ];
}

class FakeLoanRepository implements LoanRepository {
  @override
  Future<List<Loan>> getLoans() async {
    final today = DateTime.now();
    return [
      Loan(
        id: 'l1',
        bookId: 'b002',
        studentId: 's1',
        borrowDate: today,
        dueDate: today.add(const Duration(days: 7)),
      ),
    ];
  }

  @override
  Future<void> saveLoans(List<Loan> loans) async {}
}

Future<LibraryViewModel> makeVm() async {
  final vm = LibraryViewModel(
    bookRepository: FakeBookRepository(),
    loanRepository: FakeLoanRepository(),
  );
  await vm.loadData();
  return vm;
}

void main() {
  testWidgets('buku yang sedang dipinjam menampilkan tombol Dipinjam', (tester) async {
    final vm = await makeVm();

    await tester.pumpWidget(MaterialApp(
      home: LibraryScreen(viewModel: vm),
    ));

    // b002 sedang dipinjam, jadi tombolnya 'Dipinjam'
    expect(find.text('Dipinjam'), findsOneWidget);
    expect(find.text('Menu Sehari-hari & Akhir Pekan Volume 2'), findsOneWidget);
  });

  testWidgets('menekan Borrow mengubah tombol dan UI ikut berubah', (tester) async {
    final vm = await makeVm();

    await tester.pumpWidget(MaterialApp(
      home: LibraryScreen(viewModel: vm),
    ));

    // b001 tersedia dan tampil paling atas
    final borrowButton = find.widgetWithText(FilledButton, 'Borrow').first;
    await tester.tap(borrowButton);
    await tester.pump();

    expect(vm.isBookBorrowed('b001'), true);
    expect(find.text('Dipinjam'), findsNWidgets(2));
  });

  testWidgets('menampilkan pesan saat buku yang sama dipinjam lagi', (tester) async {
    final vm = await makeVm();

    await tester.pumpWidget(MaterialApp(
      home: LibraryScreen(viewModel: vm),
    ));

    final success = vm.borrowBook('b002', 's1');
    await tester.pump();

    expect(success, false);
    expect(vm.errorMessage, 'Buku sedang dipinjam.');
  });
}