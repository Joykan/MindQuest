import 'package:flutter/material.dart';
import '../data/wellness_content.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF343541), // GPT Background
      appBar: AppBar(
        title: const Text("Mind Library"),
        backgroundColor: const Color(0xFF202123),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wellnessTopics.length,
        itemBuilder: (context, index) {
          final t = wellnessTopics[index];
          return Card(
            color: const Color(0xFF444654), // GPT Card Color
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            child: ExpansionTile(
              leading: Text(t.icon, style: const TextStyle(fontSize: 24)),
              title: Text(
                t.title,
                style: const TextStyle(
                  color: Color(0xFFECECF1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconColor: Colors.white54,
              collapsedIconColor: Colors.white54,
              children: t.tips
                  .map(
                    (tip) => ListTile(
                      leading: const Icon(
                        Icons.check,
                        color: Color(0xFF10A37F),
                        size: 18,
                      ), // Green Check
                      title: Text(
                        tip,
                        style: const TextStyle(color: Color(0xFFECECF1)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
