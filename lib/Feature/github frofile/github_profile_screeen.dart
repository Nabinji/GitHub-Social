import 'package:flutter/material.dart';
import 'package:github_social/service.dart';

class GithubProfileScreeen extends StatefulWidget {
  final String accessToken;

  const GithubProfileScreeen({super.key, required this.accessToken});

  @override
  State<GithubProfileScreeen> createState() => _GithubProfileScreeenState();
}

class _GithubProfileScreeenState extends State<GithubProfileScreeen> {
  late GitHubService gitHubService;

  // Data variables
  Map<String, dynamic>? userData;
  List<dynamic> repositories = [];
  List<dynamic> activities = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialize the service with your access token
    gitHubService = GitHubService(widget.accessToken);
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Test connection first
      bool connected = await gitHubService.testConnection();
      if (!connected) {
        throw Exception('Unable to connect to GitHub API');
      }

      // Load user data
      userData = await gitHubService.getAuthenticatedUser();
      print('User data loaded: ${userData?['login']}');

      // Load repositories
      repositories = await gitHubService.getUserRepositories();
      print('Repositories loaded: ${repositories.length}');

      // Load activities
      activities = await gitHubService.getUserActivity();
      print('Activities loaded: ${activities.length}');

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMessage.isNotEmpty
        ? Center(
            child: Column(
              //   actions: [
              //   IconButton(icon: Icon(Icons.refresh), onPressed: loadData),
              // // ],
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(errorMessage, textAlign: TextAlign.center),
                SizedBox(height: 16),
                ElevatedButton(onPressed: loadData, child: Text('Retry')),
              ],
            ),
          )
        : _buildContent();
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(right: 15, left: 15, top: 55, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Card
          if (userData != null) ...[
            Card(
              color: Colors.white,
              elevation: 0.1,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: userData!['avatar_url'] != null
                          ? NetworkImage(userData!['avatar_url'])
                          : null,
                      child: userData!['avatar_url'] == null
                          ? Icon(Icons.person, size: 40)
                          : null,
                    ),
                    SizedBox(height: 12),
                    Text(
                      userData!['name'] ?? userData!['login'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('@${userData!['login'] ?? 'unknown'}'),
                    if (userData!['bio'] != null) ...[
                      SizedBox(height: 8),
                      Text(
                        userData!['bio'],
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Repos', userData!['public_repos'] ?? 0),
                        _buildStatItem(
                          'Followers',
                          userData!['followers'] ?? 0,
                        ),
                        _buildStatItem(
                          'Following',
                          userData!['following'] ?? 0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],

          // Repositories Section
          Text(
            'Recent Repositories (${repositories.length})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (repositories.isEmpty)
            Card(
              color: Colors.white,
              elevation: 0.2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No repositories found'),
              ),
            )
          else
            ...repositories
                .take(5)
                .map(
                  (repo) => Card(
                    color: Colors.white,
                    elevation: 0.2,
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        repo['private'] == true ? Icons.lock : Icons.folder,
                        color: repo['private'] == true
                            ? Colors.red
                            : Colors.blue,
                      ),
                      title: Text(repo['name'] ?? 'Unknown'),
                      subtitle: Text(repo['description'] ?? 'No description'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text('${repo['stargazers_count'] ?? 0}'),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),

          SizedBox(height: 16),

          // Activities Section
          Text(
            'Recent Activity (${activities.length})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (activities.isEmpty)
            Card(
              color: Colors.white,
              elevation: 0.2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No recent activity found'),
              ),
            )
          else
            ...activities
                .take(5)
                .map(
                  (activity) => Card(
                    color: Colors.white,
                    elevation: 0.2,
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            activity['actor']?['avatar_url'] != null
                            ? NetworkImage(activity['actor']['avatar_url'])
                            : null,
                        child: activity['actor']?['avatar_url'] == null
                            ? Icon(Icons.person)
                            : null,
                      ),
                      title: Text(_getActivityDescription(activity)),
                      subtitle: Text(
                        _formatDateTime(activity['created_at'] ?? ''),
                      ),
                      trailing: Icon(_getActivityIcon(activity['type'] ?? '')),
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  String _getActivityDescription(Map<String, dynamic> activity) {
    final type = activity['type'] ?? '';
    final repoName = activity['repo']?['name'] ?? 'Unknown';

    switch (type) {
      case 'PushEvent':
        return 'Pushed to $repoName';
      case 'CreateEvent':
        return 'Created ${activity['payload']?['ref_type'] ?? 'item'} in $repoName';
      case 'WatchEvent':
        return 'Starred $repoName';
      case 'ForkEvent':
        return 'Forked $repoName';
      case 'IssuesEvent':
        return '${activity['payload']?['action'] ?? 'Updated'} issue in $repoName';
      case 'PullRequestEvent':
        return '${activity['payload']?['action'] ?? 'Updated'} pull request in $repoName';
      default:
        return '$type in $repoName';
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'PushEvent':
        return Icons.upload;
      case 'CreateEvent':
        return Icons.add;
      case 'WatchEvent':
        return Icons.star;
      case 'ForkEvent':
        return Icons.call_split;
      case 'IssuesEvent':
        return Icons.bug_report;
      case 'PullRequestEvent':
        return Icons.merge_type;
      default:
        return Icons.circle;
    }
  }

  String _formatDateTime(String dateTime) {
    if (dateTime.isEmpty) return 'Unknown time';

    try {
      final dt = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inMinutes}m ago';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
}
