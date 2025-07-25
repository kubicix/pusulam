import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusulam_mobile/providers/chat_provider.dart';
import 'package:pusulam_mobile/widgets/chat_widget.dart';
import 'package:pusulam_mobile/widgets/message_input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Uygulama açıldığında bağlantı testi yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testConnection();
    });
  }

  Future<void> _testConnection() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final isConnected = await chatProvider.testConnection();
    
    if (!mounted) return;

    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Backend bağlantısı kurulamadı: ${chatProvider.errorMessage}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Tekrar Dene',
            textColor: Colors.white,
            onPressed: _testConnection,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backend bağlantısı başarılı!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pusulam',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testConnection,
            tooltip: 'Bağlantıyı Test Et',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _showClearDialog();
                  break;
                case 'about':
                  _showAboutDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Sohbeti Temizle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('Hakkında'),
                  ],
                ),
              ),
            ],
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

  void _showClearDialog() {
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pusulam Hakkında'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pusulam - AI Asistan'),
            SizedBox(height: 8),
            Text('Sürüm: 1.0.0'),
            SizedBox(height: 8),
            Text('Geliştirildi: Flutter & FastAPI'),
            SizedBox(height: 8),
            Text('Gemini AI ile güçlendirilmiştir.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
