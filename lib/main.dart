import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_service.dart';

void main() => runApp(AutoClipApp());

class AutoClipApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Clip',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Main(title: 'Auto Clip'),
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
  final key = new GlobalKey<ScaffoldState>();
  final textEditingController = TextEditingController();
  final notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _contentCopy(textEditingController.text);
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.suspending:
        // Will not be used.
        break;
    }
  }

  Future _contentCopy(String text) async {
    if (text.trim().isEmpty) return;
    final ClipboardData oldData = await Clipboard.getData('text/plain');
    if (text == oldData.text) return;

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      Clipboard.setData(new ClipboardData(text: text));
      key.currentState.showSnackBar(
        new SnackBar(content: new Text("Copied to Clipboard: " + text),)
      );
      notificationService.showNotification(text);
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
      body: new Container(
        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              autofocus: true,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: 'Write texts to clip on'
              ),
              style: Theme.of(context).textTheme.headline,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){ _contentCopy(textEditingController.text); },
        tooltip: 'Copy',
        child: Icon(Icons.content_copy),
      ),
    );
  }
}
