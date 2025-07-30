import 'package:flutter/material.dart';

class SocialFeedScreen extends StatelessWidget {
  final TextEditingController _postController = TextEditingController();

  SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with post input
        SizedBox(height: 50),
        _buildHeader(),
        // Feed content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Social Feed',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                _buildPostsList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // GitHub icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.account_tree, color: Colors.white, size: 16),
          ),
          SizedBox(width: 16),
          // Text input
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          // Post button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    final posts = _getPosts();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: posts.map((post) => _buildPostCard(post)).toList(),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(post.user),
          SizedBox(height: 12),
          Text(
            post.content,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade900),
          ),
          if (post.type == PostType.release) ...[
            SizedBox(height: 16),
            _buildReleaseCard(post.release!),
          ],
          if (post.type == PostType.starred) ...[
            SizedBox(height: 16),
            _buildRepoCard(post.repo!),
          ],
          if (post.type == PostType.code) ...[
            SizedBox(height: 16),
            _buildCodeBlock(post.code!),
          ],
          if (post.stats != null) ...[
            SizedBox(height: 16),
            _buildPostStats(post.stats!),
          ],
        ],
      ),
    );
  }

  Widget _buildPostHeader(User user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade300,
          child: Icon(Icons.person, color: Colors.grey.shade600),
        ),
        SizedBox(width: 12),
        Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.grey.shade900,
          ),
        ),
        if (user.time.isNotEmpty) ...[
          SizedBox(width: 8),
          Text(
            user.time,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
        Spacer(),
        Icon(Icons.more_horiz, color: Colors.grey.shade400),
      ],
    );
  }

  Widget _buildReleaseCard(Release release) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  release.version,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                release.repo,
                style: TextStyle(color: Colors.blue.shade600, fontSize: 13),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'README.md',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  release.title,
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  release.description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepoCard(Repository repo) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            repo.name,
            style: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            repo.description,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPostStats(PostStats stats) {
    return Row(
      children: [
        if (stats.comments > 0) ...[
          _buildStatButton(
            Icons.chat_bubble_outline,
            stats.comments.toString(),
          ),
          SizedBox(width: 24),
        ],
        if (stats.reactions > 0) ...[
          _buildStatButton(
            Icons.chat_bubble_outline,
            stats.reactions.toString(),
          ),
          SizedBox(width: 24),
        ],
        if (stats.likes > 0) ...[
          _buildStatButton(Icons.favorite_border, stats.likes.toString()),
          SizedBox(width: 24),
        ],
        if (stats.stars > 0) ...[
          _buildStatButton(Icons.star_border, stats.stars.toString()),
          SizedBox(width: 24),
        ],
        if (stats.bookmarks > 0) ...[
          _buildStatButton(Icons.bookmark_border, stats.bookmarks.toString()),
        ],
      ],
    );
  }

  Widget _buildStatButton(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      ],
    );
  }

  List<Post> _getPosts() {
    return [
      Post(
        id: 1,
        user: User(name: "Jake H.", time: "1h"),
        content: "Excited to release version 1.0 of our project!",
        type: PostType.release,
        release: Release(
          version: "v1.0.0",
          repo: "/example-user/example-project",
          title: "# Example Project",
          description: "This is an example project to demonstrate",
        ),
        stats: PostStats(comments: 2, reactions: 10, likes: 84),
      ),
      Post(
        id: 2,
        user: User(name: "Sarah L.", time: "2h"),
        content: "Learned about monads today! #TodayILearned",
        type: PostType.text,
        stats: PostStats(comments: 2, reactions: 10),
      ),
      Post(
        id: 3,
        user: User(name: "Alex W.", time: "5h"),
        content: "starred a repository",
        type: PostType.starred,
        repo: Repository(
          name: "octocat/Spoon-Knife",
          description: "This repo is for demonstration purposes only.",
        ),
        stats: PostStats(stars: 10),
      ),
      Post(
        id: 4,
        user: User(name: "Devon M.", time: "8h"),
        content: "Working on a dark mode UI for my app!",
        type: PostType.code,
        code:
            "styles.rss {\n  background-color: #242424;\n  color: #elelel;\n}",
        stats: PostStats(bookmarks: 22, comments: 12, likes: 12),
      ),
      Post(
        id: 5,
        user: User(name: "Chad B.", time: ""),
        content: "followed Tom R.",
        type: PostType.follow,
      ),
    ];
  }
}

// Data Models
class User {
  final String name;
  final String time;

  User({required this.name, required this.time});
}

class Post {
  final int id;
  final User user;
  final String content;
  final PostType type;
  final Release? release;
  final Repository? repo;
  final String? code;
  final PostStats? stats;

  Post({
    required this.id,
    required this.user,
    required this.content,
    required this.type,
    this.release,
    this.repo,
    this.code,
    this.stats,
  });
}

class Release {
  final String version;
  final String repo;
  final String title;
  final String description;

  Release({
    required this.version,
    required this.repo,
    required this.title,
    required this.description,
  });
}

class Repository {
  final String name;
  final String description;

  Repository({required this.name, required this.description});
}

class PostStats {
  final int comments;
  final int reactions;
  final int likes;
  final int stars;
  final int bookmarks;

  PostStats({
    this.comments = 0,
    this.reactions = 0,
    this.likes = 0,
    this.stars = 0,
    this.bookmarks = 0,
  });
}

enum PostType { release, text, starred, code, follow }
