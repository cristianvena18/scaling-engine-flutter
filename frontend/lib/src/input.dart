import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'l10n.dart';

import 'button.dart';
import 'countries.dart';
import 'form.dart';
import 'http.dart';
import 'logger.dart';
import 'widget.dart';

/// Descriptor of a form Input
///
/// ### JSON Attributes
/// - **name**: REQUIRED. This should be the name of the input field
/// - **type**: Type of input field. The possible values are:
///    - `text`: Free text (Default)
///    - `url`
///    - `email`
///    - `number`
///    - `phone`: Phone number
///    - `date`: Date
///    - `time`: Time
///    - `image`
///    - `video`
///    - 'file'
/// - **value**: Default value.
///    - When `type=date`, the format should be `yyyy-MM-dd` (Ex: 2020-07-30)
///    - When `type=time`, the format should be `HH:mm` (Ex: 23:30)
///    - When `type=phone`, the format should be in E.164 format (Ex: +442087712924)
/// - **hideText**: if `true`, the input text will be hide. (Default: `false`)
/// - **caption**: Title of the input
/// - **hint**: Help test for users
/// - **required**: if `true`, validation will be fired to ensure that the field has a value
/// - **readOnly**: if `true`, the field will not be editable (Default: `false`)
/// - **maxLength**: Maximum length of the field
/// - **maxLine**: Maximum number of line  (for multi-line input)
/// - **minLength**: Minimum length of the field (Default: 0)
/// - **initialCountry**: Initial country - for `type=phone`
/// - **countries**: List of country codes - for `type=phone`
/// - **uploadUrl**: URL where to upload the file. For `type=image` or `type=video`
/// - **imageSource**: From where to get the image or video. For `type=image` or `type=video`. The possible values
///   - `camera`: Default
///   - `gallery`
/// - **imageMaxWidth**: Image max width
/// - **imageMaxHeight**: Image max width
/// - **videoMaxDuration**: Video max width in seconds
/// - **prefix**: Prefix in the input field
/// - **suffix**: Suffix in the input field
/// - *action***: [SDUIAction] to execute when the input is clicked
class SDUIInput extends SDUIWidget with SDUIFormField {
  String name = '_no_name_';
  String? value;
  bool hideText = false;
  bool required = false;
  String? caption;
  String? hint;
  bool enabled = true;
  bool readOnly = false;
  String type = "text";
  int? maxLines;
  int? maxLength;
  int minLength = 0;
  List<String>? countries;
  String? uploadUrl;
  String? imageSource;
  int? imageMaxWidth;
  int? imageMaxHeight;
  int? videoMaxDuration;
  String? prefix;
  String? suffix;
  String? initialCountry;
  String? inputFormatterRegex;

  @override
  Widget toWidget(BuildContext context) => _createWidget(context);

  @override
  SDUIWidget fromJson(Map<String, dynamic>? json) {
    name = json?["name"] ?? '_no_name_';
    value = json?["value"];
    hideText = json?["hideText"] ?? false;
    required = json?["required"] ?? false;
    caption = json?["caption"];
    hint = json?["hint"];
    enabled = json?["enabled"] ?? true;
    readOnly = json?["readOnly"] ?? false;
    type = (json?["type"] ?? "text").toString().toLowerCase();
    maxLines = json?["maxLines"];
    maxLength = json?["maxLength"];
    minLength = json?["minLength"] ?? 0;
    uploadUrl = json?["uploadUrl"];
    imageSource = json?["imageSource"];
    imageMaxWidth = json?["imageMaxWidth"];
    imageMaxHeight = json?["imageMaxHeight"];
    videoMaxDuration = json?["videoMaxDuration"];
    prefix = json?["prefix"];
    suffix = json?["suffix"];
    initialCountry = json?["initialCountry"];
    inputFormatterRegex = json?["inputFormatterRegex"];

    var nodes = json?["countries"];
    if (nodes is List<dynamic>) {
      countries = nodes.map((e) => e.toString()).toList();
    }
    return super.fromJson(json);
  }

