import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floating Expense App',
      home: ExpenseApp(),
    );
  }
}

class ExpenseApp extends StatefulWidget {
  @override
  _ExpenseAppState createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  TextEditingController amountController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController sheetLinkController = TextEditingController();
  String? sheetLink;

  @override
  void initState() {
    super.initState();
    _loadSheetLink();
  }

  Future<void> _loadSheetLink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sheetLink = prefs.getString('sheetLink');
      sheetLinkController.text = sheetLink ?? '';
    });
  }

  Future<void> _saveSheetLink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sheetLink', sheetLinkController.text);
    setState(() {
      sheetLink = sheetLinkController.text;
    });
  }

  Future<void> _submitData() async {
    if (sheetLink == null || sheetLink!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sheet link is not set.')),
      );
      return;
    }

    final now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(now);
    final amount = amountController.text;
    final desc = descController.text;

    final uri = Uri.parse(sheetLink!);
    final response = await http.post(
      uri,
      body: {'date': date, 'amount': amount, 'desc': desc},
    );

    if (response.statusCode == 200) {
      amountController.clear();
      descController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entry added.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Floating Expense Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: sheetLinkController,
              decoration: InputDecoration(labelText: 'Google Sheet Web App URL'),
              onSubmitted: (_) => _saveSheetLink(),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitData,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}