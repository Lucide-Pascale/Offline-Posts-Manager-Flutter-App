import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/post.dart';
import '../utils/app_theme.dart';

class AddEditPostScreen extends StatefulWidget {
  final Post? post;

  const AddEditPostScreen({super.key, this.post});

  @override
  State<AddEditPostScreen> createState() => _AddEditPostScreenState();
}

class _AddEditPostScreenState extends State<AddEditPostScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isSaving = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    if (_isEditing) {
      _titleController.text = widget.post!.title;
      _descriptionController.text = widget.post!.description;
    }
    _animController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        final updatedPost = widget.post!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
        );
        await _dbHelper.updatePost(updatedPost);
      } else {
        final newPost = Post(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          timestamp: DateTime.now(),
        );
        await _dbHelper.insertPost(newPost);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving post: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Post' : 'New Post'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppTheme.surfaceWhite,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _savePost,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentYellow,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('Save'),
                  ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD32F2F),
                          Color(0xFFB71C1C),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.accentYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _isEditing
                                ? Icons.edit_note_rounded
                                : Icons.post_add_rounded,
                            color: AppTheme.textBlack,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEditing ? 'Edit Post' : 'Create New Post',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.surfaceWhite,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isEditing
                                    ? 'Update your post details below'
                                    : 'Fill in the details for your new post',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      AppTheme.surfaceWhite.withAlpha(200),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title field label
                  _FieldLabel(
                    label: 'Post Title',
                    icon: Icons.title_rounded,
                    required: true,
                  ),
                  const SizedBox(height: 8),

                  // Title input
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textBlack,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter a compelling title...',
                      prefixIcon: Icon(
                        Icons.title_rounded,
                        color: AppTheme.subtleGrey,
                        size: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Title must be at least 3 characters';
                      }
                      if (value.trim().length > 120) {
                        return 'Title must be under 120 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Description field label
                  _FieldLabel(
                    label: 'Description',
                    icon: Icons.description_outlined,
                    required: true,
                  ),
                  const SizedBox(height: 8),

                  // Description input
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 8,
                    minLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textDark,
                      height: 1.6,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Write your post content here...',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      if (value.trim().length < 10) {
                        return 'Description must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Character count
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _descriptionController,
                    builder: (context, value, _) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${value.text.length} characters',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.subtleGrey,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: _SaveButton(
                      isEditing: _isEditing,
                      isSaving: _isSaving,
                      onPressed: _savePost,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppTheme.lightGrey),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppTheme.subtleGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool required;

  const _FieldLabel({
    required this.label,
    required this.icon,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryRed),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textBlack,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppTheme.primaryRed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _SaveButton extends StatefulWidget {
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isEditing,
    required this.isSaving,
    required this.onPressed,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: ElevatedButton(
          onPressed: widget.isSaving ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.primaryRed,
            disabledBackgroundColor: AppTheme.primaryRed.withAlpha(150),
          ),
          child: widget.isSaving
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.surfaceWhite,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Saving...'),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isEditing
                          ? Icons.check_circle_outline_rounded
                          : Icons.add_circle_outline_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isEditing ? 'Update Post' : 'Publish Post',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
