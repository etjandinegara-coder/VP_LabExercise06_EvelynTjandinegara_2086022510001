import 'package:university_library_system_mvvm/models/fine.dart';
import 'package:university_library_system_mvvm/models/loan.dart';
import 'package:university_library_system_mvvm/models/loan_status.dart';

class FineService {
  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime calculateDueDate(DateTime borrowDate) {
    final cleanDate = dateOnly(borrowDate);
    return DateTime(
      cleanDate.year,
      cleanDate.month,
      cleanDate.day + Fine.loanDurationDays,
    );
  }

  int daysBetween(DateTime fromDate, DateTime toDate) {
    final hours = dateOnly(toDate).difference(dateOnly(fromDate)).inHours;
    return (hours / 24).round();
  }

  DateTime getEndDate(Loan loan, {DateTime? now}) {
    return loan.returnDate ?? dateOnly(now ?? DateTime.now());
  }

  DateTime getMissingDate(DateTime dueDate) {
    final targetMonth = dueDate.month + Fine.missingAfterMonths;
    final lastDayOfTargetMonth = DateTime(dueDate.year, targetMonth + 1, 0).day;
    final targetDay =
    dueDate.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : dueDate.day;

    return DateTime(dueDate.year, targetMonth, targetDay);
  }

  bool isMissing(Loan loan, {DateTime? now}) {
    final endDate = getEndDate(loan, now: now);
    return !endDate.isBefore(getMissingDate(loan.dueDate));
  }

  int calculateFine(Loan loan, int replacementPrice, {DateTime? now}) {
    if (isMissing(loan, now: now)) {
      return replacementPrice;
    }

    final endDate = getEndDate(loan, now: now);

    if (!endDate.isAfter(loan.dueDate)) {
      return 0;
    }

    final overdueDays = daysBetween(loan.dueDate, endDate);

    int totalFine = 0;
    for (int day = Fine.daysPerWeek; day <= overdueDays; day++) {
      totalFine += Fine.weeklyFine * (day ~/ Fine.daysPerWeek);
    }
    return totalFine;
  }

  LoanStatus getLoanStatus(Loan loan, {DateTime? now}) {
    if (isMissing(loan, now: now)) {
      return LoanStatus.missing;
    }

    if (loan.isReturned) {
      return LoanStatus.returned;
    }

    final endDate = getEndDate(loan, now: now);
    if (endDate.isAfter(loan.dueDate)) {
      return LoanStatus.overdue;
    }

    return LoanStatus.active;
  }
}