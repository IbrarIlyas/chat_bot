import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_bot/ChatMessage.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'Constants.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final GenerativeModel model;

  final List<ChatMessage> messages = [];
  final SpeechToText _speechToText = SpeechToText();
  String _hintText = "Press and hold to start recording";
  bool _isListening = false;
  var scrollController = ScrollController();

  scrollMethod() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  void initState() {
    super.initState();
    _initializeSpeechToText();
    model = GenerativeModel(
        model: "gemini-pro", apiKey: "AIzaSyAmBWgx9KsFYD_H0H4UcG3w5-Ry7K9YTck");
  }

  Future<void> _initializeSpeechToText() async {
    bool available = await _speechToText.initialize(
      onError: (error) => print('onError: $error'),
    );

    if (!available) {
      setState(() {
        _hintText = "Speech recognition not available";
      });
    }
  }

  void _startListening() async {
    if (!_isListening && _speechToText.isAvailable) {
      setState(() {
        _isListening = true;
      });

      await _speechToText.listen(onResult: (result) {
        setState(() {
          _hintText = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      _speechToText.stop();
      if (_hintText.isNotEmpty &&
          _hintText != "Press and hold to start recording") {
        setState(() {
          messages.add(
              ChatMessage(text: _hintText, memberType: ChatMemberType.person));
        });

        String response = await getGenerativeAIResponse(_hintText);

        setState(() {
          messages
              .add(ChatMessage(text: response, memberType: ChatMemberType.AI));
          scrollMethod();
        });
      }
    }
  }

  Future<String> getGenerativeAIResponse(String inputText) async {
    try {
      final GenerateContentResponse response =
          await model.generateContent([Content.text(inputText)]);
      return response.text!; // Join the response parts if needed
    } catch (e) {
      print("Error: $e");
      return "Error generating response.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundcolor,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(letterSpacing: 2.1),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: SingleChildScrollView(
                reverse: true,
                physics: const BouncingScrollPhysics(),
                child: Text(
                  _hintText,
                  style: TextStyle(
                      fontSize: 24,
                      color: _isListening ? Colors.black : Colors.black38),
                )),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: chatgptbackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView.builder(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return chatMessageBubble(
                      messages[index].text!, messages[index].memberType!);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AvatarGlow(
        glowColor: backgroundcolor,
        animate: _isListening,
        duration: const Duration(milliseconds: 1000),
        startDelay: const Duration(milliseconds: 50),
        repeat: true,
        child: GestureDetector(
          onTapDown: (details) => _startListening(),
          onTapUp: (details) => _stopListening(),
          child: CircleAvatar(
            backgroundColor: backgroundcolor,
            foregroundColor: Colors.white,
            radius: _isListening ? 40 : 35,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ),
      ),
    );
  }
}

Widget? chatMessageBubble(String textmsg, ChatMemberType persontype) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        radius: 20,
        backgroundColor: backgroundcolor,
        child: Icon(
          (persontype == ChatMemberType.AI)
              ? Icons.lightbulb_outline
              : Icons.person,
        ),
      ),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
              color: (persontype == ChatMemberType.AI)
                  ? backgroundcolor
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15))),
          child: Text(
            textmsg,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    ],
  );
}
