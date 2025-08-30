import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/article_model.dart';
import '../services/mock_article_service.dart';
import '../widgets/custom_text.dart';
import 'article_details_screen.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late Future<List<Article>> _futureArticles;
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
  }

  Future<List<Article>> _getAllArticles() async {
    try {
      final response = await MockArticleService().getAllArticle();
      
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

  void _filterArticles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredArticles = _allArticles;
        _isSearching = false;
      } else {
        _filteredArticles = _allArticles
            .where((article) =>
                article.title.toLowerCase().contains(query.toLowerCase()) ||
                article.body.toLowerCase().contains(query.toLowerCase()))
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
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
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
          // List
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: _futureArticles,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomText(
                        text: 'No articles to display.',
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator.adaptive(strokeWidth: 3.sp),
                        SizedBox(height: 10.h),
                        CustomText(
                          text: 'Loading articles...',
                          fontSize: 14.sp,
                        ),
                      ],
                    ),
                  );
                }
                final articles = snapshot.data ?? [];
                
                if (articles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomText(
                        text: 'No articles to display.',
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: _filteredArticles.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final article = _filteredArticles[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ArticleDetailsScreen(
                                article: article,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // If you have thumbnails, place an Image here.
                              // Otherwise, just use the text area expanded.
                              Placeholder(
                                fallbackHeight: 100.h,
                                fallbackWidth: 100.w,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    CustomText(
                                      text: article.title,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      // prevent overflow
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6.h),
                                    // Body preview
                                    CustomText(
                                      text: article.body,
                                      fontSize: 13.sp,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
          ),
        ],
      ),
    );
  }
}
