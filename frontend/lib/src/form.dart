import 'package:flutter/material.dart';

import 'widget.dart';

/// Descriptor of [Form]
class SDUIForm extends SDUIWidget {
  @override
  Widget toWidget(BuildContext context) => _FormWidgetStateful(this);

  @override
  SDUIWidget fromJson(Map<String, dynamic>? json) {
    super.fromJson(json);
    return this;
  }
}

/// Interface for managing the state of a form.
abstract class SDUIFormDataProvider {
  Map<String, String> getData();

  void setData(String name, String value);
}

/// Interface for attaching a form with its fields
abstract class SDUIFormField {
  GlobalKey<FormState>? formKey;
  SDUIFormDataProvider? provider;

  void attachForm(GlobalKey<FormState> formKey, SDUIFormDataProvider provider) {
    this.formKey = formKey;
    this.provider = provider;
  }
}

class _FormWidgetStateful extends StatefulWidget {
  final SDUIForm delegate;

  const _FormWidgetStateful(this.delegate, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _FormWidgetState(delegate);
}

class _FormWidgetState extends State<_FormWidgetStateful>
    implements SDUIFormDataProvider {
  SDUIForm delegate;
  Map<String, String> data = <String, String>{};
  final key = GlobalKey<FormState>();

  _FormWidgetState(this.delegate);

  @override
  Map<String, String> getData() => data;

  @override
  void setData(String name, String value) {
    data[name] = value;
  }

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < delegate.children.length; i++) {
      _attachForm(delegate.children[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: key, child: Column(children: delegate.childrenWidgets(context)));
  }

  void _attachForm(SDUIWidget child) {
    if (child is SDUIFormField) {
      (child as SDUIFormField).attachForm(key, this);
    } else {
      for (int i = 0; i < child.children.length; i++) {
        _attachForm(child.children[i]);
      }
    }
  }
}
