import 'package:flutter/material.dart';

import 'form.dart';
import 'widget.dart';

/// Descriptor of a [RadioListTile]
class SDUIRadio extends SDUIWidget {
  String? caption;
  String? subCaption;
  String? value;
  String? groupValue;

  @override
  Widget toWidget(BuildContext context) => RadioListTile<String>(
        key: id == null ? null : Key(id!),
        title: Text(caption ?? '<NO-TITLE>'),
        subtitle: subCaption == null ? null : Text(subCaption ?? ''),
        value: value ?? '',
        groupValue: groupValue,
        onChanged: (v) {},
      );

  @override
  SDUIWidget fromJson(Map<String, dynamic>? json) {
    super.fromJson(json);
    caption = json?["caption"];
    subCaption = json?["subCaption"];
    value = json?["value"];
    return super.fromJson(json);
  }
}

/// Descriptor of a radio group
class SDUIRadioGroup extends SDUIWidget with SDUIFormField {
  String name = '<no-name>';
  String? value;
  bool? separator;
  String? separatorColor;

  @override
  Widget toWidget(BuildContext context) => _RadioGroupWidget(this);

  @override
  SDUIWidget fromJson(Map<String, dynamic>? json) {
    super.fromJson(json);
    name = json?["name"] ?? '<no-name>';
    value = json?["value"];
    separator = json?["separator"];
    separatorColor = json?["separatorColor"];
    return super.fromJson(json);
  }
}

class _RadioGroupWidget extends StatefulWidget {
  final SDUIRadioGroup delegate;

  const _RadioGroupWidget(this.delegate);

  @override
  // ignore: no_logic_in_create_state
  _RadioGroupState createState() => _RadioGroupState(delegate);
}

class _RadioGroupState extends State<_RadioGroupWidget> {
  String state = '';
  SDUIRadioGroup delegate;

  _RadioGroupState(this.delegate);

  @override
  void initState() {
    super.initState();
    state = delegate.value ?? '';
    delegate.provider?.setData(delegate.name, state.toString());
  }

  @override
  Widget build(BuildContext context) => ListView(
      key: delegate.id == null ? null : Key(delegate.id!),
      children: delegate.children.map((e) {
        if (e is SDUIRadio) {
          return _toListItem(RadioListTile<String>(
              title: Text(e.caption ?? '<NO-TITLE>'),
              subtitle: e.subCaption == null ? null : Text(e.subCaption ?? ''),
              value: e.value ?? '',
              groupValue: state,
              onChanged: (String? v) => _onChange(context, v)));
        } else {
          return _toListItem(e.toWidget(context));
        }
      }).toList());

  Widget _toListItem(Widget item) {
    if (delegate.separator == true) {
      return Column(
        children: [
          item,
          Divider(
            height: 1,
            color: delegate.toColor(delegate.separatorColor),
          )
        ],
      );
    } else {
      return item;
    }
  }

  void _onChange(BuildContext context, String? value) {
    var val = value ?? '';

    setState(() {
      state = val;
    });

    var data = <String, String>{};
    data[(delegate.name)] = val;
    delegate.action
        .execute(context, data)
        .then((value) => delegate.action.handleResult(context, value));
    delegate.provider?.setData(delegate.name, state.toString());
  }
}
