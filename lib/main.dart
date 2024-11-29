import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp(httpClient: http.Client())); // Pass httpClient here
}

class MyApp extends StatelessWidget {
  final http.Client httpClient;

  // Constructor to accept httpClient
  MyApp({Key? key, required this.httpClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Python Code Executor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PythonCodeExecutor(httpClient: httpClient), // Pass the httpClient to PythonCodeExecutor
    );
  }
}

class PythonCodeExecutor extends StatefulWidget {
  final http.Client httpClient;

  // Constructor to accept httpClient
  PythonCodeExecutor({Key? key, required this.httpClient}) : super(key: key);

  @override
  _PythonCodeExecutorState createState() => _PythonCodeExecutorState();
}

class _PythonCodeExecutorState extends State<PythonCodeExecutor> {
  final TextEditingController _controller = TextEditingController();
  String _output = '';

  Future<String> executePythonCode(String code) async {
    final Uri url = Uri.parse('http://10.14.105.223:5000/execute');

    try {
      final response = await widget.httpClient.post(
        url,
        body: {'code': code},
      );

      if (response.statusCode == 200) {
        // Assuming the response is a JSON object with the key 'output' containing the Python execution result
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Access the 'output' field from the response
        return responseData['output'] ?? 'No output';  // Provide a fallback if 'output' is not available
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  void _executeCode() async {
    final code = _controller.text;
    final result = await executePythonCode(code);

    setState(() {
      _output = result;
    });
  }

  void _clear() {
    setState(() {
      _controller.clear();
      _output = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Python Code Executor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Enter Python Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _executeCode,
                  child: Text('Execute'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _clear,
                  child: Text('Clear'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Output:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _output,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

