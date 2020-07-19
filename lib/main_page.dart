import 'package:belajarbeneran/discovery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //inisialisasi bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Track the Bluetooth connection with the device
  BluetoothConnection connection;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  //disconnecting state
  bool isDisconnecting = false;

  //Nama dan alamat bluetooth kita
  String _address = "";
  String _name = "";

  //state dari bluetooth device
  BluetoothState state;

  //inisialisasi awal
  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    //Get device address
    FlutterBluetoothSerial.instance.address.then((address) {
      setState(() {
        _address = address;
      });
    });

    //Get device name
    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  // Avoid memory leak and disconnect
  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Bluetooth Classic Serial'),
      ),
      body: ListView(
        children: <Widget>[
          //Nama bluetooth
          ListTile(
            title: const Text('Nama Bluetooth Device'),
            subtitle: Text(_name),
            onLongPress: null,
          ),
          //Adress bluetooth
          ListTile(
            title: const Text('Adress Bluetooth Device'),
            subtitle: Text(_address),
          ),
          //Aktif dan non aktif bluetooth
          SwitchListTile(
            title: Text("Aktifkan Bluetooth"),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              future() async {
                if (value)
                  await FlutterBluetoothSerial.instance.requestEnable();
                else
                  await FlutterBluetoothSerial.instance.requestDisable();
              }
              future().then((_) {
                setState(() {});
              });
            },
          ),
          //Ke settings device
          ListTile(
            title: Text('Settings'),
            onTap: () async {
              await FlutterBluetoothSerial.instance.openSettings();
            },
          ),
          //Cek bluetooth device lain
          ListTile(
            title: RaisedButton(
                child: const Text('Explore devices'),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return DiscoveryPage();
                      },
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
