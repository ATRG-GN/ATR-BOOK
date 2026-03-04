/// เก็บ JWT ไว้ใน memory เท่านั้นเพื่อลดความเสี่ยงบน Web
class JwtSessionStore {
  String? _jwt;

  String? get token => _jwt;

  bool get isAuthenticated => _jwt != null && _jwt!.isNotEmpty;

  void setToken(String jwt) {
    _jwt = jwt;
  }

  void clear() {
    _jwt = null;
  }
}
