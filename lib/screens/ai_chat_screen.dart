import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/crisis_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final GeminiService gemini = GeminiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isTyping = false;

  String selectedMode = "general";
  String selectedLang = "en";

  @override
  void initState() {
    super.initState();
    _addMessage("bot", "Hello. I am MindQuest. How are you feeling today?");
  }

  void _addMessage(String sender, String text) {
    if (!mounted) {
      return;
    }
    setState(() {
      messages.add({"sender": sender, "text": text});
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    _controller.clear();
    _addMessage("user", text);
    setState(() {
      isTyping = true;
    });

    if (CrisisService.isCrisis(text)) {
      setState(() {
        isTyping = false;
      });
      CrisisService.showHelplineDialog(context);
      return;
    }

    try {
      String reply = await gemini.getBotReply(
        text,
        mode: selectedMode,
        language: selectedLang,
      );
      _addMessage("bot", reply);
    } catch (e) {
      _addMessage("bot", "MindQuest is having trouble connecting.");
    } finally {
      if (mounted) {
        setState(() {
          isTyping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MindQuest AI"),
        actions: [
          DropdownButton<String>(
            value: selectedLang,
            dropdownColor: Colors.white,
            underline: Container(),
            items: const [
              DropdownMenuItem(value: "en", child: Text("EN")),
              DropdownMenuItem(value: "sw", child: Text("SW")),
              DropdownMenuItem(value: "sg", child: Text("SHENG")),
            ],
            onChanged: (v) => setState(() => selectedLang = v!),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ["general", "therapy", "coaching"]
                  .map(
                    (mode) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(mode),
                        selected: selectedMode == mode,
                        onSelected: (val) =>
                            setState(() => selectedMode = mode),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isBot = msg['sender'] == 'bot';
                return Align(
                  alignment: isBot
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.white : const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(msg['text']!),
                  ),
                );
              },
            ),
          ),
          if (isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("MindQuest is thinking..."),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }
}
