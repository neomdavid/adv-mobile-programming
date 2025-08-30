import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/article_model.dart';
import '../widgets/custom_text.dart';

class ArticleDetailsScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailsScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
      
          SliverAppBar(
            expandedHeight: 300.h,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20.sp,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark 
                        ? [Colors.grey[900]!, Colors.black]
                        : [Colors.grey[100]!, Colors.white],
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
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(60.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.article_outlined,
                        size: 60.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Article Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomText(
                        text: article.title,
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
                      color: isDark ? Colors.grey[900] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Author Info
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  size: 20.sp,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'Author',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  CustomText(
                                    text: 'User ${article.userId}',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Date Info
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16.sp,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              SizedBox(width: 8.w),
                              CustomText(
                                text: _formatDate(article.createdAt ?? ''),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
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
                      color: isDark ? Colors.grey[900] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: CustomText(
                      text: article.body,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Tags Section
                  if (article.tags != null && article.tags!.isNotEmpty) ...[
                    CustomText(
                      text: 'Tags',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 16.h),
                    
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: article.tags!.map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(
                              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: CustomText(
                            text: '#$tag',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  SizedBox(height: 24.h),
                  
                  // Last Updated
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.update_outlined,
                          size: 20.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        SizedBox(width: 12.w),
                        CustomText(
                          text: 'Last updated: ${_formatDate(article.updatedAt ?? '')}',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Unknown';
    
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
