import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String status;
  final Color statusColor;
  final String? imageUrl;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.status,
    required this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.person, size: 40),
        title: Text(name),
        subtitle: Text(status),
        trailing: CircleAvatar(
          backgroundColor: statusColor,
          radius: 10,
        ),
        onTap: onTap,
      ),
    );
  }
}
