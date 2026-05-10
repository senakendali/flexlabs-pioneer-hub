class ApiConstants {
  /*
  |--------------------------------------------------------------------------
  | Base URL
  |--------------------------------------------------------------------------
  |
  | Untuk Flutter Web / Chrome local development:
  | http://127.0.0.1:8007
  |
  | Kalau nanti jalan di Android Emulator, ganti appUrl jadi:
  | http://10.0.2.2:8007
  |
  | Kalau nanti jalan di HP fisik, pakai IP laptop, contoh:
  | http://192.168.1.10:8007
  |
  */

  static const String appUrl = 'http://127.0.0.1:8007';
  static const String baseUrl = '$appUrl/api';

  /*
  |--------------------------------------------------------------------------
  | Auth
  |--------------------------------------------------------------------------
  */

  static const String login = '/lms/student/login';
  static const String me = '/lms/student/me';
  static const String logout = '/lms/student/logout';

  /*
  |--------------------------------------------------------------------------
  | Student Profile
  |--------------------------------------------------------------------------
  */

  static const String profile = '/lms/student/profile';

  /*
  |--------------------------------------------------------------------------
  | Student Avatar Proxy
  |--------------------------------------------------------------------------
  |
  | Dipakai oleh HomeService:
  | ${ApiConstants.baseUrl}${ApiConstants.studentAvatarBase}/$studentId
  |
  | Hasil:
  | http://127.0.0.1:8007/api/lms/student/avatar/5
  |
  */

  static const String studentAvatarBase = '/lms/student/avatar';

  // Alias lama, biar kalau ada file lain masih pakai studentAvatar tidak error.
  static const String studentAvatar = studentAvatarBase;

  /*
  |--------------------------------------------------------------------------
  | Notes & Academic Documents
  |--------------------------------------------------------------------------
  */

  static const String notes = '/lms/student/notes';
  static const String academicDocuments = '/lms/student/academic-documents';

  /*
  |--------------------------------------------------------------------------
  | Community / Pioneer Hub
  |--------------------------------------------------------------------------
  */

  static const String communityHome = '/lms/student/community/home';
  static const String communityChannels = '/lms/student/community/channels';

  static String channelPosts(int channelId) {
    return '/lms/student/community/channels/$channelId/posts';
  }

  static String postDetail(int postId) {
    return '/lms/student/community/posts/$postId';
  }

  static String postComments(int postId) {
    return '/lms/student/community/posts/$postId/comments';
  }

  static String solvePost(int postId) {
    return '/lms/student/community/posts/$postId/solve';
  }

  /*
  |--------------------------------------------------------------------------
  | Mentoring / 1-on-1 Booking
  |--------------------------------------------------------------------------
  */

  static const String mentoringInstructors =
      '/lms/student/mentoring/instructors';

  static const String mentoringSlots = '/lms/student/mentoring/slots';

  static const String mentoringBook = '/lms/student/mentoring/book';
}