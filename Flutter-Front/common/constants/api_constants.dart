import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._(); // 인스턴스 생성 방지

  // ── 스프링부트 / 플라스크 (기존 유지) ───────────────────
  // ✅ .env 에서 실제 값을 가져옴
  // static String get springBaseUrl  => dotenv.env['SPRING_BASE_URL']  ?? '';
  // static String get springBaseUrl2 => dotenv.env['SPRING_BASE_URL2'] ?? '';
  // static String get flaskBaseUrl   => dotenv.env['FLASK_BASE_URL']   ?? '';
  
  // 팀규칙으로 변경
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

}