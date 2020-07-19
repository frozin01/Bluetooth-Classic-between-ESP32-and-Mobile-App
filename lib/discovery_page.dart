import 'package:belajarbeneran/bluetooth_device_list_entry.dart';
import 'package:belajarbeneran/devices_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';

class DiscoveryPage extends StatefulWidget {
  @override
  _DiscoveryPageState createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  
  //Hasil discovering
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>();
  
  //state of discovering
  bool isDiscovering;

  //inisialisasi awal
  @override
  void initState() {
    super.initState();
    isDiscovering = true;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  //Restart discovery
  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });
    _startDiscovery();
  }

  //Start discovery
  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((dataDevice) {
      setState(() {
        results.add(dataDevice);
      });
    });
    _streamSubscription.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  // Avoid memory leak (`setState` after dispose) and cancel discovery
  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isDiscovering
            ? Text('Discovering devices')
            : Text('Discovered devices'),
        actions: <Widget>[
          isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: new EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.replay),
                  onPressed: () {
                    _restartDiscovery();
                  },
                )
        ],
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (BuildContext context, index) {
          BluetoothDiscoveryResult result = results[index];
          return BluetoothDeviceListEntry(
            device: result.device,
            rssi: result.rssi,
            onTap: () async {
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                return DevicesPage(device: result.device);
              }));
            },
          );
        },
      ),
    );
  }
}
