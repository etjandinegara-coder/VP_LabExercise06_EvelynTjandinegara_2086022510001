import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:university_library_system_mvvm/models/loan.dart';

abstract class LoanRepository {
  Future<List<Loan>> getLoans();
  Future<void> saveLoans(List<Loan> loans);
}

class FileLoanRepository implements LoanRepository {
  Future<File> _getFile() async {
    final folder = await getApplicationDocumentsDirectory();
    return File('${folder.path}/loans.json');
  }

  @override
  Future<List<Loan>> getLoans() async {
    try {
      final file = await _getFile();

      if (!await file.exists()) {
        return [];
      }

      final jsonText = await file.readAsString();
      final jsonList = jsonDecode(jsonText) as List;

      return jsonList
          .map((item) => Loan.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      return [];
    }
  }

  @override
  Future<void> saveLoans(List<Loan> loans) async {
    final file = await _getFile();
    final jsonText = jsonEncode(loans.map((loan) => loan.toJson()).toList());
    await file.writeAsString(jsonText);
  }
}