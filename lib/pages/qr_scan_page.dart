// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');

  /// If Barcode found, store in this variable
  Barcode? barcode;
  QRViewController? controller;

  String _url = "";

  bool _isLaunchableSite = false;
  bool _isFaceBookSite = false;
  bool _isYouTubeSite = false;
  bool _isLineApp = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();

    /// Need to fix hot-reload for Camera
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          buildQrView(context),
          Positioned(bottom: 40, child: buildResult()),
          Positioned(
              bottom: 110,
              child: barcode != null
                  ? buildResultButton()
                  : Text(
                      "scanning...",
                      style: TextStyle(fontSize: 22),
                    ))
        ],
      ),
    );
  }

  /// If the scanned result is launchable site
  /// @return Button Widget
  Widget buildResultButton() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: buttonBackgroundColor()),
      child: TextButton(
        child: buttonText(),
        onPressed: () => lauchSite(),
      ),
    );
  }

  /// Launch url site
  void lauchSite() async {
    /// Launching
    if (await canLaunch(_url)) await launch(_url);

    /// Refresh boolean values, once button pressed
    setState(() {
      if (_isLaunchableSite) _isLaunchableSite = false;
      if (_isFaceBookSite) _isFaceBookSite = false;
      if (_isYouTubeSite) _isYouTubeSite = false;
      if (_isLineApp) _isLineApp = false;
    });
  }

  /// @return Color for Button Widget
  Color? buttonBackgroundColor() {
    if (_isFaceBookSite) return Colors.blue[900];
    if (_isYouTubeSite) return Colors.red[900];
    if (_isLineApp) return Colors.green;
    return Colors.white70;
  }

  /// @return Text for Button Widget
  Text buttonText() {
    String text = "Go to : ";

    if (_isFaceBookSite) {
      text += "Facebook";
    } else if (_isYouTubeSite) {
      text += "Youtube";
    } else if (_isLineApp) {
      text += "Line";
    } else {
      text += _url;
    }

    return Text(
      text,
      style: TextStyle(color: Colors.white70),
    );
  }

  /// Show scanning result in Text
  Widget buildResult() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: Colors.white24),
      child: Text(
        barcode != null ? "Result : ${barcode!.code}" : "Scan a code!",
        maxLines: 3,
      ),
    );
  }

  /// QRCode reading area view
  Widget buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.blue,
        borderRadius: 10,
        borderLength: 20,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }

  /// Use to control QR scanning area
  onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    /// If the Camera found a QRCode
    controller.scannedDataStream.listen((barcode) => setState(() {
          this.barcode = barcode;

          _url = this.barcode?.code ?? "";

          if (_url.contains("http")) {
            _isLaunchableSite = true;
          }

          /// If the site is either Facebook or Youtube or Line
          if (_url.contains("facebook.com")) {
            _isFaceBookSite = true;
          } else if (_url.contains("youtube.com")) {
            _isYouTubeSite = true;
          } else if (_url.contains("line.me")) {
            _isLineApp = true;
          }
        }));
  }
}
