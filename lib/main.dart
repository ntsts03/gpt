import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_key.dart';

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
  String searchText = '';
  List<Map<String, String>> chatHistory = [];

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
                if (chatHistory.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: chatHistory
                      .map<Column>(
                        (Map<String, String> entry) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'User: ${entry['user']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Bot: ${entry['bot']}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                      )
                      .toList(),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    //検索
                    callAPI();
                  },
                  child: const Text('検索'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    clearChatHistory();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('履歴削除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 Future<void> callAPI() async {
    List<Map<String, String>> messages = chatHistory
        .map((entry) => {
              "role": "user",
              "content": entry['user']!,
            })
        .toList();

    messages.add({
      "role": "user",
      "content": searchText,
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(<String, dynamic>{
        "model": "gpt-3.5-turbo",
        "messages": messages,
      }),
    );
    final body = response.bodyBytes;
    final jsonString = utf8.decode(body);
    final json = jsonDecode(jsonString);
    final choices = json['choices'];
    final content = choices[0]['message']['content'];

    setState(() {
      chatHistory.add({
        'user': searchText,
        'bot': content,
      });
    });
  }

  void clearChatHistory() {
    setState(() {
      chatHistory.clear();
    });
  }
}
