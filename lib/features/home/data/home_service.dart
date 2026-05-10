import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class HomeDashboardData {
  final int studentId;
  final String studentName;
  final String programName;
  final String batchName;
  final String? avatarUrl;

  final int notesCount;
  final int certificateCount;
  final int reportCardCount;
  final int updateCount;
  final int discussionCount;
  final int mentoringCount;

  final bool profileIncomplete;
  final String latestAnnouncementTitle;
  final String latestAnnouncementSubtitle;
  final String latestDiscussionTitle;
  final String latestDiscussionSubtitle;

  const HomeDashboardData({
    required this.studentId,
    required this.studentName,
    required this.programName,
    required this.batchName,
    required this.avatarUrl,
    required this.notesCount,
    required this.certificateCount,
    required this.reportCardCount,
    required this.updateCount,
    required this.discussionCount,
    required this.mentoringCount,
    required this.profileIncomplete,
    required this.latestAnnouncementTitle,
    required this.latestAnnouncementSubtitle,
    required this.latestDiscussionTitle,
    required this.latestDiscussionSubtitle,
  });

  factory HomeDashboardData.empty() {
    return const HomeDashboardData(
      studentId: 0,
      studentName: 'Pioneer',
      programName: 'Flexlabs Program',
      batchName: 'Active Batch',
      avatarUrl: null,
      notesCount: 0,
      certificateCount: 0,
      reportCardCount: 0,
      updateCount: 0,
      discussionCount: 0,
      mentoringCount: 0,
      profileIncomplete: true,
      latestAnnouncementTitle: 'No announcement yet',
      latestAnnouncementSubtitle: 'Latest updates will appear here.',
      latestDiscussionTitle: 'No discussion yet',
      latestDiscussionSubtitle: 'Batch discussions will appear here.',
    );
  }

  HomeDashboardData copyWith({
    int? studentId,
    String? studentName,
    String? programName,
    String? batchName,
    String? avatarUrl,
    int? notesCount,
    int? certificateCount,
    int? reportCardCount,
    int? updateCount,
    int? discussionCount,
    int? mentoringCount,
    bool? profileIncomplete,
    String? latestAnnouncementTitle,
    String? latestAnnouncementSubtitle,
    String? latestDiscussionTitle,
    String? latestDiscussionSubtitle,
  }) {
    return HomeDashboardData(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      programName: programName ?? this.programName,
      batchName: batchName ?? this.batchName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notesCount: notesCount ?? this.notesCount,
      certificateCount: certificateCount ?? this.certificateCount,
      reportCardCount: reportCardCount ?? this.reportCardCount,
      updateCount: updateCount ?? this.updateCount,
      discussionCount: discussionCount ?? this.discussionCount,
      mentoringCount: mentoringCount ?? this.mentoringCount,
      profileIncomplete: profileIncomplete ?? this.profileIncomplete,
      latestAnnouncementTitle:
          latestAnnouncementTitle ?? this.latestAnnouncementTitle,
      latestAnnouncementSubtitle:
          latestAnnouncementSubtitle ?? this.latestAnnouncementSubtitle,
      latestDiscussionTitle: latestDiscussionTitle ?? this.latestDiscussionTitle,
      latestDiscussionSubtitle:
          latestDiscussionSubtitle ?? this.latestDiscussionSubtitle,
    );
  }
}

class HomeService {
  final ApiClient apiClient;

  HomeService({
    required this.apiClient,
  });

  Future<HomeDashboardData> fetchHomeDashboard() async {
    HomeDashboardData result = HomeDashboardData.empty();

    final responses = await Future.wait<Response?>(
      [
        _safeGet(ApiConstants.profile),
        _safeGet(ApiConstants.notes),
        _safeGet(ApiConstants.academicDocuments),
        _safeGet(ApiConstants.communityHome),
        _safeGet(ApiConstants.mentoringInstructors),
      ],
    );

    result = _applyProfile(result, _asMap(responses[0]?.data));
    result = _applyNotes(result, _asMap(responses[1]?.data));
    result = _applyAcademicDocuments(result, _asMap(responses[2]?.data));
    result = _applyCommunity(result, _asMap(responses[3]?.data));
    result = _applyMentoring(result, _asMap(responses[4]?.data));

    return result;
  }

  Future<Response?> _safeGet(String path) async {
    try {
      return await apiClient.dio.get(path);
    } catch (_) {
      return null;
    }
  }

