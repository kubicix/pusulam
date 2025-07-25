import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/chat_widget.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Sohbet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _showClearDialog(context),
            tooltip: 'Sohbeti Temizle',
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(child: ChatWidget()),
          MessageInput(),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sohbeti Temizle'),
        content: const Text('Tüm mesajları silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).clearMessages();
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }
}
