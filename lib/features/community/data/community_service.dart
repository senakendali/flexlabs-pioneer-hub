import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

enum IconType {
  announcement,
  coding,
  project,
  career,
  discussion,
}

class CommunityChannel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String type;
  final int postsCount;
  final bool isAnnouncement;

  const CommunityChannel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.type,
    required this.postsCount,
    required this.isAnnouncement,
  });

  factory CommunityChannel.fromMap(Map<String, dynamic> map) {
    final name = _firstString([
          map['name'],
          map['title'],
          map['label'],
        ]) ??
        'Community Room';

    final slug = _firstString([
          map['slug'],
          map['key'],
        ]) ??
        '';

    final type = _firstString([
          map['type'],
          map['channel_type'],
          map['channelType'],
          slug,
          name,
        ]) ??
        'discussion';

    final lowerType = type.toLowerCase();

    return CommunityChannel(
      id: _firstInt([
            map['id'],
            map['channel_id'],
            map['channelId'],
          ]) ??
          0,
      name: name,
      slug: slug,
      description: _stripHtmlStatic(
            _firstString([
              map['description'],
              map['caption'],
              map['subtitle'],
            ]),
          ) ??
          'Join the discussion and stay connected with your batch.',
      type: type,
      postsCount: _firstInt([
            map['posts_count'],
            map['postsCount'],
            map['post_count'],
            map['postCount'],
            map['total_posts'],
            map['totalPosts'],
            map['count'],
            map['total'],
          ]) ??
          0,
      isAnnouncement: lowerType.contains('announcement') ||
          slug.toLowerCase().contains('announcement') ||
          name.toLowerCase().contains('announcement'),
    );
  }

  IconType get iconType {
    final lower = '$name $slug $type'.toLowerCase();

    if (lower.contains('announcement') || lower.contains('update')) {
      return IconType.announcement;
    }

    if (lower.contains('coding') ||
        lower.contains('error') ||
        lower.contains('debug')) {
      return IconType.coding;
    }

    if (lower.contains('project')) {
      return IconType.project;
    }

    if (lower.contains('career') || lower.contains('portfolio')) {
      return IconType.career;
    }

    return IconType.discussion;
  }
}

class CommunityPost {
  final int id;
  final String title;
  final String body;
  final String authorName;
  final String authorRole;
  final String createdAtLabel;
  final int commentsCount;
  final bool isSolved;
  final bool isAnnouncement;

  const CommunityPost({
    required this.id,
    required this.title,
    required this.body,
    required this.authorName,
    required this.authorRole,
    required this.createdAtLabel,
    required this.commentsCount,
    required this.isSolved,
    required this.isAnnouncement,
  });

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    final author = _asMapStatic(map['author']);
    final user = _asMapStatic(map['user']);
    final student = _asMapStatic(map['student']);
    final creator = _asMapStatic(map['creator']);
    final createdBy = _asMapStatic(map['created_by']);
    final createdByCamel = _asMapStatic(map['createdBy']);

    return CommunityPost(
      id: _firstInt([
            map['id'],
            map['post_id'],
            map['postId'],
          ]) ??
          0,
      title: _firstString([
            map['title'],
            map['subject'],
            map['name'],
          ]) ??
          'Untitled Post',
      body: _stripHtmlStatic(
            _firstString([
              map['body'],
              map['content'],
              map['description'],
              map['excerpt'],
              map['message'],
            ]),
          ) ??
          'No content preview available.',
      authorName: _firstString([
            author['name'],
            author['full_name'],
            author['fullName'],
            user['name'],
            user['full_name'],
            user['fullName'],
            student['name'],
            student['full_name'],
            student['fullName'],
            creator['name'],
            creator['full_name'],
            creator['fullName'],
            createdBy['name'],
            createdBy['full_name'],
            createdBy['fullName'],
            createdByCamel['name'],
            createdByCamel['full_name'],
            createdByCamel['fullName'],
            map['author_name'],
            map['authorName'],
            map['created_by_name'],
            map['createdByName'],
          ]) ??
          'Flexlabs Student',
      authorRole: _firstString([
            author['role'],
            user['role'],
            student['role'],
            creator['role'],
            createdBy['role'],
            createdByCamel['role'],
            map['author_role'],
            map['authorRole'],
          ]) ??
          'Pioneer',
      createdAtLabel: _firstString([
            map['created_at_label'],
            map['createdAtLabel'],
            map['created_at_human'],
            map['createdAtHuman'],
            map['created_at'],
            map['createdAt'],
            map['published_at'],
            map['publishedAt'],
          ]) ??
          'Recently',
      commentsCount: _firstInt([
            map['comments_count'],
            map['commentsCount'],
            map['comment_count'],
            map['commentCount'],
            map['replies_count'],
            map['repliesCount'],
          ]) ??
          _asListStatic(map['comments']).length,
      isSolved: _firstBool([
        map['is_solved'],
        map['isSolved'],
        map['solved'],
        map['has_solution'],
        map['hasSolution'],
      ]),
      isAnnouncement: _firstBool([
        map['is_announcement'],
        map['isAnnouncement'],
        map['announcement'],
      ]),
    );
  }
}

