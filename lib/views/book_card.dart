import 'package:flutter/material.dart';
import 'package:university_library_system_mvvm/models/book.dart';
import 'package:university_library_system_mvvm/models/loan_status.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.isBorrowed,
    required this.status,
    required this.onBorrow,
  });

  final Book book;
  final bool isBorrowed;
  final LoanStatus? status;
  final VoidCallback onBorrow;

  String _getStatusText() {
    switch (status) {
      case null:
        return 'Available';
      case LoanStatus.active:
        return 'Borrowed';
      case LoanStatus.overdue:
        return 'Overdue';
      case LoanStatus.missing:
        return 'Missing';
      case LoanStatus.returned:
        return 'Available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${book.author}\nStatus: ${_getStatusText()}'),
        isThreeLine: true,
        trailing: FilledButton(
          onPressed: isBorrowed ? null : onBorrow,
          child: Text(isBorrowed ? 'Dipinjam' : 'Borrow'),
        ),
      ),
    );
  }
}