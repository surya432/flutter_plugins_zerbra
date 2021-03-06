import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  BluetoothDevice _device;
  static const platform = const MethodChannel('surya432.rnd.dev/zebraprint');
  String _batteryLevel = 'Unknown battery level.';
  List<dynamic> btDevices;
  String tips = 'no device connect';

  bool isShowDevices = false;
  void _incrementCounter() {
    setState(() {
      isShowDevices = false;
      getDevices();
      WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
    });
  }

  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected;

    bluetoothPrint.state.listen((state) {
      print('cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {});
    }
  }

  Future<void> _getBtDevices() async {
    String batteryLevel;
    try {
      final String result = await platform.invokeMethod('getDevicesBluetooth');
      batteryLevel = result;
    } on PlatformException catch (e) {
      print("Failed to get devices: '${e.message}'.");
    }
    print("_getBtDevices:" + batteryLevel);
    setState(() {
      btDevices = jsonDecode(batteryLevel);
    });
    // return jsonDecode(batteryLevel);
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

  Future<void> _getPrinterTest(mac) async {
    print("start print $mac");
    String batteryLevel;
    try {
      final String result = await platform
          .invokeMethod('printTest', <String, dynamic>{"mac": mac});
      batteryLevel = 'printTestDevice at $result % OK .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
    setState(() => isShowDevices = true);
  }

  Future<void> _prinCpclCode(mac) async {
    print("start print $mac");
    String batteryLevel;
    var dateTimeNow = DateFormat('yyyy-MM-dd H:m:s').format(DateTime.now());
    try {
      final String dataPrint =
          "! 0 200 200 515 1\r\nJURNAL\r\nCENTER 383\r\nTEXT 4 0 0 15 PT.SUPRAMA\r\nTEXT 7 0 0 55 --------------------------------\r\nLEFT\r\nTEXT 7 0 0 75 \r\nLEFT\r\nTEXT 7 0 0 75 Sales    :Surya Hadi Prastya\r\nLEFT\r\nTEXT 7 0 0 95 Penerima :Surya Heho\r\nRIGHT\r\nTEXT 7 0 0 130 25-04-2020 08:45 \r\nLEFT\r\nTEXT 7 0 0 130 #0501479923   \r\nTEXT 7 0 0 150 --------------------------------\r\nLEFT\r\nTEXT 7 0 0 170 Aqua GLN 20Lit 991   10.000.000\r\nLEFT\r\nTEXT 7 0 0 190  er ASLI AQUA  \r\nLEFT\r\nTEXT 7 0 0 210 Air Mineral 36   4       10.000\r\nLEFT\r\nTEXT 7 0 0 230  0 Ml          \r\nLEFT\r\nTEXT 7 0 0 250 FruitTea 350ML   2        7.000\r\nLEFT\r\nTEXT 7 0 0 270 Mie Burung Dar   2       70.000\r\nLEFT\r\nTEXT 7 0 0 290  a Enaknya nyam\r\nLEFT\r\nTEXT 7 0 0 310  bung terus    \r\nTEXT 7 0 0 330 --------------------------------\r\nRIGHT\r\nTEXT 7 0 0 350       10.087.000 \r\nLEFT\r\nTEXT 7 0 0 350 Total        :\r\nRIGHT\r\nTEXT 7 0 0 370            2.000 \r\nLEFT\r\nTEXT 7 0 0 370 Disc         :\r\nRIGHT\r\nTEXT 7 0 0 390       10.085.000 \r\nLEFT\r\nTEXT 7 0 0 390 Total Bayar  :\r\nCENTER\r\nTEXT 5 1 0 420 DONE\r\nPRINT\r\n";
      final String result = await platform.invokeMethod('sendCpclOverBluetooth',
          <String, dynamic>{"mac": mac, "dataPrint": dataPrint});
      batteryLevel = 'printTestDevice at $result % OK .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
  }

  @override
  Widget build(BuildContext context) {
    var list = FutureBuilder<dynamic>(
      // future: _getBtDevices(),
      initialData: btDevices,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // print("data kosong ${snapshot.error}");
          return Text("Gagal Mendapatkan Data Log");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done &&
            snapshot.data.length > 0) {
          // return buildItemList(snapshot);
        } else {
          return Text("Data Kosong");
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: buildCenter(context),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothPrint.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => bluetoothPrint.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () =>
                    bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }

  Center buildCenter(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          StreamBuilder<List<BluetoothDevice>>(
            stream: bluetoothPrint.scanResults,
            initialData: [],
            builder: (c, snapshot) => Column(
              children: snapshot.data
                  .map((d) => ListTile(
                        title: Text(d.name ?? ''),
                        subtitle: Text(d.address),
                        onTap: () async {
                          setState(() {
                            _device = d;
                          });
                        },
                        trailing:
                            _device != null && _device.address == d.address
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : null,
                      ))
                  .toList(),
            ),
          ),
          Divider(),
          RaisedButton(
            child: Text('Get Battery Level'),
            onPressed: () {
              // getBatteryLevel();
              _getBtDevices();
              getDevices();
            },
          ),
          Text(_batteryLevel),
          Text("Data List Bluetooth"),
          // list,
          // buildItemList(btDevices),
          isShowDevices ? buildItemList(btDevices) : Text("Belum Ada Data"),
        ],
      ),
    );
  }

  Widget buildItemList(List<dynamic> snapshot) {
    return Container(
      constraints: new BoxConstraints(
        minHeight: 90.0,
        maxHeight: double.infinity,
      ),
      child: ListView.builder(
        itemCount: snapshot.length,
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          Map<String, dynamic> dataVendor = snapshot[index];
          String name = dataVendor['name'].toString();
          String mac = dataVendor['mac'].toString();
          return SizedBox(
            child: FlatButton(
              onPressed: isShowDevices
                  ? () async {
                      // setState(() => isShowDevices = false);

                      await _prinCpclCode(mac);
                      // await _getPrinterTest(mac);
                    }
                  : null,
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

  void getDevices() async {
    String batteryLevel;
    try {
      final String result = await platform.invokeMethod('getDevicesBluetooth');
      batteryLevel = result;
    } on PlatformException catch (e) {
      print("Failed to get devices: '${e.message}'.");
    }
    print("_getBtDevices:" + batteryLevel);
    setState(() {
      isShowDevices = true;
      btDevices = jsonDecode(batteryLevel);
    });
  }

  void getBatteryLevel() async {
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

  void printTestDevice(String mac) async {
    print("start print $mac");
    String batteryLevel;
    try {
      final String result = await platform
          .invokeMethod('printTest', <String, dynamic>{"mac": mac});
      batteryLevel = 'printTestDevice at $result % OK .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
  }

  void printCpclDevice(String mac) async {
    print("start print $mac");
    String batteryLevel;
    var dateTimeNow = DateFormat('yyyy-MM-dd H:m:s').format(DateTime.now());
    try {
      String dataPrint = "! 0 200 200 210 1\r\n" +
          // "JURNAL" +
          "CENTER\r\n" +
          "TEXT 4 0 20 25 PT.SUPRAMA\r\n" +
          "LINE 0 70 360 70 1\r\n" +
          "TEXT 7 0 0 80 $dateTimeNow | SURYA \r\n" +
          "LINE 0 105 383 105 1\r\n" +
          "TEXT 7 0 0 130 Aqua 650ML  5000  1   5000\r\n" +
          "TEXT 7 0 0 150 Aqua 350ML  2500  1   2500\r\n" +
          "TEXT 7 0 0 170 Lee Mineral 2500  1   2500\r\n" +
          "LINE 0 225 360 225 1\r\n" +
          "CENTER\r\n" +
          "TEXT 7 0 0 250 POTONG DISINI\r\n" +
          "TEXT 7 0 0 270 .\r\n" +
          "TEXT 7 0 0 290 .\r\n" +
          // "</br>" +
          // "\\r\n" +
          // "! 0 200 200 210 1\r\n" +
          // "TEXT 7 0 0 10 beeps for two seconds\r\n" +
          // "FORM\r\n" +
          "PRINT\r\n";
      dataPrint =
          "! 10 200 200 275 1\r\nJURNAL\r\nCENTER\r\nTEXT 4 0 20 25 PT.SUPRAMA\r\nLINE 0 50 383 50\r\nLEFT\r\nTEXT 7 0 0 75 Aqua GLN 20 99@250000  10000000\r\nTEXT 7 0 0 100 Liter ASLI  \r\nTEXT 7 0 0 125 Air Mineral  4@2500       10000\r\nTEXT 7 0 0 150  360 Ml \r\nTEXT 7 0 0 175 FruitTea 35  2@3500        7000\r\nTEXT 7 0 0 200 0ML \r\nPRINT\r\n";
      final String result = await platform.invokeMethod('sendCpclOverBluetooth',
          <String, dynamic>{"mac": mac, "dataPrint": dataPrint});
      batteryLevel = 'printTestDevice at $result % OK .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
  }
}