  HomeDashboardData _applyProfile(
    HomeDashboardData current,
    Map<String, dynamic> response,
  ) {
    final data = _asMap(response['data']);

    final student = _asMap(data['student']);
    final profile = _asMap(data['profile']);
    final summaries = _asMap(data['summaries']);
    final learningProgress = _asList(data['learning_progress']);

    final firstCourse =
        learningProgress.isNotEmpty ? learningProgress.first : <String, dynamic>{};

    final studentId = _firstInt([
      student['id'],
      student['student_id'],
      student['studentId'],
      data['student_id'],
      data['studentId'],
    ]);

    final name = _firstString([
      student['full_name'],
      student['fullName'],
      student['name'],
      profile['name'],
      data['name'],
    ]);

    final programName = _firstString([
      profile['program'],
      profile['program_name'],
      profile['programName'],
      firstCourse['title'],
      firstCourse['name'],
      data['program_name'],
      data['programName'],
    ]);

    final batchName = _firstString([
      firstCourse['batch_name'],
      firstCourse['batchName'],
      firstCourse['caption'],
      data['batch_name'],
      data['batchName'],
      profile['batch_name'],
      profile['batchName'],
    ]);

    final rawAvatarUrl = _firstString([
      student['avatar_url'],
      student['avatarUrl'],
      student['avatar'],
      student['photo_url'],
      student['photoUrl'],
      student['profile_photo_url'],
      student['profilePhotoUrl'],
      student['profile_photo_path'],
      student['profilePhotoPath'],
      student['image_url'],
      student['imageUrl'],
      profile['avatar_url'],
      profile['avatarUrl'],
      profile['photo_url'],
      profile['photoUrl'],
    ]);

    final avatarUrl = _buildAvatarProxyUrl(
      studentId: studentId,
      rawAvatarUrl: rawAvatarUrl,
    );

    final bio = _firstString([
      student['bio'],
      profile['bio'],
    ]);

    final goal = _firstString([
      student['goal'],
      student['learning_goal'],
      student['learningGoal'],
      student['career_goal'],
      student['careerGoal'],
      profile['goal'],
      profile['learning_goal'],
      profile['learningGoal'],
    ]);

    final certificatesCount = _firstInt([
      summaries['certificates'],
      summaries['certificate_count'],
      summaries['certificateCount'],
    ]);

    return current.copyWith(
      studentId: studentId ?? current.studentId,
      studentName: name ?? current.studentName,
      programName: programName ?? current.programName,
      batchName: batchName ?? current.batchName,
      avatarUrl: avatarUrl,
      certificateCount: certificatesCount ?? current.certificateCount,
      profileIncomplete: bio == null || goal == null,
    );
  }

  HomeDashboardData _applyNotes(
    HomeDashboardData current,
    Map<String, dynamic> response,
  ) {
    final notes = _extractList(response, [
      ['data', 'notes'],
      ['data', 'data'],
      ['notes'],
      ['data'],
    ]);

    final total = _firstInt([
      _readPath(response, ['data', 'total']),
      _readPath(response, ['data', 'notes_count']),
      _readPath(response, ['data', 'notesCount']),
      _readPath(response, ['total']),
      notes.length,
    ]);

    return current.copyWith(
      notesCount: total ?? notes.length,
    );
  }

  HomeDashboardData _applyAcademicDocuments(
    HomeDashboardData current,
    Map<String, dynamic> response,
  ) {
    final data = _asMap(response['data']);

    final certificates = _extractList(response, [
      ['data', 'certificates'],
      ['certificates'],
    ]);

    final reportCards = _extractList(response, [
      ['data', 'report_cards'],
      ['data', 'reportCards'],
      ['report_cards'],
      ['reportCards'],
    ]);

    final documents = _extractList(response, [
      ['data', 'documents'],
      ['documents'],
      ['data'],
    ]);

    int certificateCount = _firstInt([
          data['certificates_count'],
          data['certificatesCount'],
          data['certificate_count'],
          data['certificateCount'],
        ]) ??
        certificates.length;

    int reportCardCount = _firstInt([
          data['report_cards_count'],
          data['reportCardsCount'],
          data['report_card_count'],
          data['reportCardCount'],
        ]) ??
        reportCards.length;

    if (documents.isNotEmpty && certificateCount == 0 && reportCardCount == 0) {
      certificateCount = documents.where((item) {
        final type = _firstString([
          item['type'],
          item['document_type'],
          item['documentType'],
          item['category'],
        ])?.toLowerCase();

        return type?.contains('certificate') == true;
      }).length;

      reportCardCount = documents.where((item) {
        final type = _firstString([
          item['type'],
          item['document_type'],
          item['documentType'],
          item['category'],
        ])?.toLowerCase();

        return type?.contains('report') == true;
      }).length;
    }

    return current.copyWith(
      certificateCount: certificateCount,
      reportCardCount: reportCardCount,
    );
  }

