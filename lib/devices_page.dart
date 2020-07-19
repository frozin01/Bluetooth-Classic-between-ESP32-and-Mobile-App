import 'dart:async';
import 'dart:convert'; // buat convert data utf8
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DevicesPage extends StatefulWidget {
  //device
  final BluetoothDevice device;

  const DevicesPage({this.device});

  @override
  _DevicesPage createState() => new _DevicesPage();
}

//Message yang dikirim
class _Message {
  int deviceID;
  String text;

  _Message(this.deviceID, this.text);
}

class _DevicesPage extends State<DevicesPage> {
  //Device ID
  static final deviceID = 0;

  //For cek the connection of bluetooth
  BluetoothConnection connection;

  //connecting state
  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  //disconnecting state
  bool isDisconnecting = false;

  //message
  List<_Message> messages = List<_Message>();

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //inisialisasi awal
  @override
  void initState() {
    super.initState();

    //connecting to device chossed
    BluetoothConnection.toAddress(widget.device.address).then((_connection) {
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      if (this.mounted) {
        setState(() {});
      }
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  // Avoid memory leak (`setState` after dispose) and disconnect
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
      key: _scaffoldKey,
      appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting to ' + widget.device.name)
              : isConnected
                  ? Text(widget.device.name)
                  : Text('Connection Lost'))),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("ON"),
              onPressed: isConnected ? () => _sendMessage("a") : null,
            ),
            RaisedButton(
              child: Text("OFF"),
              onPressed: isConnected ? () => _sendMessage("b") : null,
            )
          ],
        ),
      ),
    );
  }

  //For sending message
  void _sendMessage(String text) async {
    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
        setState(() {
          messages.add(_Message(deviceID, text));
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
    //Snackbar
    if (text == 'a') {
      show('Relay ON');
    }
    if (text == 'b') {
      show('Relay OFF');
    }
  }

  //for showing snackbar
  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}
