import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense App',
      home: ExpenseApp(),
    );
  }
}

class ExpenseApp extends StatefulWidget {
  @override
  _ExpenseAppState createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  final amountController = TextEditingController();
  final descController = TextEditingController();
  final sheetLinkController = TextEditingController();
  String? sheetLink;

  @override
  void initState() {
    super.initState();
    _loadSheetLink();
  }

  Future<void> _loadSheetLink() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sheetLink = prefs.getString('sheetLink');
      sheetLinkController.text = sheetLink ?? '';
    });
  }

  Future<void> _saveSheetLink() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sheetLink', sheetLinkController.text);
    setState(() {
      sheetLink = sheetLinkController.text;
    });
  }

  Future<void> _submitData() async {
    final now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(now);
    final amount = amountController.text;
    final desc = descController.text;

    if (sheetLink == null || sheetLink!.isEmpty) return;

    final uri = Uri.parse(sheetLink!);
    final response = await http.post(uri, body: {
      'date': date,
      'amount': amount,
      'desc': desc,
    });

    if (response.statusCode == 200) {
      amountController.clear();
      descController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Submitted!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: sheetLinkController,
              decoration: InputDecoration(labelText: 'Google Apps Script URL'),
              onSubmitted: (_) => _saveSheetLink(),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _submitData, child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}