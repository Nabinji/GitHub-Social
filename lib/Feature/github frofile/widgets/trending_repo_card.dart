import 'package:flutter/material.dart';

Widget buildTrendingRepoCard(Map<String, dynamic> repo) {
  return Card(
    color: Colors.white,
    elevation: 0.2,
    margin: EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(
        backgroundImage: repo['owner']?['avatar_url'] != null
            ? NetworkImage(repo['owner']['avatar_url'])
            : null,
        radius: 20,
        child: repo['owner']?['avatar_url'] == null
            ? Icon(Icons.person, size: 20)
            : null,
      ),
      title: Text(
        repo['full_name'] ?? 'Unknown',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (repo['description'] != null) ...[
            Text(
              repo['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
          ],
          Row(
            children: [
              if (repo['language'] != null) ...[
                Icon(
                  Icons.circle,
                  size: 12,
                  color: _getLanguageColor(repo['language']),
                ),
                SizedBox(width: 4),
                Text(repo['language'], style: TextStyle(fontSize: 12)),
                SizedBox(width: 16),
              ],
              Icon(Icons.star, size: 16, color: Colors.amber),
              SizedBox(width: 4),
              Text(
                _formatNumber(repo['stargazers_count'] ?? 0),
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.star_border, color: Colors.grey),
        onPressed: () {},
        //  => _starRepository(repo['full_name']),
      ),
      isThreeLine: repo['description'] != null,
    ),
  );
}
String _formatNumber(int number) {
  if (number > 1000) {
    return '${(number / 1000).toStringAsFixed(1)}k';
  }
  return number.toString();
}
Color _getLanguageColor(String language) {
  switch (language.toLowerCase()) {
    case 'dart':
      return Colors.blue;
    case 'javascript':
      return Colors.yellow[700]!;
    case 'python':
      return Colors.green;
    case 'java':
      return Colors.orange;
    case 'swift':
      return Colors.red;
    case 'kotlin':
      return Colors.purple;
    case 'typescript':
      return Colors.blue[700]!;
    case 'go':
      return Colors.cyan;
    case 'rust':
      return Colors.brown;
    case 'c++':
      return Colors.pink;
    default:
      return Colors.grey;
  }
}
