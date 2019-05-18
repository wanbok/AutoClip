import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Keys {
  static final String isAutoCopyOn = 'isAutoCopyOn';
}

class Menu extends StatefulWidget {
  const Menu();
  @override
  _MenuState createState() => new _MenuState();
}

class _MenuState extends State<Menu> {
  _MenuState() {
    _loadDataFromSharedPreferences();
  }

  bool _isActive = true;

  _loadDataFromSharedPreferences() {
    SharedPreferences.getInstance()
      .then((prefs) => setState(() => _isActive = (prefs.getBool(Keys.isAutoCopyOn) ?? true)));
  }

  _onChanged(bool value) {
    setState(() => _isActive = value);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Keys.isAutoCopyOn, value);
    }); 
  }

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
              title: Row(
                children: <Widget>[
                  Text('Auto Copy'),
                  Switch(
                    value: _isActive,
                    activeColor: Colors.blueGrey,
                    inactiveThumbColor: Colors.grey,
                    onChanged: _onChanged,
                  ),
                ]
              ),
            ),
          ],
        ),
      );
  }
}