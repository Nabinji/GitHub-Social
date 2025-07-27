import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  final String accessToken;
  final String baseUrl = 'https://api.github.com';

  GitHubService(this.accessToken);

  // Headers for authenticated requests
  Map<String, String> get headers => {
    'Authorization': 'Bearer $accessToken',
    'Accept': 'application/vnd.github.v3+json',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  // Get authenticated user info
  Future<Map<String, dynamic>> getAuthenticatedUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Failed to fetch user data: $e');
    }
  }

  // Get user's repositories (public and private)
  Future<List<dynamic>> getUserRepositories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/repos?sort=updated&per_page=50&type=all'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch repositories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching repositories: $e');
      return []; // Return empty list on error
    }
  }

  // Get user's activity timeline
  Future<List<dynamic>> getUserActivity() async {
    try {
      final user = await getAuthenticatedUser();
      final username = user['login'];

      final response = await http.get(
        Uri.parse('$baseUrl/users/$username/events?per_page=50'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to fetch user activity: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching user activity: $e');
      return []; // Return empty list on error
    }
  }

  // Get user's starred repositories
  Future<List<dynamic>> getStarredRepositories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/starred?per_page=30'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to fetch starred repositories: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching starred repositories: $e');
      return []; // Return empty list on error
    }
  }

  // Get user's followers
  Future<List<dynamic>> getFollowers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/followers?per_page=50'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch followers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching followers: $e');
      return []; // Return empty list on error
    }
  }

  // Get who user is following
  Future<List<dynamic>> getFollowing() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/following?per_page=50'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch following: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching following: $e');
      return []; // Return empty list on error
    }
  }

  // Get notifications
  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications?per_page=30'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to fetch notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return []; // Return empty list on error
    }
  }

  // Get user's organizations
  Future<List<dynamic>> getUserOrganizations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/orgs'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to fetch organizations: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching organizations: $e');
      return []; // Return empty list on error
    }
  }

  // Get organization events
  Future<List<dynamic>> getOrganizationEvents(String orgName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orgs/$orgName/events?per_page=30'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to fetch organization events: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching organization events: $e');
      return []; // Return empty list on error
    }
  }

  // Get trending repositories (using search API)
  Future<List<dynamic>> getTrendingRepositories() async {
    try {
      final today = DateTime.now();
      final lastWeek = today.subtract(Duration(days: 7));
      final dateStr = lastWeek.toIso8601String().split('T')[0];

      final response = await http.get(
        Uri.parse(
          '$baseUrl/search/repositories?q=created:>$dateStr&sort=stars&order=desc&per_page=30',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
        throw Exception(
          'Failed to fetch trending repositories: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching trending repositories: $e');
      return []; // Return empty list on error
    }
  }

  // Get recent commits across user's repositories
  Future<List<dynamic>> getRecentCommits() async {
    try {
      final repos = await getUserRepositories();
      List<dynamic> allCommits = [];

      // Get commits from first 10 repositories to avoid rate limiting
      final reposToCheck = repos.take(10).toList();

      for (var repo in reposToCheck) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/repos/${repo['full_name']}/commits?per_page=5'),
            headers: headers,
          );

          if (response.statusCode == 200) {
            final commits = json.decode(response.body);
            for (var commit in commits) {
              commit['repository'] = repo; // Add repo info to commit
            }
            allCommits.addAll(commits);
          }

          // Small delay to avoid rate limiting
          await Future.delayed(Duration(milliseconds: 100));
        } catch (e) {
          print('Error fetching commits for ${repo['name']}: $e');
          continue; // Skip this repo and continue with others
        }
      }

      // Sort by commit date (most recent first)
      allCommits.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['commit']['committer']['date']);
          final dateB = DateTime.parse(b['commit']['committer']['date']);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0; // If date parsing fails, maintain current order
        }
      });

      return allCommits.take(20).toList(); // Return latest 20 commits
    } catch (e) {
      print('Error fetching recent commits: $e');
      return []; // Return empty list on error
    }
  }

  // Test API connection
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Get rate limit status
  Future<Map<String, dynamic>> getRateLimit() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rate_limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch rate limit: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rate limit: $e');
      return {};
    }
  }
}
