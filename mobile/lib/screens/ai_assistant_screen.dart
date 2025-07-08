import 'package:flutter/material.dart';
import '../services/ai_assistant_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _response;
  bool _loading = false;

  Future<void> _ask() async {
    setState(() => _loading = true);
    try {
      final response = await AIAssistantService.askAssistant(
        prompt: _controller.text,
      );
      setState(() => _response = response);
    } catch (e) {
      setState(() => _response = "⚠️ Error: ${e.toString()}");
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Assistant")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Ask your farming question...",
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 4,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : _ask,
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Ask"),
            ),
            const SizedBox(height: 20),
            if (_response != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _response!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
// This screen allows users to ask questions to the AI assistant and displays the response.