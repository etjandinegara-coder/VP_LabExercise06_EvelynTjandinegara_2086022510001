import 'package:flutter_test/flutter_test.dart';
import 'package:university_library_system_mvvm/models/book.dart';
import 'package:university_library_system_mvvm/models/loan.dart';
import 'package:university_library_system_mvvm/models/loan_status.dart';
import 'package:university_library_system_mvvm/models/book_filter.dart';
import 'package:university_library_system_mvvm/models/repositories/book_repository.dart';
import 'package:university_library_system_mvvm/models/repositories/loan_repository.dart';
import 'package:university_library_system_mvvm/viewmodels/library_view_model.dart';

class FakeBookRepository implements BookRepository {
  @override
  Future<List<Book>> getBooks() async {
    return [
      const Book(id: 'b001', title: 'Buku 1', author: 'Penulis A', replacementPrice: 109000),
      const Book(id: 'b002', title: 'Buku 2', author: 'Penulis B', replacementPrice: 109000),
    ];
  }
}

class FakeLoanRepository implements LoanRepository {
  List<Loan> savedLoans = [];

  @override
  Future<List<Loan>> getLoans() async {
    return List.of(savedLoans);
  }

  @override
  Future<void> saveLoans(List<Loan> loans) async {
    savedLoans = List.of(loans);
  }
}

void main() {
  late FakeLoanRepository loanRepository;
  late LibraryViewModel viewModel;

  // Pinjam 24 September 2026, jatuh tempo 1 Oktober 2026
  setUp(() async {
    loanRepository = FakeLoanRepository();
    viewModel = LibraryViewModel(
      bookRepository: FakeBookRepository(),
      loanRepository: loanRepository,
    );
    await viewModel.loadData();
    viewModel.borrowBook('b001', 's1', borrowedOn: DateTime(2026, 9, 24));
  });

  group('pinjam dan kembali', () {
    test('jatuh tempo = tanggal pinjam + 7 hari', () {
      expect(viewModel.loans.first.dueDate, DateTime(2026, 10, 1));
    });

    test('pinjam buku yang sama dua kali ditolak', () {
      expect(viewModel.borrowBook('b001', 's2'), false);
      expect(viewModel.errorMessage, 'Buku sedang dipinjam.');
      expect(viewModel.loans.length, 1);
    });

    test('mengembalikan buku membuatnya tersedia lagi', () {
      expect(viewModel.isBookBorrowed('b001'), true);
      expect(viewModel.returnBook('l1', returnedOn: DateTime(2026, 10, 1)), true);
      expect(viewModel.isBookBorrowed('b001'), false);
      expect(viewModel.loans.first.isReturned, true);
    });

    test('mengembalikan buku dua kali ditolak', () {
      viewModel.returnBook('l1', returnedOn: DateTime(2026, 10, 1));
      expect(viewModel.returnBook('l1'), false);
      expect(viewModel.errorMessage, 'Buku sudah dikembalikan.');
    });
  });

  group('denda (aturan dosen)', () {
    int fineAt(DateTime date) {
      return viewModel.calculateFine(viewModel.loans.first, now: date);
    }

    test('tepat jatuh tempo: 0', () {
      expect(fineAt(DateTime(2026, 10, 1)), 0);
    });

    test('terlambat 6 hari: 0', () {
      expect(fineAt(DateTime(2026, 10, 7)), 0);
    });

    test('terlambat 7 hari (minggu lengkap pertama): 5000', () {
      expect(fineAt(DateTime(2026, 10, 8)), 5000);
    });

    test('terlambat 8 hari: 10000', () {
      expect(fineAt(DateTime(2026, 10, 9)), 10000);
    });

    test('terlambat 13 hari: 35000', () {
      expect(fineAt(DateTime(2026, 10, 14)), 35000);
    });

    test('terlambat 14 hari: 45000', () {
      expect(fineAt(DateTime(2026, 10, 15)), 45000);
    });

    test('terlambat 21 hari: 120000', () {
      expect(fineAt(DateTime(2026, 10, 22)), 120000);
    });
  });

  group('batas enam bulan', () {
    test('sehari sebelum batas: masih overdue', () {
      final loan = viewModel.loans.first;
      final dayBefore = DateTime(2027, 3, 31);

      expect(viewModel.getOverdueStatus(loan, now: dayBefore), LoanStatus.overdue);
      expect(viewModel.calculateFine(loan, now: dayBefore), 11375000);
    });

    test('tepat di batas: missing, denda = harga ganti', () {
      final loan = viewModel.loans.first;
      final boundaryDay = DateTime(2027, 4, 1);

      expect(viewModel.getOverdueStatus(loan, now: boundaryDay), LoanStatus.missing);
      expect(viewModel.calculateFine(loan, now: boundaryDay), 109000);
    });

    test('dikembalikan setelah hilang: tagihan tidak hilang', () {
      viewModel.returnBook('l1', returnedOn: DateTime(2027, 5, 1));
      final loan = viewModel.loans.first;

      expect(viewModel.getOverdueStatus(loan), LoanStatus.missing);
      expect(viewModel.calculateFine(loan), 109000);
    });

    test('jatuh tempo akhir bulan: 31 Agustus -> batas 28 Februari', () {
      viewModel.borrowBook('b002', 's1', borrowedOn: DateTime(2026, 8, 24));
      final loan = viewModel.loans.last; // jatuh tempo 31 Agustus 2026

      expect(viewModel.getOverdueStatus(loan, now: DateTime(2027, 2, 27)), LoanStatus.overdue);
      expect(viewModel.getOverdueStatus(loan, now: DateTime(2027, 2, 28)), LoanStatus.missing);
    });
  });

  group('status', () {
    test('active, overdue, returned', () {
      final loan = viewModel.loans.first;

      expect(viewModel.getOverdueStatus(loan, now: DateTime(2026, 10, 1)), LoanStatus.active);
      expect(viewModel.getOverdueStatus(loan, now: DateTime(2026, 10, 2)), LoanStatus.overdue);

      viewModel.returnBook('l1', returnedOn: DateTime(2026, 10, 3));
      expect(viewModel.getOverdueStatus(viewModel.loans.first), LoanStatus.returned);
    });

    test('status buku di katalog', () {
      expect(viewModel.getBookStatus('b001'), LoanStatus.active);
      expect(viewModel.getBookStatus('b002'), null);
    });
  });

  group('penyimpanan', () {
    test('data pinjaman tersimpan dan bisa dimuat lagi', () async {
      viewModel.returnBook('l1', returnedOn: DateTime(2026, 10, 3));

      final newViewModel = LibraryViewModel(
        bookRepository: FakeBookRepository(),
        loanRepository: loanRepository,
      );
      await newViewModel.loadData();

      expect(newViewModel.loans.length, 1);
      expect(newViewModel.loans.first.returnDate, DateTime(2026, 10, 3));

      expect(newViewModel.borrowBook('b002', 's1'), true);
      expect(newViewModel.loans.last.id, 'l2');
    });
  });

  group('pencarian dan filter', () {
    test('cari berdasarkan judul', () {
      viewModel.setSearchText('buku 2');
      expect(viewModel.filteredBooks.length, 1);
      expect(viewModel.filteredBooks.first.id, 'b002');
    });

    test('filter Available dan Borrowed', () {
      viewModel.setFilter(BookFilter.available);
      expect(viewModel.filteredBooks.map((book) => book.id), ['b002']);
    });
  });
}