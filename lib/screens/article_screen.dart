import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';
import '../widgets/custom_text.dart';
import 'detail_screen.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late Future<List<Article>> _futureArticles;
  late Future<void> loadFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  void _loadArticles() {
    _futureArticles = _getAllArticles();
    loadFuture = _getAllArticles().then((_) {});
  }

  Future<List<Article>> _getAllArticles() async {
    try {
      final response = await ArticleService().getAllArticle();

      // Map raw list to typed models once
      final articles = response.map((e) => Article.fromJson(e)).toList();

      setState(() {
        _allArticles = articles;
        _filteredArticles = articles;
      });

      return articles;
    } catch (e) {
      print('Error in _getAllArticles: $e');
      rethrow;
    }
  }

  Future<void> _openAddArticleDialog() async {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    bool isActive = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setLocalState) {
            List<String> _toList(String raw) {
              // Split by newlines or commas, trim, drop empties
              return raw
                  .split(RegExp(r'[\n,]'))
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
            }

            return AlertDialog(
              title: const Text('Add Article'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: authorController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Author / Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: contentController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText:
                              'Content (one item per line or comma-separated)',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) {
                          final items = _toList(v ?? '');
                          return items.isEmpty
                              ? 'At least one content item'
                              : null;
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
                        onChanged: (val) => setLocalState(() => isActive = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: isSaving ? null : () => save(),
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> save() async {
    // This function will be called from within the dialog context
    // where the variables are properly defined
  }

  Widget _statusChip(bool active) {
    return Chip(
      label: Text(active ? 'Active' : 'Inactive'),
      visualDensity: VisualDensity.compact,
      side: BorderSide(
        color: active ? Colors.green : Colors.grey,
      ),
    );
  }

  void _filterArticles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredArticles = _allArticles;
        _isSearching = false;
      } else {
        _filteredArticles = _allArticles
            .where((article) =>
                article.title.toLowerCase().contains(query.toLowerCase()) ||
                article.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _isSearching = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddArticleDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            // Search Text field must be here

            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: TextField(
                controller: _searchController,
                onChanged: _filterArticles,
                decoration: InputDecoration(
                  hintText: 'Search articles...',
                  prefixIcon: Icon(Icons.search, size: 20.sp),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 20.sp),
                          onPressed: () {
                            _searchController.clear();
                            _filterArticles('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            FutureBuilder<void>(
              future: loadFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SizedBox(
                    height: ScreenUtil().screenHeight * 0.6,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CustomText(
                          text: 'No equipment article to display...',
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: ScreenUtil().screenHeight * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator.adaptive(strokeWidth: 3.sp),
                          SizedBox(height: 10.h),
                          CustomText(
                            text:
                                'Waiting for the equipment articles to display...',
                            fontSize: 14.sp,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (_filteredArticles.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: Center(
                      child: CustomText(
                        text: 'No equipment article to display...',
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  shrinkWrap: true,
                  itemCount: _filteredArticles.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final article = _filteredArticles[index];
                    final preview =
                        article.content.isNotEmpty ? article.content.first : '';

                    return Card(
                      elevation: 1,
                      child: InkWell(
                        onTap: () {
                          debugPrint('Tapped index $index: ${article.aid}');
                          // Navigation to DetailScreen must be here
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                article: article,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(15),
                              vertical: ScreenUtil().setHeight(15)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            text: article.title.isEmpty
                                                ? 'Untitled'
                                                : article.title,
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.bold,
                                            maxLines: 2,
                                          ),
                                        ),
                                        _statusChip(article.isActive),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomText(
                                      text: article.name,
                                      fontSize: 13.sp,
                                    ),
                                    if (preview.isNotEmpty) ...[
                                      SizedBox(height: 6.h),
                                      CustomText(
                                        text: preview,
                                        fontSize: 12.sp,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
