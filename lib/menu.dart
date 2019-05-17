import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu();
  @override
  _MenuState createState() => new _MenuState();
}

class _MenuState extends State<Menu> {
  bool _isActive = true;

  void _onChanged(bool value) => setState(() => _isActive = value);

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
                child: Text(
                  'Settings',
                  style: TextStyle(color: Colors.white)
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
              onTap: () {
                // Update the state of the app
                
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Close'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
  }
}