class CommunityComment {
  final int id;
  final String body;
  final String authorName;
  final String authorRole;
  final String createdAtLabel;

  const CommunityComment({
    required this.id,
    required this.body,
    required this.authorName,
    required this.authorRole,
    required this.createdAtLabel,
  });

  factory CommunityComment.fromMap(Map<String, dynamic> map) {
    final author = _asMapStatic(map['author']);
    final user = _asMapStatic(map['user']);
    final student = _asMapStatic(map['student']);
    final creator = _asMapStatic(map['creator']);
    final createdBy = _asMapStatic(map['created_by']);
    final createdByCamel = _asMapStatic(map['createdBy']);

    return CommunityComment(
      id: _firstInt([
            map['id'],
            map['comment_id'],
            map['commentId'],
          ]) ??
          0,
      body: _stripHtmlStatic(
            _firstString([
              map['body'],
              map['content'],
              map['comment'],
              map['message'],
            ]),
          ) ??
          '',
      authorName: _firstString([
            author['name'],
            author['full_name'],
            author['fullName'],
            user['name'],
            user['full_name'],
            user['fullName'],
            student['name'],
            student['full_name'],
            student['fullName'],
            creator['name'],
            creator['full_name'],
            creator['fullName'],
            createdBy['name'],
            createdBy['full_name'],
            createdBy['fullName'],
            createdByCamel['name'],
            createdByCamel['full_name'],
            createdByCamel['fullName'],
            map['author_name'],
            map['authorName'],
            map['created_by_name'],
            map['createdByName'],
          ]) ??
          'Flexlabs Student',
      authorRole: _firstString([
            author['role'],
            user['role'],
            student['role'],
            creator['role'],
            createdBy['role'],
            createdByCamel['role'],
            map['author_role'],
            map['authorRole'],
          ]) ??
          'Pioneer',
      createdAtLabel: _firstString([
            map['created_at_label'],
            map['createdAtLabel'],
            map['created_at_human'],
            map['createdAtHuman'],
            map['created_at'],
            map['createdAt'],
          ]) ??
          'Recently',
    );
  }
}

class CommunityPostDetail {
  final CommunityPost post;
  final List<CommunityComment> comments;

  const CommunityPostDetail({
    required this.post,
    required this.comments,
  });
}

class CommunityService {
  final ApiClient apiClient;

  CommunityService({
    required this.apiClient,
  });

