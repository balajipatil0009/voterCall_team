import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class ProblemCard extends StatelessWidget {
  final Map<String, dynamic> problem;
  final VoidCallback onTap;

  const ProblemCard({super.key, required this.problem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy hh:mm a')
        .format(DateTime.parse(problem['created_at']));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        onTap: onTap,
        title: Text(
          problem['description'] ??
              'No Description', // Or problem['title'] if you have title
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${problem['category'] ?? 'N/A'}'),
            Text('Status: ${problem['status'] ?? 'pending'}'),
            Text('Created at: $formattedDate'), // Display formatted date
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