  HomeDashboardData _applyCommunity(
    HomeDashboardData current,
    Map<String, dynamic> response,
  ) {
    final data = _asMap(response['data']);

    final channels = _asList(data['channels']);
    final latestAnnouncements = _asList(data['latest_announcements']);
    final latestDiscussions = _asList(data['latest_discussions']);

    final announcement = latestAnnouncements.isNotEmpty
        ? _asMap(latestAnnouncements.first)
        : <String, dynamic>{};

    final discussion = latestDiscussions.isNotEmpty
        ? _asMap(latestDiscussions.first)
        : <String, dynamic>{};

    int updatesCount = latestAnnouncements.length;
    int discussionCount = latestDiscussions.length;

    if (channels.isNotEmpty) {
      for (final item in channels) {
        final channel = _asMap(item);
        final type = _firstString([
          channel['type'],
          channel['slug'],
          channel['name'],
        ])?.toLowerCase();

        final count = _firstInt([
          channel['posts_count'],
          channel['postsCount'],
          channel['count'],
          channel['total'],
        ]);

        if (type != null && type.contains('announcement')) {
          updatesCount = count ?? updatesCount;
        }

        if (type != null &&
            (type.contains('discussion') ||
                type.contains('coding') ||
                type.contains('project') ||
                type.contains('career') ||
                type.contains('general'))) {
          discussionCount += count ?? 0;
        }
      }
    }

    return current.copyWith(
      updateCount: updatesCount,
      discussionCount: discussionCount,
      latestAnnouncementTitle: _firstString([
            announcement['title'],
            announcement['name'],
          ]) ??
          current.latestAnnouncementTitle,
      latestAnnouncementSubtitle: _stripHtml(
            _firstString([
              announcement['body'],
              announcement['description'],
              announcement['excerpt'],
            ]),
          ) ??
          current.latestAnnouncementSubtitle,
      latestDiscussionTitle: _firstString([
            discussion['title'],
            discussion['name'],
          ]) ??
          current.latestDiscussionTitle,
      latestDiscussionSubtitle: _stripHtml(
            _firstString([
              discussion['body'],
              discussion['description'],
              discussion['excerpt'],
            ]),
          ) ??
          current.latestDiscussionSubtitle,
    );
  }

  HomeDashboardData _applyMentoring(
    HomeDashboardData current,
    Map<String, dynamic> response,
  ) {
    final instructors = _extractList(response, [
      ['data', 'instructors'],
      ['instructors'],
      ['data'],
    ]);

    return current.copyWith(
      mentoringCount: instructors.length,
    );
  }

  String? _buildAvatarProxyUrl({
    required int? studentId,
    required String? rawAvatarUrl,
  }) {
    if (rawAvatarUrl == null || rawAvatarUrl.trim().isEmpty) {
      return null;
    }

    if (studentId == null || studentId <= 0) {
      return _normalizeUrl(rawAvatarUrl);
    }

    return '${ApiConstants.baseUrl}${ApiConstants.studentAvatarBase}/$studentId';
  }

  String? _normalizeUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    final cleanUrl = url.trim();

    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return cleanUrl;
    }

    if (cleanUrl.startsWith('/storage/')) {
      return '${ApiConstants.appUrl}$cleanUrl';
    }

    if (cleanUrl.startsWith('storage/')) {
      return '${ApiConstants.appUrl}/$cleanUrl';
    }

    if (cleanUrl.startsWith('/')) {
      return '${ApiConstants.appUrl}$cleanUrl';
    }

    return '${ApiConstants.appUrl}/storage/$cleanUrl';
  }

  String? _stripHtml(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .trim();
  }

  String? _firstString(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;

      final stringValue = value.toString().trim();

      if (stringValue.isNotEmpty && stringValue != 'null') {
        return stringValue;
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
      return value
          .map((item) => _asMap(item))
          .where((item) => item.isNotEmpty)
          .toList();
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
      final list = _asList(value);

      if (list.isNotEmpty) {
        return list;
      }
    }

    return [];
  }
}