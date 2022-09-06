import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

class QrcodeContainer extends StatelessWidget {
  final String data;
  const QrcodeContainer({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(29),
        color: Colors.transparent,
      ),
      child: BarcodeWidget(data: data, barcode: Barcode.qrCode()),
    );
  }
}
