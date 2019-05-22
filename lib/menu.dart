import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Keys {
  static final String isAutoCopyOn = 'isAutoCopyOn';
  static final String isAutoPasteOn = 'isAutoPasteOn';
  static final String doClearAfterCopy = 'doClearAfterCopy';
  static final String doShowPushNotification = 'doShowPushNotification';
}

class Menu extends StatelessWidget {
  const Menu();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 100,
            child: DrawerHeader(
              child: Row(
                children: <Widget>[
                  Text(
                    'Settings',
                    style: TextStyle(color: Colors.white)
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    color: Colors.white,
                    padding: EdgeInsets.only(top: 0, bottom: 8, left: 8, right: 8),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
            )
          ),
          ListTile(
            title: TextSwitch(title: 'Auto Copy', key: Keys.isAutoCopyOn, defaultValue: true),
          ),
          ListTile(
            title: TextSwitch(title: 'Auto Paste on load', key: Keys.isAutoPasteOn, defaultValue: false),
          ),
          ListTile(
            title: TextSwitch(title: 'Clear Text after copy', key: Keys.doClearAfterCopy, defaultValue: false),
          ),
          ListTile(
            title: TextSwitch(title: 'Push notification after copy', key: Keys.doShowPushNotification, defaultValue: true),
          ),
        ],
      ),
    );
  }
}

class TextSwitch extends StatefulWidget {
  final String _key;
  final String _title;
  final bool _value;

  TextSwitch({String key, String title, bool defaultValue}):
    _key = key,
    _title = title,
    _value = defaultValue;

  @override
  State<StatefulWidget> createState() => TextSwitchState(key: _key, title: _title, defaultValue: _value);
}

class TextSwitchState extends State<TextSwitch> {
  final String _key;
  final String _title;
  bool _value;

  TextSwitchState._(this._key, this._title, this._value);
  factory TextSwitchState({String key, String title, bool defaultValue}) {
    TextSwitchState state = TextSwitchState._(key, title, defaultValue);
    state._loadDataFromSharedPreferences(key);
    return state;
  }

  _loadDataFromSharedPreferences(String key) {
    SharedPreferences.getInstance()
      .then((prefs) => setState(() => _value = (prefs.getBool(_key) ?? _value)));
  }
  _onChanged(bool value) {
    setState(() => _value = value);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_key, value);
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(_title),
        Switch(
          value: _value,
          activeColor: Colors.blueGrey,
          inactiveThumbColor: Colors.grey,
          onChanged: _onChanged,
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
