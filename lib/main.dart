import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_key.dart' ;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _apiText;
  String searchText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Builder(builder: (context) {
                final text = _apiText;
                if (text == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                );
              }),
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: '検索したいテキスト',
              ),
              onChanged: (text) {
                setState(() {
                  searchText = text;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                //検索
                callAPI();
              },
              child: const Text('検索'),
            ),
          ],
        ),
      ),
    );
  }

  void callAPI() async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(<String, dynamic>{
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "user",
            "content": searchText,
          }
        ]
      }),
    );
    final body = response.bodyBytes;
    final jsonString = utf8.decode(body);
    final json = jsonDecode(jsonString);
    final choices = json['choices'];
    final content = choices[0]['message']['content'];

    setState(() {
      _apiText = content;
    });
  }
}
