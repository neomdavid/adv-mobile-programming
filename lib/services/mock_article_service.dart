import 'dart:convert';

class MockArticleService {
  // Sample article data that matches your backend response format
  static final List<Map<String, dynamic>> _mockArticles = [
    {
      'id': 1,
      'title': 'Getting Started with Flutter Development',
      'body': 'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. This article covers the basics of setting up your development environment and creating your first Flutter app.',
      'userId': 1,
      'tags': ['flutter', 'mobile', 'development'],
      'createdAt': '2024-01-15T10:30:00Z',
      'updatedAt': '2024-01-15T10:30:00Z',
    },
    {
      'id': 2,
      'title': 'Understanding State Management in Flutter',
      'body': 'State management is crucial for building scalable Flutter applications. Learn about different approaches including Provider, Bloc, Riverpod, and GetX. Discover best practices for managing application state effectively.',
      'userId': 2,
      'tags': ['flutter', 'state-management', 'provider'],
      'createdAt': '2024-01-14T14:20:00Z',
      'updatedAt': '2024-01-14T14:20:00Z',
    },
    {
      'id': 3,
      'title': 'Building Responsive UIs with Flutter ScreenUtil',
      'body': 'Create responsive user interfaces that work across different screen sizes and orientations. Flutter ScreenUtil provides utilities for adapting your UI to various device dimensions and pixel densities.',
      'userId': 3,
      'tags': ['flutter', 'responsive', 'ui', 'screenutil'],
      'createdAt': '2024-01-13T09:15:00Z',
      'updatedAt': '2024-01-13T09:15:00Z',
    },
    {
      'id': 4,
      'title': 'HTTP Requests and API Integration in Flutter',
      'body': 'Learn how to integrate your Flutter app with REST APIs using the http package. This guide covers making GET, POST, PUT, and DELETE requests, handling responses, and implementing proper error handling.',
      'userId': 1,
      'tags': ['flutter', 'http', 'api', 'rest'],
      'createdAt': '2024-01-12T16:45:00Z',
      'updatedAt': '2024-01-12T16:45:00Z',
    },
    {
      'id': 5,
      'title': 'Custom Widgets and Reusable Components',
      'body': 'Master the art of creating custom widgets in Flutter. Learn about StatelessWidget vs StatefulWidget, composition patterns, and how to build reusable components that enhance your app\'s maintainability.',
      'userId': 2,
      'tags': ['flutter', 'widgets', 'custom', 'components'],
      'createdAt': '2024-01-11T11:30:00Z',
      'updatedAt': '2024-01-11T11:30:00Z',
    },
    {
      'id': 6,
      'title': 'Navigation and Routing in Flutter Apps',
      'body': 'Explore different navigation patterns in Flutter including named routes, nested navigation, and deep linking. Understand how to implement smooth transitions and maintain navigation state.',
      'userId': 3,
      'tags': ['flutter', 'navigation', 'routing', 'deep-linking'],
      'createdAt': '2024-01-10T13:20:00Z',
      'updatedAt': '2024-01-10T13:20:00Z',
    },
    {
      'id': 7,
      'title': 'Testing Flutter Applications',
      'body': 'Comprehensive guide to testing Flutter applications including unit tests, widget tests, and integration tests. Learn testing best practices and how to achieve high test coverage for reliable apps.',
      'userId': 1,
      'tags': ['flutter', 'testing', 'unit-tests', 'widget-tests'],
      'createdAt': '2024-01-09T15:10:00Z',
      'updatedAt': '2024-01-09T15:10:00Z',
    },
    {
      'id': 8,
      'title': 'Performance Optimization Techniques',
      'body': 'Discover techniques to optimize your Flutter app\'s performance. Learn about lazy loading, image optimization, memory management, and profiling tools to identify and fix performance bottlenecks.',
      'userId': 2,
      'tags': ['flutter', 'performance', 'optimization', 'profiling'],
      'createdAt': '2024-01-08T10:00:00Z',
      'updatedAt': '2024-01-08T10:00:00Z',
    },
  ];

  /// Simulates fetching all articles
  Future<List<Map<String, dynamic>>> getAllArticle() async {
    // Simulate a small network delay for realistic feel
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return the mock data
    return _mockArticles;
  }
}
