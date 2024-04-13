import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_audience_network/easy_audience_network.dart';
import 'package:get/get.dart';

void main() {
  AdHelper.init();
  runApp(MyApp());
}

class AdHelper {
  static void init() {
    EasyAudienceNetwork.init(
      testMode: true,
    );
  }

  static void showInterstitialAd(VoidCallback onComplete) {
    // Show loading
    final interstitialAd = InterstitialAd(InterstitialAd.testPlacementId);

    interstitialAd.listener = InterstitialAdListener(onLoaded: () {
      //hide loading
      Get.back();
      onComplete();

      interstitialAd.show();
    }, onDismissed: () {
      interstitialAd.destroy();
    }, onError: (i, e) {
      //hide loading
      Get.back();
      onComplete();
    });

    interstitialAd.load();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIQuanta AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _controller = TextEditingController();
  List<Widget> messages = [];

  void sendMessage(String message) async {
    setState(() {
      messages.add(UserMessage(text: message));
    });

    String url =
        'https://api.deepinfra.com/v1/inference/mistralai/Mixtral-8x7B-Instruct-v0.1';
    Map<String, String> headers = {
      'Authorization': 'bearer t3daO1rf3y0MS5jOL',
      'Content-Type': 'application/json'
    };

    Map<String, dynamic> requestBody = {
      'input': message,
      'temperature': 0,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String generatedText = responseData['results'][0]['generated_text'];
        setState(() {
          messages.add(ChatbotMessage(text: generatedText));
        });
      } else {
        throw Exception('Failed to get response from the server.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AIQuanta AI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return messages[index];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your prompt',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserMessage extends StatelessWidget {
  final String text;

  UserMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(color: Colors.black),
      ),
      subtitle: Text('User'),
      trailing: Icon(Icons.account_circle),
    );
  }
}

class ChatbotMessage extends StatelessWidget {
  final String text;

  ChatbotMessage({required this.text});

  void copyText(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              copyText(context, text);
            },
            child: Text('Copy'),
          ),
        ],
      ),
      subtitle: Text('AIQuanta AI'),
      leading: Icon(Icons.chat_bubble_outline),
      tileColor: Colors.white,
    );
  }
}
