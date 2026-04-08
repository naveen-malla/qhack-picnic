import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;

/// Automatic Google Calendar → `/api/extract` pipeline (5-day window, preferred account).
class CalendarSyncService {
  CalendarSyncService._();
  static final CalendarSyncService instance = CalendarSyncService._();

  /// Account the app expects for calendar access (OAuth still requires user consent once).
  static const preferredGoogleEmail = 'sayansinha2019@gmail.com';

  static const _calendarScope = 'https://www.googleapis.com/auth/calendar.readonly';
  static const autoSyncInterval = Duration(minutes: 1);
  static const horizonDays = 5;

  /// Don’t hammer the API when switching tabs.
  static const minIntervalBetweenTabSyncs = Duration(seconds: 20);

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: const [_calendarScope],
  );

  String apiBase = 'http://127.0.0.1:5001';
  String apiKey = 'dev-token';
  void Function(Map<String, dynamic> extracted)? onSuggestionsReady;
  void Function()? onNavigateToEntdecken;
  void Function(String message)? onStatusMessage;

  Timer? _timer;
  bool _busy = false;

  /// If [syncNow] was called while a run was in progress (e.g. back from Calendar app), run again.
  bool _syncQueued = false;

  DateTime? _lastTabSyncRequestAt;

  /// Background auto-sync only tries the interactive Google UI once per app launch (avoids prompts every 5 min).
  bool _autoInteractiveAttemptedThisSession = false;

  /// Last successful combined calendar text (for debugging / future UI).
  String lastCombinedPreview = '';

  void configure({
    required String apiBase,
    required String apiKey,
    void Function(Map<String, dynamic> extracted)? onSuggestionsReady,
    void Function()? onNavigateToEntdecken,
    void Function(String message)? onStatusMessage,
  }) {
    this.apiBase = apiBase;
    this.apiKey = apiKey;
    this.onSuggestionsReady = onSuggestionsReady;
    this.onNavigateToEntdecken = onNavigateToEntdecken;
    this.onStatusMessage = onStatusMessage;
  }

  /// Starts periodic sync + runs one sync soon after start.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(autoSyncInterval, (_) {
      syncNow(navigateToDiscover: false, forceInteractive: false, quiet: true);
    });
    scheduleMicrotask(() {
      syncNow(navigateToDiscover: false, forceInteractive: false, quiet: true);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void onAppResumed() {
    syncNow(navigateToDiscover: false, forceInteractive: false, quiet: true);
  }

  /// Call when user opens the Entdecken tab — picks up calendar edits without waiting for the timer.
  void onEntdeckenTabSelected() {
    final now = DateTime.now();
    if (_lastTabSyncRequestAt != null &&
        now.difference(_lastTabSyncRequestAt!) < minIntervalBetweenTabSyncs) {
      return;
    }
    _lastTabSyncRequestAt = now;
    syncNow(navigateToDiscover: false, forceInteractive: false, quiet: true);
  }

  /// Resets session flag so the next cold start can prompt again (optional).
  void resetSessionSignInFlag() {
    _autoInteractiveAttemptedThisSession = false;
  }

  bool _emailMatches(GoogleSignInAccount account) {
    return account.email.toLowerCase().trim() ==
        preferredGoogleEmail.toLowerCase();
  }

  Future<GoogleSignInAccount?> _interactivePreferred() async {
    final account = await googleSignIn.signIn();
    if (account == null) return null;
    if (_emailMatches(account)) return account;
    await googleSignIn.signOut();
    onStatusMessage?.call(
      'Bitte mit $preferredGoogleEmail anmelden (anderes Konto abgemeldet).',
    );
    return null;
  }

  Uri _extractUri() => Uri.parse('$apiBase/api/extract')
      .replace(queryParameters: {'api_key': apiKey});

  Future<void> _postExtract(String text) async {
    final resp = await http.post(
      _extractUri(),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    if (resp.statusCode != 200) {
      onStatusMessage?.call('Server: ${resp.statusCode}');
      return;
    }
    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    onSuggestionsReady?.call(map);
  }

  Future<GoogleSignInAccount?> _ensurePreferredAccount({
    required bool forceInteractive,
  }) async {
    Future<GoogleSignInAccount?> trySilent() async {
      final account = await googleSignIn.signInSilently(suppressErrors: true);
      if (account == null) return null;
      if (_emailMatches(account)) return account;
      await googleSignIn.signOut();
      onStatusMessage?.call(
        'Nur $preferredGoogleEmail ist für den Kalender vorgesehen.',
      );
      return null;
    }

    if (forceInteractive) {
      final silentOk = await trySilent();
      if (silentOk != null) return silentOk;
      return _interactivePreferred();
    }

    final silentOk = await trySilent();
    if (silentOk != null) return silentOk;

    if (!_autoInteractiveAttemptedThisSession) {
      _autoInteractiveAttemptedThisSession = true;
      return _interactivePreferred();
    }
    return null;
  }

  String _eventText(gcal.Event e) {
    final summary = (e.summary ?? '').trim();
    final title = summary.isEmpty ? 'Ohne Titel' : summary;
    final desc = (e.description ?? '').trim();
    final loc = (e.location ?? '').trim();
    final when = _formatEventWhen(e);
    final parts = <String>[title];
    if (when != null) parts.add(when);
    if (desc.isNotEmpty) parts.add(desc);
    if (loc.isNotEmpty) parts.add(loc);
    // So edits / “recreate” change the payload and extraction can update suggestions.
    final u = e.updated;
    if (u != null) {
      parts.add('Zuletzt geändert: ${u.toUtc().toIso8601String()}');
    }
    return parts.join('\n');
  }

  String? _formatEventWhen(gcal.Event e) {
    final s = e.start;
    if (s == null) return null;
    if (s.dateTime != null) {
      final local = s.dateTime!.toLocal();
      return 'Wann: ${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
          '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    if (s.date != null) {
      return 'Ganztägig: ${s.date}';
    }
    return null;
  }

  Future<String> _fetchCalendarText(GoogleSignInAccount account) async {
    final auth = await account.authentication;
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      onStatusMessage?.call('Kein Zugriffstoken — bitte erneut anmelden.');
      return '';
    }

    final bearer = _AuthBearerClient(token);
    late final gcal.Events eventsResp;
    try {
      final api = gcal.CalendarApi(bearer);
      final now = DateTime.now().toUtc();
      final start = now.subtract(const Duration(hours: 24));
      final end = now.add(Duration(days: horizonDays));

      eventsResp = await api.events.list(
        'primary',
        timeMin: start,
        timeMax: end,
        maxResults: 80,
        singleEvents: true,
        orderBy: 'startTime',
      );
    } finally {
      bearer.close();
    }

    final buf = StringBuffer();
    for (final e in eventsResp.items ?? const <gcal.Event>[]) {
      final block = _eventText(e);
      if (block.isEmpty) continue;
      if (buf.isNotEmpty) buf.writeln('\n---\n');
      buf.writeln(block);
    }
    return buf.toString().trim();
  }

  /// Fetches calendar and posts to backend.
  /// [navigateToDiscover]: when true, switches to Entdecken after success (manual flow).
  /// [forceInteractive]: user tapped sync — prefer silent, then account picker.
  /// [quiet]: when true (background), no snackbar for „empty calendar“.
  Future<String?> syncNow({
    bool navigateToDiscover = true,
    bool forceInteractive = false,
    bool quiet = false,
  }) async {
    if (_busy) {
      _syncQueued = true;
      return null;
    }
    _busy = true;
    try {
      final account = await _ensurePreferredAccount(forceInteractive: forceInteractive);
      if (account == null) return null;

      final combined = await _fetchCalendarText(account);
      lastCombinedPreview = combined;
      if (combined.isEmpty) {
        if (!quiet) {
          onStatusMessage?.call(
            'Keine Termine im Fenster (ca. 24h zurück bis +$horizonDays Tage) auf dem Hauptkalender.',
          );
        }
        return null;
      }

      await _postExtract(combined);
      if (navigateToDiscover) {
        onNavigateToEntdecken?.call();
      }
      return combined;
    } catch (e) {
      if (!quiet) {
        onStatusMessage?.call('$e');
      }
      return null;
    } finally {
      _busy = false;
      if (_syncQueued) {
        _syncQueued = false;
        scheduleMicrotask(() => syncNow(
              navigateToDiscover: false,
              forceInteractive: false,
              quiet: true,
            ));
      }
    }
  }
}

class _AuthBearerClient extends http.BaseClient {
  _AuthBearerClient(this._token);
  final String _token;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}
