import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:unityspace/models/auth_models.dart';
import 'package:unityspace/plugins/http_plugin.dart';
import 'package:unityspace/plugins/store.dart';
import 'package:unityspace/service/auth_service.dart' as api;
import 'package:unityspace/store/user_store.dart';

class AuthStore extends GStore {
  static AuthStore? _instance;

  factory AuthStore() => _instance ??= AuthStore._();

  AuthStore._();

  AuthTokens _currentTokens = const AuthTokens('', '');
  Completer<bool> _refreshUserTokenCompleteEvent = Completer<bool>()
    ..complete(true);

  bool get isAuthenticated => _currentTokens.accessToken.isNotEmpty;

  AuthTokens getUserTokens() {
    return _currentTokens;
  }

  Stream<bool> get observeIsAuthenticated =>
      observe(() => _currentTokens.accessToken.isNotEmpty);

  Future<void> removeUserTokens() async {
    // удалить из локал стореджа
    final sp = await SharedPreferences.getInstance();
    await sp.remove('access_token');
    await sp.remove('refresh_token');
    //
    setStore(() {
      _currentTokens = const AuthTokens('', '');
    });
    // установить заголовки
    _updateHttpAuthorizationHeader('');
  }

  Future<void> setUserTokens(
    final String userToken,
    final String refreshToken,
  ) async {
    if (userToken.isEmpty || refreshToken.isEmpty) return removeUserTokens();

    // сохранить в локалсторедж
    final sp = await SharedPreferences.getInstance();
    await sp.setString('access_token', userToken);
    await sp.setString('refresh_token', refreshToken);

    //
    setStore(() {
      _currentTokens = AuthTokens(userToken, refreshToken);
    });

    // установить заголовки
    _updateHttpAuthorizationHeader(userToken);
  }

  Future<void> loadUserTokens() async {
    final sp = await SharedPreferences.getInstance();
    final userToken = sp.getString('access_token') ?? '';
    final refreshToken = sp.getString('refresh_token') ?? '';
    setStore(() {
      _currentTokens = AuthTokens(userToken, refreshToken);
    });
    _updateHttpAuthorizationHeader(userToken);
  }

  Future<bool> refreshUserToken() async {
    if (_refreshUserTokenCompleteEvent.isCompleted == false) {
      return await _refreshUserTokenCompleteEvent.future;
    }
    _refreshUserTokenCompleteEvent = Completer<bool>();
    final refreshToken = getUserTokens().refreshToken;
    if (refreshToken.isEmpty) {
      _refreshUserTokenCompleteEvent.complete(false);
      return false;
    }
    try {
      final tokens = await api.refreshAccessToken(refreshToken: refreshToken);
      await setUserTokens(tokens.accessToken, tokens.refreshToken);
      _refreshUserTokenCompleteEvent.complete(true);
      return true;
    } catch (_, __) {
      _refreshUserTokenCompleteEvent.complete(false);
      return false;
    }
  }

  Future<void> login(final String email, final String password) async {
    final tokens = await api.login(email: email, password: password);
    await setUserTokens(tokens.accessToken, tokens.refreshToken);
  }

  Future<void> restorePasswordByEmail(final String email) async {
    await api.restorePasswordByEmail(email: email);
  }

  Future<void> signOut() async {
    final refreshToken = getUserTokens().refreshToken;
    final globalUserId = UserStore().user?.globalId;
    if (refreshToken.isNotEmpty && globalUserId != null) {
      await api.signOut(
        refreshToken: refreshToken,
        globalUserId: globalUserId,
      );
    }
    await removeUserTokens();
  }

  void _updateHttpAuthorizationHeader(final String token) {
    if (token.isEmpty) {
      HttpPlugin().setAuthorizationHeader('');
    } else {
      HttpPlugin().setAuthorizationHeader('Bearer $token');
    }
  }
}
