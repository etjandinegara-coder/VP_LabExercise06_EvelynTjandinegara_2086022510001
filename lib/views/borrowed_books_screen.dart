import 'package:flutter/material.dart';
import 'package:university_library_system_mvvm/viewmodels/library_view_model.dart';
import 'package:university_library_system_mvvm/views/loan_card.dart';

class BorrowedBooksScreen extends StatelessWidget {
  const BorrowedBooksScreen({super.key, required this.viewModel});

  final LibraryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buku Dipinjam')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          final loans = viewModel.loans;

          return Column(
            children: [
              Card(
                child: ListTile(
                  title: const Text('Total denda'),
                  trailing: Text('Rp${viewModel.totalFine}'),
                ),
              ),
              Expanded(
                child: loans.isEmpty
                    ? const Center(child: Text('Belum ada peminjaman'))
                    : ListView.builder(
                  itemCount: loans.length,
                  itemBuilder: (context, index) {
                    final loan = loans[index];

                    return LoanCard(
                      loan: loan,
                      title: viewModel.getBookTitle(loan.bookId),
                      status: viewModel.getOverdueStatus(loan),
                      fine: viewModel.calculateFine(loan),
                      onReturn: () {
                        final success = viewModel.returnBook(loan.id);
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                viewModel.errorMessage ?? 'Gagal mengembalikan buku',
                              ),
                            ),
                          );
                        }
                      },
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