import 'package:flutter/material.dart';
import 'l10n.dart';

typedef LoadingStateBuilder = Widget Function(BuildContext context);

/// Loading widget
// ignore: prefer_function_declarations_over_variables
LoadingStateBuilder sduiProgressIndicator =
    (context) => const CircularProgressIndicator();

/// Loading state
/// This is the page displayed when the app move to loading state.
// ignore: prefer_function_declarations_over_variables
LoadingStateBuilder sduiLoadingState = (context) => Scaffold(
    appBar: AppBar(
      title: Text(sduiL10.loading,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blueAccent)),
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0.0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.blueAccent,
    ),
    body: Center(child: sduiProgressIndicator(context)));
