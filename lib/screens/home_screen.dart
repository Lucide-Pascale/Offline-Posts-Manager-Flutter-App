import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/post.dart';
import '../utils/app_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'add_edit_post_screen.dart';
import 'post_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Post> _posts = [];
  bool _isLoading = true;
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScaleAnim = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.elasticOut,
    );
    _loadPosts();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _dbHelper.getAllPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
        _fabAnimController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load posts: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _deletePost(Post post) async {
    await _dbHelper.deletePost(post.id!);
    if (mounted) {
      setState(() => _posts.removeWhere((p) => p.id == post.id));
      _showSnackBar('Post deleted successfully', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.delete_rounded : Icons.check_circle_rounded,
              color: AppTheme.surfaceWhite,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor:
            isError ? AppTheme.primaryRed : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _navigateToAddPost() async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const AddEditPostScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
    if (result == true) {
      _loadPosts();
      _showSnackBar('Post created successfully');
    }
  }

  Future<void> _navigateToEditPost(Post post) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => AddEditPostScreen(post: post),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
    if (result == true) {
      _loadPosts();
      _showSnackBar('Post updated successfully');
    }
  }

  Future<void> _navigateToDetails(Post post) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => PostDetailsScreen(post: post),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Offline Posts Manager'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _posts.isEmpty
                    ? const SizedBox.shrink()
                    : Container(
                        key: ValueKey(_posts.length),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_posts.length} Post${_posts.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: AppTheme.textBlack,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            )
          : _posts.isEmpty
              ? _buildEmptyState()
              : _buildPostsList(),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnim,
        child: FloatingActionButton(
          onPressed: _navigateToAddPost,
          tooltip: 'Add New Post',
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.article_outlined,
              size: 48,
              color: AppTheme.primaryRed,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Posts Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to create\nyour first post',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.subtleGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToAddPost,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return RefreshIndicator(
      color: AppTheme.primaryRed,
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PostCard(
              post: post,
              index: index,
              onTap: () => _navigateToDetails(post),
              onEdit: () => _navigateToEditPost(post),
              onDelete: () => showDeleteConfirmation(
                context,
                postTitle: post.title,
                onConfirm: () => _deletePost(post),
              ),
            ),
          );
        },
      ),
    );
  }
}
