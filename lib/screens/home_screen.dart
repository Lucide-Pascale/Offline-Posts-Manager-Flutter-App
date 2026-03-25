import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../services/database_service.dart';
import 'add_edit_post_screen.dart';
import 'post_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  late Future<List<Post>> _postsFuture;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _postsFuture = _dbService.getAllPosts();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _refreshPosts() {
    setState(() {
      _postsFuture = _dbService.getAllPosts();
    });
  }

  void _navigateToAddPost() async {
    _fabAnimationController.forward();
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return AddEditPostScreen(post: null);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
    _fabAnimationController.reverse();
    if (result == true) {
      _refreshPosts();
    }
  }

  void _navigateToDetails(Post post) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return PostDetailsScreen(post: post);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            alignment: Alignment.center,
            child: child,
          );
        },
      ),
    ).then((_) => _refreshPosts());
  }

  void _deletePost(int postId) {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteConfirmationDialog(
          onConfirm: () async {
            Navigator.pop(context);
            await _dbService.deletePost(postId);
            _refreshPosts();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post deleted successfully'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Manager'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first post',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: _PostCard(
                  post: post,
                  onTap: () => _navigateToDetails(post),
                  onEdit: () async {
                    final result = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AddEditPostScreen(post: post);
                        },
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          return SlideTransition(position: animation.drive(tween), child: child);
                        },
                      ),
                    );
                    if (result == true) {
                      _refreshPosts();
                    }
                  },
                  onDelete: () => _deletePost(post.id!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
        ),
        child: FloatingActionButton(
          onPressed: _navigateToAddPost,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PostCard({
    required this.post,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.red.shade700,
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.post.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description preview
                  Text(
                    widget.post.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Timestamp and action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Timestamp
                      if (widget.post.updatedAt != null)
                        Text(
                          DateFormat('MMM d, yyyy').format(widget.post.updatedAt!),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      // Action buttons
                      Row(
                        children: [
                          // Edit button
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.amber.shade600),
                            onPressed: widget.onEdit,
                            tooltip: 'Edit',
                            splashRadius: 20,
                          ),
                          // Delete button
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade600),
                            onPressed: widget.onDelete,
                            tooltip: 'Delete',
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    required this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Post'),
      content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
          ),
          onPressed: onConfirm,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