  Widget _createWidget(BuildContext context) {
    switch (type.toLowerCase()) {
      case 'submit':
        return _SubmitWidgetStateful(this);

      case 'date':
      case 'time':
        return _DateTimeWidgetStateful(this);

      case 'phone':
        return _PhoneWidgetStateful(this);

      case 'image':
      case 'video':
        return _ImageWidgetStateful(this);

      case 'file':
        return _FileWidgetStateful(this);

      default:
        return _TextFieldWidgetStateful(this);
    }
  }

  String? _onValidate(String? value) {
    String trimmed = value?.trim() ?? '';
    bool empty = (value == null || trimmed.isEmpty);
    if (empty) {
      if (required) {
        return sduiL10.validationMissingField;
      }
    }
    if (!empty) {
      if (type == 'email' && !EmailValidator.validate(value)) {
        return sduiL10.validationMalformedEmail;
      }
      if (type == 'url') {
        try {
          if (!Uri.parse(value).isAbsolute) {
            return sduiL10.validationMalformedURL;
          }
        } catch (e) {
          return sduiL10.validationMalformedURL;
        }
      }
      if (type == 'number') {
        if (double.tryParse(value) == null) {
          return sduiL10.validationInvalidNumber;
        }
      }
    }
    return null;
  }

  Future<String?> _onSubmit(BuildContext context) async {
    return formKey?.currentState?.validate() == false
        ? null
        : await action.execute(context, provider?.getData());
  }
}

/// Text
class _TextFieldWidgetStateful extends StatefulWidget {
  final SDUIInput delegate;

  const _TextFieldWidgetStateful(this.delegate, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _TextFieldWidgetState(delegate);
}

class _TextFieldWidgetState extends State<_TextFieldWidgetStateful> {
  SDUIInput delegate;
  String state = '';

  _TextFieldWidgetState(this.delegate);

  @override
  void initState() {
    super.initState();
    state = delegate.value ?? '';
    delegate.provider?.setData(delegate.name, state);
  }

  @override
  Widget build(BuildContext context) => TextFormField(
      key: delegate.id == null ? null : Key(delegate.id!),
      enabled: delegate.enabled,
      decoration: _toInputDecoration(),
      controller: TextEditingController(text: state),
      obscureText: delegate.hideText,
      readOnly: delegate.readOnly,
      maxLength: delegate.maxLength,
      maxLines: delegate.maxLines,
      keyboardType: _toKeyboardType(),
      onChanged: (String value) => _onChanged(value),
      validator: (String? value) => _onValidate(value),
      textCapitalization: delegate.type == 'text'
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      inputFormatters: delegate.inputFormatterRegex == null
          ? null
          : <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                  RegExp(delegate.inputFormatterRegex!))
            ]);

  TextInputType? _toKeyboardType() {
    switch (delegate.type.toLowerCase()) {
      case 'email':
        return TextInputType.emailAddress;

      case 'number':
        return TextInputType.number;

      case 'url':
        return TextInputType.url;

      case 'date':
      case 'time':
        return TextInputType.datetime;

      case 'phone':
        return TextInputType.phone;
    }

    return delegate.maxLines == null || delegate.maxLines! == 1
        ? TextInputType.text
        : TextInputType.multiline;
  }

  InputDecoration? _toInputDecoration() => InputDecoration(
        hintText: delegate.hint,
        label: delegate.caption == null ? null : Text(delegate.caption!),
        prefix: delegate.prefix == null ? null : Text(delegate.prefix!),
        suffix: delegate.suffix == null ? null : Text(delegate.suffix!),
      );

  String? _onValidate(String? value) => delegate._onValidate(value);

  void _onChanged(String value) {
    delegate.provider?.setData(delegate.name, value.trim());
  }
}

/// Submit
class _SubmitWidgetStateful extends StatefulWidget {
  final SDUIInput delegate;

  const _SubmitWidgetStateful(this.delegate, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _SubmitWidgetState(delegate);
}

class _SubmitWidgetState extends State<_SubmitWidgetStateful> {
  bool busy = false;
  SDUIInput delegate;
  SDUIButton button = SDUIButton();

  _SubmitWidgetState(this.delegate);

  @override
  void initState() {
    super.initState();

    button = SDUIButton(
        caption: delegate.caption,
        onPressed: (context) => delegate._onSubmit(context));
    button.action.pageController = delegate.action.pageController;
  }

