// TODO Implement this library.
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static String get groqApiKey {
    final key = dotenv.env['GROQ_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GROQ_API_KEY not found in .env file');
    }
    return key;
  }
}