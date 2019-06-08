import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';
import 'menu.dart';

void main() => runApp(AutoClipApp());

class AutoClipApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Color color = Colors.blueGrey;
    return MaterialApp(
      title: 'Auto Clip',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: color,
        primaryTextTheme: TextTheme(
          title: TextStyle(
            color: color,
          )
        ),
        appBarTheme: AppBarTheme(
          color: Colors.transparent,
          elevation: 0.0,
          iconTheme: IconThemeData(color: color),
        ),
      ),
      home: Main(title: 'Auto Clip'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Main extends StatefulWidget {
  Main({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> with WidgetsBindingObserver {
  static final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final textEditingController = TextEditingController();
  final notificationService = NotificationService();
  int maxLine = 5;
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    focusNode = FocusNode()..addListener(_refreshMaxTextLine);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _contentCopyIfCan(textEditingController.text);
        break;
      case AppLifecycleState.resumed:
        _resume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.suspending:
        // Will not be used.
        break;
    }
  }

  _contentCopyIfCan(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(Keys.isAutoCopyOn) ?? true)
      _contentCopy(text);
  }

  Future _contentCopy(String text) async {
    if (text.trim().isEmpty) return;
    final ClipboardData oldData = await Clipboard.getData('text/plain');
    if (text == oldData.text) return; // Let the message post even if duplicated
    Clipboard.setData(ClipboardData(text: text));
    _notifyText(text);

    Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    prefs.then((prefs) {
      if (prefs.getBool(Keys.doClearAfterCopy) ?? false)
        textEditingController.clear();
    });
  }

  void _notifyText(String message) {
    Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    prefs.then((prefs) {
      if (prefs.getBool(Keys.doShowPushNotification) ?? true)
        notificationService.showNotification(message);
    });
  }

  void _resume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(Keys.isAutoPasteOn) ?? false) {
      final ClipboardData oldData = await Clipboard.getData('text/plain');
      textEditingController.text = oldData.text;
    }
    FocusScope.of(context).requestFocus(focusNode);
  }

  void _refreshMaxTextLine() {
    setState(() {
      double height = MediaQuery.of(context).size.height;
      double vertical = MediaQuery.of(context).viewInsets.vertical;
      double textHeight = height - vertical;
      maxLine = (textHeight / 80).floor();
      print(maxLine);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _contentCopy method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      key: key,
      appBar: AppBar(
        // Here we take the value from the Main object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0, bottom: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              autofocus: true,
              focusNode: focusNode,
              minLines: 1,
              maxLines: maxLine,
              keyboardType: TextInputType.multiline,
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: 'Write text to clip on',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    textEditingController.clear();
                  }
                ),
              ),
              style: Theme.of(context).textTheme.headline,
            ),
          ],
        ),
      ),
      drawer: const Menu(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){ _contentCopy(textEditingController.text); },
        tooltip: 'Copy',
        child: Icon(Icons.content_copy),
      ),
    );
  }
}
