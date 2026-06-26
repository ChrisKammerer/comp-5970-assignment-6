import 'package:email_summarizer/providers/email_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_summarizer/screens/home_screen.dart';

void main() {
  runApp(const ScanLogApp());
}

class ScanLogApp extends StatelessWidget {
  const ScanLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmailSummaryProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Email Summarizer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: HomeScreen(),
      ),
    );
  }
}