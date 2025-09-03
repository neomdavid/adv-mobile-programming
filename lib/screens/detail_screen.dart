import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/article_model.dart';
import '../widgets/custom_text.dart';

class DetailScreen extends StatelessWidget {
  final Article article;

  const DetailScreen({
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
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  size: 20.sp,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
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
                                    text: article.name,
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
                            color: article.isActive
                                ? (isDark
                                    ? Colors.green[800]
                                    : Colors.green[100])
                                : (isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                article.isActive
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16.sp,
                                color: article.isActive
                                    ? (isDark
                                        ? Colors.green[400]
                                        : Colors.green[600])
                                    : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                              ),
                              SizedBox(width: 8.w),
                              CustomText(
                                text: article.isActive ? 'Active' : 'Inactive',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.content.isNotEmpty) ...[
                          for (int i = 0; i < article.content.length; i++) ...[
                            if (i > 0) SizedBox(height: 16.h),
                            CustomText(
                              text: '${i + 1}. ${article.content[i]}',
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

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
