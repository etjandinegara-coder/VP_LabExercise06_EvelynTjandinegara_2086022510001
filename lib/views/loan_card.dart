import 'package:flutter/material.dart';
import 'package:university_library_system_mvvm/models/loan.dart';
import 'package:university_library_system_mvvm/models/loan_status.dart';

class LoanCard extends StatelessWidget {
  const LoanCard({
    super.key,
    required this.loan,
    required this.title,
    required this.status,
    required this.fine,
    required this.onReturn,
  });

  final Loan loan;
  final String title;
  final LoanStatus status;
  final int fine;
  final VoidCallback onReturn;

  // Hanya mengatur cara tanggal ditampilkan
  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jatuh tempo: ${_formatDate(loan.dueDate)}'),
            Text('Status: ${status.name}'),
            if (fine > 0) Text('Denda: Rp$fine'),
          ],
        ),
        trailing: loan.isActive
            ? FilledButton(
          onPressed: onReturn,
          child: const Text('Return'),
        )
            : const Text('Dikembalikan'),
      ),
    );
  }
}