class ApiConfig {
    static const String ngrokUrl = 'https://122f-41-139-172-215.ngrok-free.app';
  
  // Your Firebase project ID
  static const String projectId = 'demprojo';
  
  // API Base URL
  static String get baseUrl => '$ngrokUrl/$projectId/us-central1/api';
  
  // Individual endpoints
  static String get health => '$baseUrl/health';
  static String get testConfig => '$baseUrl/test-config';
  static String get testMpesaAuth => '$baseUrl/test-mpesa-auth';
  static String get initiateStkPush => '$baseUrl/initiate-stk-push';
  static String get checkPayment => '$baseUrl/check-payment';
  static String get mpesaCallback => '$baseUrl/mpesa-callback';
  
  static const bool useNgrok = true;
  
  static String get activeUrl {
    if (useNgrok) {
      return baseUrl;
    } else {
      return 'https://us-central1-$projectId.cloudfunctions.net/api';
    }
  }
}