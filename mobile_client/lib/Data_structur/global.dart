library my_project.globals;

class GlobalVariables {
  static String _apiUrl = 'http://localhost:3000';

  static String get apiUrl => _apiUrl;

  static void set apiUrl(String value) {
    _apiUrl = value;
  }
}