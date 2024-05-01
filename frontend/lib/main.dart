import 'package:flutter/material.dart';
import 'sdui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkout from server driven ui',
      initialRoute: '/',
      routes: _routes(),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [sduiRouteObserver],
    );
  }

  Map<String, WidgetBuilder> _routes() => {
    '/': (context) => const DynamicRoute(provider: HttpRouteContentProvider('http://10.0.2.2:3333/api/checkout'))
  };
}
