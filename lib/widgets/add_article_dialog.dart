import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:david_advmobprog/services/article_service.dart';
import 'package:david_advmobprog/widgets/custom_text.dart';

class AddArticleDialog extends StatefulWidget {
  final VoidCallback onArticleAdded;

  const AddArticleDialog({
    super.key,
    required this.onArticleAdded,
  });

  @override
  State<AddArticleDialog> createState() => _AddArticleDialogState();
}

class _AddArticleDialogState extends State<AddArticleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  bool isActive = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void setLocalState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  Future<void> _submitArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setLocalState(() => _isLoading = true);

    try {
      final contentList = _contentController.text
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final articleData = {
        'title': _titleController.text.trim(),
        'name': _nameController.text.trim(),
        'content': contentList,
        'isActive': isActive,
      };

      await ArticleService().createArticle(articleData);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onArticleAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding article: $e')),
        );
      }
    } finally {
      if (mounted) {
        setLocalState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: CustomText(
        text: 'Add Article',
        fontSize: 23.sp,
        fontWeight: FontWeight.normal,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loading indicator when submitting
              if (_isLoading)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green.shade400,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Adding article...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isLoading) SizedBox(height: 16.h),
              TextFormField(
                controller: _titleController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Author Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _contentController,
                enabled: !_isLoading,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Content (separate with commas or new lines)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter content';
                  }
                  final contentList = value
                      .split(RegExp(r'[,\n]'))
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  if (contentList.isEmpty) {
                    return 'At least one content item';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.h),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: isActive,
                activeColor: Colors.green.shade400,
                activeTrackColor: Colors.green.shade400,
                thumbColor: MaterialStateProperty.all(Colors.white),
                onChanged: _isLoading
                    ? null
                    : (val) => setLocalState(() => isActive = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _submitArticle,
          icon: _isLoading
              ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              : const Icon(Icons.save),
          label: const Text('Save'),
        ),
      ],
    );
  }
}
