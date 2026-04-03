import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/forum_provider.dart';
import 'create_post_screen.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    context.read<ForumProvider>().fetchForumPosts();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadPosts();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: Consumer2<AuthProvider, ForumProvider>(
        builder: (context, authProvider, forumProvider, child) {
          if (forumProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final posts = forumProvider.posts;

          if (posts.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No forum posts yet",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Create the first post!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToCreatePost(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9E75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Create Post",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              }

              final post = posts[index - 1];
              final userId = authProvider.user?.uid ?? "";
              final userHasUpvoted = post.upvotedBy.contains(userId);
              final userHasDownvoted = post.downvotedBy.contains(userId);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF1D9E75),
                            child: Text(
                              post.authorName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "3 hours ago",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (post.isAnonymous)
                            Chip(
                              label: const Text("Anonymous"),
                              backgroundColor: Colors.grey[200],
                              labelStyle: const TextStyle(fontSize: 11),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (post.tags.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: post.tags
                              .take(3)
                              .map<Widget>(
                                (tag) => Chip(
                                  label: Text(
                                    "#$tag",
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleUpvote(
                              context,
                              post.postId,
                              userId,
                              userHasUpvoted,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: userHasUpvoted
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.thumb_up,
                                    size: 16,
                                    color: userHasUpvoted
                                        ? const Color(0xFF1D9E75)
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    post.upvotes.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: userHasUpvoted
                                          ? const Color(0xFF1D9E75)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _toggleDownvote(
                              context,
                              post.postId,
                              userId,
                              userHasDownvoted,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: userHasDownvoted
                                    ? const Color(0xFFFEEBEE)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.thumb_down,
                                    size: 16,
                                    color: userHasDownvoted
                                        ? Colors.red[600]
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    post.downvotes.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: userHasDownvoted
                                          ? Colors.red[600]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _showPostOptions(context, post.postId),
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToCreatePost(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    );
  }

  void _toggleUpvote(
    BuildContext context,
    String postId,
    String userId,
    bool alreadyUpvoted,
  ) {
    if (alreadyUpvoted) {
      context.read<ForumProvider>().removeVote(postId, userId);
    } else {
      context.read<ForumProvider>().upvotePost(postId, userId);
    }
  }

  void _toggleDownvote(
    BuildContext context,
    String postId,
    String userId,
    bool alreadyDownvoted,
  ) {
    if (alreadyDownvoted) {
      context.read<ForumProvider>().removeVote(postId, userId);
    } else {
      context.read<ForumProvider>().downvotePost(postId, userId);
    }
  }

  void _showPostOptions(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text("Report Post"),
              onTap: () {
                Navigator.pop(context);
                _reportPost(context, postId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Share"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _reportPost(BuildContext context, String postId) {
    final userId = context.read<AuthProvider>().user?.uid ?? "";
    context.read<ForumProvider>().reportPost(postId, userId).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Post reported"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