  @override
  Widget build(BuildContext context) => button.toWidget(context);
}

/// Date Time
class _DateTimeWidgetStateful extends StatefulWidget {
  final SDUIInput delegate;

  const _DateTimeWidgetStateful(this.delegate, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _DateTimeWidgetState(delegate);
}

class _DateTimeWidgetState extends State<_DateTimeWidgetStateful> {
  static final Logger _logger = LoggerFactory.create('_DateTimeWidgetState');

  DateTime? state;
  DateFormat displayDateFormat = DateFormat("yyyy-MM-dd");
  DateFormat dataDateFormat = DateFormat("yyyy-MM-dd");
  String emptyText = "";
  SDUIInput delegate;

  _DateTimeWidgetState(this.delegate);

  @override
  void initState() {
    super.initState();

    if (delegate.type == 'date') {
      displayDateFormat = DateFormat("dd MMM yyyy");
      dataDateFormat = DateFormat("yyyy-MM-dd");
      emptyText = sduiL10.selectDate;
    } else {
      displayDateFormat = DateFormat("HH:mm");
      dataDateFormat = DateFormat("HH:mm");
      emptyText = sduiL10.selectTime;
    }

    if (delegate.value == null || delegate.value?.isEmpty == true) {
      state = null;
    } else {
      try {
        state = dataDateFormat.parse(delegate.value!);
      } catch (e) {
        _logger.w("Invalid date: ${delegate.value}");
      }
    }
    delegate.provider?.setData(delegate.name, _text());
  }

  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: Column(
        key: delegate.id == null ? null : Key(delegate.id!),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(delegate.caption ?? '',
                style: const TextStyle(color: Color(0xff707070), fontSize: 12)),
          ),
          SizedBox(
              width: double.infinity,
              child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 1, color: Color(0xff909090))),
                  ),
                  child: TextButton(
                    style: const ButtonStyle(alignment: Alignment.centerLeft),
                    child: Text(
                      _displayText(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () => _selectDateOrTime(context),
                  )))
        ],
      ));

  String _text() => state == null ? emptyText : dataDateFormat.format(state!);

  String _displayText() =>
      state == null ? emptyText : displayDateFormat.format(state!);

  void _selectDateOrTime(BuildContext context) async {
    if (delegate.type == 'date') {
      _selectDate(context);
    } else if (delegate.type == 'time') {
      _selectTime(context);
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year + 100),
    );

    if (picked != null && picked != state) {
      setState(() {
        state = picked;
        delegate.provider?.setData(delegate.name, _text());
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: state == null
            ? TimeOfDay.fromDateTime(DateTime.now())
            : TimeOfDay(hour: state!.hour, minute: state!.minute));

    if (picked != null) {
      setState(() {
        var date = state ?? DateTime.now();
        state = DateTime(
            date.year, date.month, date.day, picked.hour, picked.minute);
        delegate.provider?.setData(delegate.name, _text());
      });
    }
  }
}

/// Phone
class _PhoneWidgetStateful extends StatefulWidget {
  final SDUIInput delegate;

  const _PhoneWidgetStateful(this.delegate, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _PhoneWidgetState(delegate);
}

class _PhoneWidgetState extends State<_PhoneWidgetStateful> {
  String state = '';
  SDUIInput delegate;
  PhoneNumber? number;

  _PhoneWidgetState(this.delegate);

  @override
  void initState() {
    super.initState();

    state = delegate.value ?? '';
    delegate.provider?.setData(delegate.name, state);
    number = toPhoneNumber(state);
  }

  @override
  Widget build(BuildContext context) => InternationalPhoneNumberInput(
        key: delegate.id == null ? null : Key(delegate.id!),
        selectorConfig:
            const SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
        ignoreBlank: true,
        formatInput: false,
        isEnabled: delegate.enabled,
        countries: delegate.countries,
        textFieldController: TextEditingController(text: number?.phoneNumber),
        initialValue: number,
        hintText: delegate.caption,
        onInputChanged: (v) => _onChanged(v),
        validator: (s) => _onValidate(s),
      );

  void _onChanged(PhoneNumber value) {
    delegate.provider?.setData(delegate.name, value.phoneNumber ?? '');
  }

