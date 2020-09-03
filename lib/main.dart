import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  static const platform = const MethodChannel('surya432.rnd.dev/zebraprint');
  String _batteryLevel = 'Unknown battery level.';
  List<dynamic> btDevices;
  void _incrementCounter() {
    setState(() {
      _counter++;
      _getBatteryLevel();
      // getBtDevices();
    });
  }

  Future<void> _getBtDevices() async {
    String batteryLevel;
    try {
      final String result = await platform.invokeMethod('getDevicesBluetooth');
      batteryLevel = result;
    } on PlatformException catch (e) {
      print("Failed to get devices: '${e.message}'.");
    }
    print(batteryLevel);
    // setState(() {
    //   btDevices = batteryLevel;
    // });
    return jsonDecode(batteryLevel);
  }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _getPrinterTest() async {
    String batteryLevel;
    try {
      final String result = await platform.invokeMethod('printTest');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    var list = FutureBuilder<dynamic>(
      future: _getBtDevices(),
      // initialData: "Terjadi Kesalahan Get Device",
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // print("data kosong ${snapshot.error}");
          return Text("Gagal Mendapatkan Data Log");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done &&
            snapshot.data.length > 0) {
          return buildItemList(snapshot);
        } else {
          return Text("Data Kosong");
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            RaisedButton(
              child: Text('Get Battery Level'),
              onPressed: () {
                _getBatteryLevel();
                _getBtDevices();
              },
            ),
            Text(_batteryLevel),
            Text("Data List Bluetooth"),
            list,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildItemList(AsyncSnapshot snapshot) {
    print("DAta snapshot.data :" + snapshot.data.toString());
    return Container(
      constraints: new BoxConstraints(
        minHeight: 90.0,
        maxHeight: double.infinity,
      ),
      child: ListView.builder(
        itemCount: snapshot.data.length,
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          Map<String, dynamic> dataVendor = snapshot.data[index];
          String name = dataVendor['name'].toString();
          String mac = dataVendor['mac'].toString();
          return SizedBox(
            child: GestureDetector(
              onTap: _getPrinterTest,
              child: Column(
                children: [
                  ListTile(
                    title: Text('$name ( $mac )'),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  new Divider(
                    height: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
