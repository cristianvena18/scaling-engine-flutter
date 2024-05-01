import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:uni_links/uni_links.dart';

import 'analytics.dart';
import 'deeplink.dart';
import 'error.dart';
import 'firebase.dart';
import 'http.dart';
import 'loading.dart';
import 'logger.dart';
import 'parser.dart';
import 'widget.dart';

/// Instance of FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Route observer to track route navigation so that we can reload screens when poped.
/// See DynamicRouteState.didPopNext().
/// IMPORTANT: This route observer must be added to the application
final RouteObserver<ModalRoute> sduiRouteObserver = RouteObserver<ModalRoute>();

/// Returns the content of a route
abstract class RouteContentProvider {
  Future<String> getContent();
}

/// Static implementation of RouteContentProvider with static content
class StaticRouteContentProvider implements RouteContentProvider {
  final String _json;

  const StaticRouteContentProvider(this._json);

  @override
  Future<String> getContent() {
    return Future(() => _json);
  }

  @override
  String toString() => "StaticRouteContentProvider";
}

/// Static implementation of RouteContentProvider with static content
class HttpRouteContentProvider implements RouteContentProvider {
  final String _url;
  final Map<String, dynamic>? data;

  const HttpRouteContentProvider(this._url, {this.data});

  @override
  Future<String> getContent() async => Http.getInstance().get(_url);

  @override
  String toString() => "StaticRouteContentProvider(url=$_url)";
}

/// Dynamic Route
class DynamicRoute extends StatefulWidget {
  final RouteContentProvider provider;
  final PageController? pageController;
  final bool handleFirebaseMessages;

  const DynamicRoute(
      {Key? key,
      this.pageController,
      required this.provider,
      this.handleFirebaseMessages = true})
      : super(key: key);

  @override
  DynamicRouteState createState() =>
      // ignore: no_logic_in_create_state
      DynamicRouteState(provider, pageController, handleFirebaseMessages);
}

class DynamicRouteState extends State<DynamicRoute> with RouteAware {
  static final Logger _logger = LoggerFactory.create('DynamicRouteState');
  static Map<int, String?> statusCodeRoutes = {};
  static final List<String> _history = [];
  static bool _initialURIHandled = false;
  static bool _firebaseMessagingInitialized = false;

  RouteContentProvider provider;
  final PageController? pageController;
  late Future<String> content;
  SDUIWidget? sduiWidget;
  StreamSubscription? _streamSubscription;
  bool handleFirebaseMessages;

