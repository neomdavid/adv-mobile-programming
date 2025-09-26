import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/article_model.dart';
import '../widgets/custom_text.dart';
import '../services/article_service.dart';
import '../constants/colors.dart';

class DetailScreen extends StatefulWidget {
  final Article article;
  final VoidCallback? onArticleUpdated;

  const DetailScreen({
    super.key,
    required this.article,
    this.onArticleUpdated,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isEditMode = false;
  bool _isLoading = false;

  // Controllers for edit mode
  late TextEditingController _titleController;
  late TextEditingController _nameController;
  late TextEditingController _contentController;
  late bool _isActive;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.article.title);
    _nameController = TextEditingController(text: widget.article.name);
    _contentController =
        TextEditingController(text: widget.article.content.join('\n'));
    _isActive = widget.article.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _initializeControllers();
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final contentList = _contentController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final articleData = {
        'title': _titleController.text.trim(),
        'name': _nameController.text.trim(),
        'content': contentList,
        'isActive': _isActive,
      };

      await ArticleService().updateArticle(widget.article.aid, articleData);

      if (mounted) {
        setState(() {
          _isEditMode = false;
          _isLoading = false;
        });

        widget.onArticleUpdated?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating article: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.h,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.baseContent.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.baseContent,
                  size: 20.sp,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              if (!_isEditMode)
                Container(
                  margin: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.baseContent.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.baseContent,
                      size: 20.sp,
                    ),
                    onPressed: _toggleEditMode,
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.surface, AppColors.background],
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 60.h),

                    // Hero Image Placeholder
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(60.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.baseContent.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.article_outlined,
                        size: 60.sp,
                        color: AppColors.primaryContent,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: _isEditMode
                          ? TextFormField(
                              controller: _titleController,
                              enabled: !_isLoading,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.baseContent,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter title...',
                                hintStyle: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neutral,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                            )
                          : CustomText(
                              text: widget.article.title,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Article Content
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta Information Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.base300,
                          width: 1,
                        ),
                      ),
                      child: _isEditMode
                          ? Column(
                              children: [
                                // Author Name Field
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
                                // Active Status Toggle
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Active',
                                      style: TextStyle(
                                          color: AppColors.baseContent)),
                                  value: _isActive,
                                  activeColor: AppColors.success,
                                  activeTrackColor: AppColors.success,
                                  thumbColor: MaterialStateProperty.all(
                                      AppColors.primaryContent),
                                  onChanged: _isLoading
                                      ? null
                                      : (val) =>
                                          setState(() => _isActive = val),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                // Author Info
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                        ),
                                        child: Icon(
                                          Icons.person_outline,
                                          size: 20.sp,
                                          color: AppColors.primaryContent,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text: 'Author',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          CustomText(
                                            text: widget.article.name,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Status Info
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: widget.article.isActive
                                        ? AppColors.success
                                        : AppColors.neutral,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        widget.article.isActive
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 16.sp,
                                        color: widget.article.isActive
                                            ? AppColors.successContent
                                            : AppColors.neutralContent,
                                      ),
                                      SizedBox(width: 8.w),
                                      CustomText(
                                        text: widget.article.isActive
                                            ? 'Active'
                                            : 'Inactive',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: widget.article.isActive
                                            ? AppColors.successContent
                                            : AppColors.neutralContent,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),

                    SizedBox(height: 24.h),

                    // Article Content
                    CustomText(
                      text: 'Article Content',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 16.h),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.base300,
                          width: 1,
                        ),
                      ),
                      child: _isEditMode
                          ? TextFormField(
                              controller: _contentController,
                              enabled: !_isLoading,
                              maxLines: 8,
                              decoration: InputDecoration(
                                labelText: 'Content (one item per line)',
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
                                    .split('\n')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();
                                if (contentList.isEmpty) {
                                  return 'At least one content item';
                                }
                                return null;
                              },
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.article.content.isNotEmpty) ...[
                                  for (int i = 0;
                                      i < widget.article.content.length;
                                      i++) ...[
                                    if (i > 0) SizedBox(height: 16.h),
                                    CustomText(
                                      text:
                                          '${i + 1}. ${widget.article.content[i]}',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ] else ...[
                                  CustomText(
                                    text: 'No content available',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ],
                              ],
                            ),
                    ),

                    SizedBox(height: 24.h),

                    // Action Buttons (Edit Mode)
                    if (_isEditMode) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _toggleEditMode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.neutral,
                                foregroundColor: AppColors.neutralContent,
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                minimumSize: Size(0, 36.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveChanges,
                              icon: _isLoading
                                  ? SizedBox(
                                      width: 14.w,
                                      height: 14.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppColors.successContent,
                                        ),
                                      ),
                                    )
                                  : Icon(Icons.save, size: 16.sp),
                              label: const Text('Save Changes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: AppColors.successContent,
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                minimumSize: Size(0, 36.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                    ],

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
