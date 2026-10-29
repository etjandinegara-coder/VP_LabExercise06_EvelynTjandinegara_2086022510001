import 'package:flutter/material.dart';
import 'package:university_library_system_mvvm/models/repositories/book_repository.dart';
import 'package:university_library_system_mvvm/models/repositories/loan_repository.dart';
import 'package:university_library_system_mvvm/viewmodels/library_view_model.dart';
import 'package:university_library_system_mvvm/views/library_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final viewModel = LibraryViewModel(
    bookRepository: AssetBookRepository(),
    loanRepository: FileLoanRepository(),
  );

  await viewModel.loadData();

  runApp(MyApp(viewModel: viewModel));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.viewModel});

  final LibraryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Library System',
      theme: ThemeData(useMaterial3: true),
      home: LibraryScreen(viewModel: viewModel),
    );
  }
}