  DynamicRouteState(
      this.provider, this.pageController, this.handleFirebaseMessages);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      sduiRouteObserver.subscribe(this, ModalRoute.of(context)!);
    });

    content = provider.getContent();

    // UniLink
    try {
      _handleFirstUriLink();
      _initializeUriLink();
    } catch (e) {
      _logger.w('Unable to initialize firebase', e);
    }

    // Firebase
    try {
      _initializeFirebase();
    } catch (e) {
      _logger.w('Unable to initialize firebase', e);
    }

    super.initState();
  }

  @override
  void dispose() {
    sduiRouteObserver.unsubscribe(this);
    _streamSubscription?.cancel();

    super.dispose();
  }

  ///
  /// Deeplink
  ///
  void _handleFirstUriLink() async {
    // Already handled
    if (_initialURIHandled) return;

    // Initial URL
    try {
      Uri? initialURI = await getInitialUri();
      _logger.i("initial: deep_link=$initialURI");

      if (initialURI != null) {
        String? url = sduiDeeplinkHandler(initialURI);
        _logger.i("deep_link=$initialURI url=$url");
        if (url != null) {
          _initialURIHandled =
              true; // Make sure we handle the initial URL only ONCE!

          setState(() {
            provider = HttpRouteContentProvider(url);
            content = provider.getContent();
          });
        }
      }
    } catch (ex) {
      _logger.w("Failed to receive initial uri", ex);
    }
  }

  void _initializeUriLink() async {
    _streamSubscription = uriLinkStream.listen((Uri? uri) {
      _logger.i("received: deep_link=$uri");
      if (uri != null) {
        String? url = sduiDeeplinkHandler(uri);
        _logger.i("deep_link=$uri -> $url");

        if (url != null) {
          setState(() {
            provider = HttpRouteContentProvider(url);
            content = provider.getContent();
          });
        }
      }
    }, onError: (Object err) {
      _logger.w('Deeplink error', err);
    });
  }

  ///
  /// Firebase Messaging
  ///
  void _initializeFirebase() async {
    if (_firebaseMessagingInitialized || !handleFirebaseMessages) return;

    // Initialize local notifications
    _localNotificationsPlugin.initialize(
        InitializationSettings(
          android: AndroidInitializationSettings(sduiFirebaseIconAndroid),
          iOS: const DarwinInitializationSettings(),
        ),
        onDidReceiveBackgroundNotificationResponse: (response) =>
            _onNotificationSelected(response));

    // Get permission
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    _logger.i('Notification permission=${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Background messages
      _logger.i('Listening to Firebase background messages');
      FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
        _logger.i('onBackgroundMessage: ${message.messageId}');
        _onFirebaseMessage(message, true);
      });

      // Foreground messages
      _logger.i('Listening to Firebase foreground messages');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('onMessage: ${message.messageId}');
        sduiFirebaseMessageHandler(message);
      });

      // Token
      FirebaseMessaging.instance.getToken().then((token) {
        _logger.i('Token: $token');
        sduiFirebaseTokenHandler(token);
      });
    } else {
      _logger.i('User declined or has not accepted permission');
    }
    _firebaseMessagingInitialized = true;
  }

  Future<void> _onFirebaseMessage(
      RemoteMessage message, bool background) async {
    _logger.i(
        '_onFirebaseMessage id=${message.messageId} data=${message.data} background=$background');

    if (background) {
      await Firebase.initializeApp();
    }

    // Show notification
    await _localNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              'wutsi_channel',
              'wutsi_channel',
              priority: Priority.max,
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
              icon: sduiFirebaseIconAndroid,
            ),
            iOS: const DarwinNotificationDetails(
                presentAlert: true, presentBadge: true, presentSound: true)),
        payload: jsonEncode(message.data));
  }

  Future<void> _onNotificationSelected(NotificationResponse response) async {
    _logger.i('_onNotificationSelected payload=${response.payload}');
    if (response.payload != null) return;

    var data = jsonDecode(response.payload!);
    if (data is Map<String, dynamic>) {
      _onNotificationData(data);
    }
  }

  void _onNotificationData(Map<String, dynamic> data) {
    String? url = data['url'];
    if (url != null) {
      String? xurl = sduiDeeplinkHandler(Uri.parse(url));
      _logger.i("deep_link: $url -> $xurl");

      if (xurl != null) {
        Future(() => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DynamicRoute(provider: HttpRouteContentProvider(xurl))),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Center(
      child: FutureBuilder<String>(
          future: content,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              sduiWidget =
                  SDUIParser.getInstance().fromJson(jsonDecode(snapshot.data!));
              String? id = sduiWidget!.id;
              sduiWidget!.attachPageController(pageController);
              _push(id);
              return sduiWidget!.toWidget(context);
            } else if (snapshot.hasError) {
              // Log
              var error = snapshot.error;
              if (error is ClientException) {
                int? statusCode = int.tryParse(error.message);
                if (statusCode != null) {
                  String? route = statusCodeRoutes[statusCode];
                  if (route != null) {
                    _logger.e('status=$statusCode route=$route', error,
                        snapshot.stackTrace);
                    Navigator.pushReplacementNamed(context, route);
                  }
                }
              }

              // Error State
              _logger.e('provider=$provider', error, snapshot.stackTrace);
              return sduiErrorState(context, error);
            }

            // Loading state
            return sduiLoadingState(context);
          }));

  void _reload() {
    content = provider.getContent();
  }

  void _push(String? pageId) {
    if (pageId != null && pageId != _peek()) {
      _history.add(pageId);
      _notifyAnalytics();
    }
    _logger.i('...push($pageId) - history=$_history');
  }

  void _pop() {
    if (_history.isNotEmpty) {
      _history.removeAt(_history.length - 1);
      _logger.i('...pop() - history=$_history');

      _notifyAnalytics();
    }
  }

  String? _peek() => _history.isEmpty ? null : _history.last;

  @override
  void didPush() {
    _logger.i('didPush() - widget.id=${sduiWidget?.id} - peek=${_peek()}');
    super.didPush();

    _notifyAnalytics();
  }

  @override
  void didPushNext() {
    _logger.i('didPushNext() - widget.id=${sduiWidget?.id} - peek=${_peek()}');
    super.didPush();

    // _push(sduiWidget?.id);
  }

  @override
  void didPop() {
    _logger.i('didPop() - widget.id=${sduiWidget?.id} - peek=${_peek()}');
    super.didPop();
  }

  @override
  void didPopNext() {
    _logger.i('didPopNext() - widget.id=${sduiWidget?.id} - peek=${_peek()}');
    super.didPopNext();

    if (_history.isEmpty || _peek() != sduiWidget?.id) {
      _logger.i('... Reloading the page');
      _pop();

      // Force refresh of the page
      setState(() {
        _reload();
      });
    }
  }

  void _notifyAnalytics() {
    try {
      String? id = sduiWidget?.id;
      if (id != null) {
        sduiAnalytics.onRoute(id);
      }
    } catch (e) {
      _logger.w("Unable to push event to Analytics", e);
    }
  }
}
