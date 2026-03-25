import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/database_service.dart';

class AddEditPostScreen extends StatefulWidget {
  final Post? post;

  const AddEditPostScreen({
    this.post,
    super.key,
  });

  @override
  State<AddEditPostScreen> createState() => _AddEditPostScreenState();
}

class _AddEditPostScreenState extends State<AddEditPostScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _descriptionController = TextEditingController(text: widget.post?.description ?? '');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      if (widget.post == null) {
        // Create new post
        await _dbService.createPost(
          Post(
            title: title,
            description: description,
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post created successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Update existing post
        await _dbService.updatePost(
          widget.post!.copyWith(
            title: title,
            description: description,
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post updated successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.blue,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.post != null;

    return WillPopScope(
      onWillPop: () async {
        if (_isSubmitting) return false;
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Post' : 'Create Post'),
          elevation: 0,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isEditMode ? Colors.blue.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isEditMode ? Colors.blue.shade200 : Colors.red.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isEditMode ? Icons.edit : Icons.add_circle,
                          size: 32,
                          color: isEditMode ? Colors.blue.shade700 : Colors.red.shade700,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEditMode ? 'Update your post' : 'Create a new post',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: isEditMode ? Colors.blue.shade700 : Colors.red.shade700,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Post Title',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        maxLength: 200,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Enter post title...',
                          prefixIcon: const Icon(Icons.title),
                          counterText: '',
                          suffixIcon: _titleController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _titleController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title cannot be empty';
                          }
                          if (value.trim().length < 3) {
                            return 'Title must be at least 3 characters long';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLength: 2000,
                        maxLines: 8,
                        minLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Enter post description...',
                          alignLabelWithHint: true,
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description cannot be empty';
                          }
                          if (value.trim().length < 10) {
                            return 'Description must be at least 10 characters long';
                          }
                          return null;
                        },
                      ),
                      Text(
                        '${_descriptionController.text.length} / 2000',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.95 + (_animationController.value * 0.05),
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitForm,
                          icon: _isSubmitting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.8),
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(isEditMode ? Icons.update : Icons.check),
                          label: Text(
                            _isSubmitting
                                ? 'Processing...'
                                : (isEditMode ? 'Update Post' : 'Create Post'),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Cancel button
                  OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),

                  const SizedBox(height: 24),

                  // Info section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'All posts are stored locally on your device.\nNo internet connection required!',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade700,
                                ),
                          ),
                        ),
                      ],
                    ),
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
