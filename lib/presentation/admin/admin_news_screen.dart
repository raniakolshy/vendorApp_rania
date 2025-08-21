import 'package:flutter/material.dart';

class AdminNewsScreen extends StatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  // Liste de données d'exemple pour les actualités
  final List<Map<String, String>> _newsItems = [
    {
      'title': 'Issue Fixed',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis.',
      'time': '2 m ago',
    },
    {
      'title': 'New Feature Added',
      'content': 'A new feature has been added to improve your experience. Check it out now!',
      'time': '10 m ago',
    },
    {
      'title': 'Server Maintenance',
      'content': 'Scheduled server maintenance will occur on Thursday at 2 AM UTC.',
      'time': '1 h ago',
    },
  ];

  void _refreshNews() {
    // Cette fonction simule un rafraîchissement de la liste d'actualités.
    // Dans une application réelle, vous feriez ici un appel API pour récupérer les dernières données.
    setState(() {
      _newsItems.clear();
      _newsItems.add({
        'title': 'Refreshed News 1',
        'content': 'This is a new news item fetched after a refresh.',
        'time': 'just now',
      });
      _newsItems.add({
        'title': 'Refreshed News 2',
        'content': 'Another fresh piece of information.',
        'time': '1 m ago',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('News list refreshed!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshNews,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin News',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 60, 60, 60),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _newsItems.length,
                          itemBuilder: (context, index) {
                            final newsItem = _newsItems[index];
                            return _buildNewsItem(
                              title: newsItem['title']!,
                              content: newsItem['content']!,
                              time: newsItem['time']!,
                              onDelete: () {
                                setState(() {
                                  _newsItems.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('News deleted successfully.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsItem({
    required String title,
    required String content,
    required String time,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 120, 120, 120),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 120, 120, 120),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(
            color: Color.fromARGB(255, 230, 230, 230),
            thickness: 1,
            height: 0,
          ),
        ],
      ),
    );
  }
}