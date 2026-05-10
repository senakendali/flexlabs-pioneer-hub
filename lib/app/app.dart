import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/data/auth_service.dart';
import '../features/splash/presentation/splash_page.dart';

class PioneerHubApp extends StatefulWidget {
  const PioneerHubApp({super.key});

  @override
  State<PioneerHubApp> createState() => _PioneerHubAppState();
}

class _PioneerHubAppState extends State<PioneerHubApp> {
  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final AuthService authService;

  @override
  void initState() {
    super.initState();

    tokenStorage = TokenStorage();

    apiClient = ApiClient(
      tokenStorage: tokenStorage,
    );

    authService = AuthService(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pioneer Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: SplashPage(
        authService: authService,
      ),
    );
  }
}