  Future<List<CommunityChannel>> fetchChannels() async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.communityChannels,
        queryParameters: {
          '_': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final data = _asMap(response.data);

      final channels = _extractList(data, [
        ['data', 'channels'],
        ['data', 'channels', 'data'],
        ['data', 'channels', 'items'],
        ['data', 'channels', 'results'],
        ['data', 'data'],
        ['data', 'data', 'data'],
        ['channels'],
        ['channels', 'data'],
        ['items'],
        ['results'],
        ['data'],
      ]);

      return channels
          .map(CommunityChannel.fromMap)
          .where((channel) => channel.id > 0)
          .toList();
    } on DioException catch (error) {
      throw Exception(
        _extractMessage(error.response?.data) ??
            'Gagal memuat community channels.',
      );
    } catch (_) {
      throw Exception('Gagal memuat community channels.');
    }
  }

  Future<List<CommunityPost>> fetchPosts(int channelId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.channelPosts(channelId),
        queryParameters: {
          '_': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final data = _asMap(response.data);

      final posts = _extractList(data, [
        ['data', 'posts'],
        ['data', 'posts', 'data'],
        ['data', 'posts', 'items'],
        ['data', 'posts', 'results'],
        ['data', 'data'],
        ['data', 'data', 'data'],
        ['posts'],
        ['posts', 'data'],
        ['posts', 'items'],
        ['posts', 'results'],
        ['items'],
        ['results'],
        ['data'],
      ]);

      return posts
          .map(CommunityPost.fromMap)
          .where((post) => post.id > 0)
          .toList();
    } on DioException catch (error) {
      throw Exception(
        _extractMessage(error.response?.data) ??
            'Gagal memuat community posts.',
      );
    } catch (_) {
      throw Exception('Gagal memuat community posts.');
    }
  }

  Future<CommunityPostDetail> fetchPostDetail(int postId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.postDetail(postId),
        queryParameters: {
          '_': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final data = _asMap(response.data);
      final payload = _asMap(
        _readPath(data, ['data']) ?? data,
      );

      final postMap = _firstNonEmptyMap([
        payload['post'],
        payload['discussion'],
        payload['thread'],
        payload,
      ]);

      final comments = _extractList(payload, [
        ['comments'],
        ['comments', 'data'],
        ['comments', 'items'],
        ['comments', 'results'],
        ['post', 'comments'],
        ['post', 'comments', 'data'],
        ['discussion', 'comments'],
        ['discussion', 'comments', 'data'],
        ['thread', 'comments'],
        ['thread', 'comments', 'data'],
        ['replies'],
        ['replies', 'data'],
        ['post', 'replies'],
        ['post', 'replies', 'data'],
      ]);

      return CommunityPostDetail(
        post: CommunityPost.fromMap(postMap),
        comments: comments
            .map(CommunityComment.fromMap)
            .where((comment) => comment.id > 0 || comment.body.isNotEmpty)
            .toList(),
      );
    } on DioException catch (error) {
      throw Exception(
        _extractMessage(error.response?.data) ?? 'Gagal memuat detail post.',
      );
    } catch (_) {
      throw Exception('Gagal memuat detail post.');
    }
  }

  Future<CommunityPost> createPost({
    required int channelId,
    required String title,
    required String body,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.channelPosts(channelId),
        data: {
          'title': title,
          'body': body,

          // Backup kalau backend pakai field content.
          'content': body,
        },
      );

      final data = _asMap(response.data);
      final payload = _asMap(
        _readPath(data, ['data']) ?? data,
      );

      final postMap = _firstNonEmptyMap([
        payload['post'],
        payload['discussion'],
        payload['thread'],
        payload,
      ]);

      return CommunityPost.fromMap(postMap);
    } on DioException catch (error) {
      throw Exception(
        _extractMessage(error.response?.data) ?? 'Gagal membuat post baru.',
      );
    } catch (_) {
      throw Exception('Gagal membuat post baru.');
    }
  }

  String? _extractMessage(dynamic value) {
    final map = _asMap(value);

    final directMessage = _firstString([
      map['message'],
      map['error'],
    ]);

    if (directMessage != null) {
      return directMessage;
    }

    final errors = _asMap(map['errors']);

    if (errors.isNotEmpty) {
      final firstError = errors.values.first;

      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }

      return firstError.toString();
    }

    return null;
  }

  Map<String, dynamic> _firstNonEmptyMap(List<dynamic> values) {
    for (final value in values) {
      final map = _asMap(value);

      if (map.isNotEmpty) {
        return map;
      }
    }

    return {};
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is List) {
      return value.map(_asMap).where((item) => item.isNotEmpty).toList();
    }

    return [];
  }

  dynamic _readPath(Map<String, dynamic> source, List<String> path) {
    dynamic current = source;

    for (final key in path) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }

    return current;
  }

  List<Map<String, dynamic>> _extractList(
    Map<String, dynamic> source,
    List<List<String>> paths,
  ) {
    for (final path in paths) {
      final value = _readPath(source, path);

      final directList = _asList(value);
      if (directList.isNotEmpty) {
        return directList;
      }

      final valueMap = _asMap(value);

      final paginatedData = _asList(valueMap['data']);
      if (paginatedData.isNotEmpty) {
        return paginatedData;
      }

      final items = _asList(valueMap['items']);
      if (items.isNotEmpty) {
        return items;
      }

      final results = _asList(valueMap['results']);
      if (results.isNotEmpty) {
        return results;
      }
    }

    return [];
  }
}

String? _firstString(List<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;

    final text = value.toString().trim();

    if (text.isNotEmpty && text != 'null') {
      return text;
    }
  }

  return null;
}

int? _firstInt(List<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;

    if (value is int) return value;

    final parsed = int.tryParse(value.toString());

    if (parsed != null) return parsed;
  }

  return null;
}

bool _firstBool(List<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;

    if (value is bool) return value;

    final text = value.toString().toLowerCase().trim();

    if (text == '1' || text == 'true' || text == 'yes') {
      return true;
    }

    if (text == '0' || text == 'false' || text == 'no') {
      return false;
    }
  }

  return false;
}

Map<String, dynamic> _asMapStatic(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return {};
}

List<Map<String, dynamic>> _asListStatic(dynamic value) {
  if (value is List) {
    return value
        .map(_asMapStatic)
        .where((item) => item.isNotEmpty)
        .toList();
  }

  return [];
}

String? _stripHtmlStatic(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  return value
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .trim();
}