  String? _onValidate(String? value) {
    return delegate._onValidate(value);
  }

  PhoneNumber? toPhoneNumber(String value) {
    if (value.isEmpty) return PhoneNumber(isoCode: delegate.initialCountry);

    List<Map<String, dynamic>> countries =
        List<Map<String, dynamic>>.from(Countries.countryList);
    countries.sort((a, b) => b["dial_code"].length - a["dial_code"].length);

    Map<String, dynamic>? country;
    for (var element in countries) {
      if (value.startsWith(element["dial_code"])) {
        country = element;
        break;
      }
    }

    return country == null
        ? PhoneNumber(isoCode: delegate.initialCountry)
        : PhoneNumber(
            isoCode: country["alpha_2_code"],
            dialCode: country["dial_code"],
            phoneNumber:
                state.substring(country["dial_code"].toString().length));
  }
}

/// Image
class _ImageWidgetStateful extends StatefulWidget {
  final SDUIInput delegate;

  const _ImageWidgetStateful(this.delegate, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _ImageWidgetState(delegate);
}

class _ImageWidgetState extends State<_ImageWidgetStateful> {
  SDUIInput delegate;
  SDUIButton button = SDUIButton();

  _ImageWidgetState(this.delegate);

  @override
  void initState() {
    super.initState();

    button = SDUIButton(
        caption: delegate.caption,
        type: "text",
        onPressed: (context) => _onPressed(context));
    button.id = delegate.id;
    button.action.pageController = delegate.action.pageController;
  }

  @override
  Widget build(BuildContext context) => button.toWidget(context);

  Future<String?> _onPressed(BuildContext context) async {
    XFile? file;
    final ImagePicker picker = ImagePicker();
    final ImageSource source = delegate.imageSource?.toLowerCase() == 'gallery'
        ? ImageSource.gallery
        : ImageSource.camera;

    switch (delegate.type.toLowerCase()) {
      case 'video':
        file = await picker.pickVideo(
            source: source,
            maxDuration: delegate.videoMaxDuration == null
                ? null
                : Duration(seconds: delegate.videoMaxDuration!));
        break;

      default:
        file = await picker.pickImage(
            source: source,
            maxHeight: delegate.imageMaxHeight?.toDouble(),
            maxWidth: delegate.imageMaxWidth?.toDouble());
    }

    if (file != null) {
      Http.getInstance()
          .upload(delegate.uploadUrl!, delegate.name, file)
          .then((value) => delegate.action.execute(context, null));
    }
    return file?.name;
  }
}

/// File
class _FileWidgetStateful extends StatefulWidget {
  final SDUIInput delegate;

  const _FileWidgetStateful(this.delegate, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _FileWidgetState(delegate);
}

class _FileWidgetState extends State<_FileWidgetStateful> {
  SDUIInput delegate;
  SDUIButton button = SDUIButton();
  String? _filename;
  bool _loading = false;

  _FileWidgetState(this.delegate);

  @override
  void initState() {
    super.initState();

    button = SDUIButton(
        caption: delegate.caption,
        type: "text",
        onPressed: (context) => _onPressed(context));
    button.id = delegate.id;
    button.action.pageController = delegate.action.pageController;
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          button.toWidget(context),
          if (_loading)
            const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ))
          else if (_filename != null)
            Text(_filename!)
          else
            Container()
        ],
      );

  Future<String?> _onPressed(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    File? file = result != null ? File(result.files.single.path!) : null;

    if (file != null) {
      setLoading(true);
      String? mimeType = lookupMimeType(file.path);
      Http.getInstance()
          .uploadStream(delegate.uploadUrl!, delegate.name, file.path,
              file.readAsBytes().asStream(), mimeType, await file.length())
          .then((value) {
        setValue(file.uri.toString());
        delegate.action.execute(context, null);
      }).whenComplete(() => setLoading(false));
    }
    return file?.path;
  }

  void setValue(String value) {
    setState(() {
      _filename = value.substring(value.lastIndexOf("/") + 1);
      delegate.provider?.setData(delegate.name, value);
    });
  }

  void setLoading(bool value) {
    setState(() {
      _loading = value;
    });
  }
}
