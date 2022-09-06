// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart';
import '../../components/constants.dart';

class SendMoney extends StatefulWidget {
  final String userID;
  const SendMoney({Key? key, required this.userID}) : super(key: key);

  @override
  State<SendMoney> createState() => _SendMoneyState();
}

class _SendMoneyState extends State<SendMoney> {
  TextEditingController destinationAddressController = TextEditingController();
  TextEditingController amountToSendController = TextEditingController();

  String mysolde = "";
  String sendCode = "";
  String receiveCode = "";

  void accountRequest(String userID) async {
    debugPrint("ACCOUNT REQUEST - RECEIVE PAGE");

    try {
      debugPrint(
          "Tentative de recupération des infos solde [${api}users/$userID/accounts/]");
      Response responseAccount =
          await get(Uri.parse('${api}users/$userID/accounts/'));

      debugPrint("Code de la reponse : [${responseAccount.statusCode}]");
      debugPrint("Contenue de la reponse : ${responseAccount.body}");

      if (responseAccount.statusCode == 200) {
        Map<String, dynamic> tmp = jsonDecode(responseAccount.body.toString());

        Map<String, dynamic> account = tmp['account_owner'][0];
        debugPrint("Retour du solde du client");
        setState(() {
          mysolde = account['amount'].toString();
          debugPrint("Mon solde mis a jour : $mysolde");
        });
      } else {
        debugPrint("La requete e échouée");

        setState(() {
          mysolde = "0.0";
          //account['status_account'].toString();
        });
        debugPrint("Mon solde mis a jour : $mysolde");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  ///
  ///
  ///
  void userDataRequest(String userID) async {
    debugPrint("USERDATA REQUEST - RECEIVE PAGE");

    try {
      debugPrint(
          "Tentative de recupération des infos utilisateurs [${api}users/$userID/]");
      Response responseAccount = await get(Uri.parse('${api}users/$userID/'));

      debugPrint("Code de la reponse : [${responseAccount.statusCode}]");
      debugPrint("Contenue de la reponse : ${responseAccount.body}");

      if (responseAccount.statusCode == 200) {
        Map<String, dynamic> tmp = jsonDecode(responseAccount.body.toString());

        debugPrint("Retour du solde du client");
        setState(() {
          sendCode = tmp['send_code'].toString();
          receiveCode = tmp['receive_code'].toString();
          debugPrint("Votre code d'envoi est  : $sendCode");
          debugPrint("Votre code de reception est  : $receiveCode");
        });
      } else {
        debugPrint("La requete e échouée");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    accountRequest(widget.userID);
    userDataRequest(widget.userID);
    return Scaffold(
      body: Column(
        children: <Widget>[
          appBarBottomSection(),
          const SizedBox(
            height: 100,
          ),
          mainBody(),
        ],
      ),
    );
  }

  ///
  ///
  ///

  Container appBarBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Fonds total",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 0.9,
                  )),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                mysolde,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  height: 0.9,
                ),
              ),
              Text(
                ' Fcfa',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Expanded mainBody() {
    return Expanded(
      child: Column(
        children: [
          Form(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: defaultPadding, horizontal: defaultPadding * 2),
              child: Column(
                children: [
                  TextFormField(
                    controller: destinationAddressController,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    //onSaved: (email) {},
                    decoration: InputDecoration(
                      hintText: "Adresse du destinataire",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: kWeightBoldColor)),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(defaultPadding),
                        child: Icon(Icons.qr_code),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: defaultPadding,
                  ),
                  TextFormField(
                    controller: amountToSendController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      hintText: "Montant à transferer",
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(defaultPadding),
                        child: Icon(Icons.currency_franc),
                      ),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: kWeightBoldColor)),
                    ),
                  ),
                  SizedBox(height: defaultPadding * 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Montant restant"),
                      Text(
                          "${double.parse((mysolde.isNotEmpty) ? mysolde : "0.0") - double.parse((amountToSendController.text.isNotEmpty) ? amountToSendController.text : "0.0")}"),
                    ],
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  FloatingActionButton(
                    backgroundColor: kPrimaryColor,
                    onPressed: () async {
                      destinationAddressController.text =
                          await FlutterBarcodeScanner.scanBarcode(
                              '#ffffff', 'retour', true, ScanMode.QR);
                      print(destinationAddressController.text);
                    },
                    child: const Icon(
                      Icons.qr_code_scanner_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: defaultPadding,
                        horizontal: defaultPadding * 3),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (double.parse(
                                (mysolde.isNotEmpty) ? mysolde : "0.0") >
                            double.parse(
                                (amountToSendController.text.isNotEmpty)
                                    ? amountToSendController.text
                                    : "0.0")) {
                          if (receiveCode !=
                              destinationAddressController.text) {
                            try {
                              print("Tentative d'envoie d'argent");
                              Response response = await post(
                                  Uri.parse(
                                      'http://devinstapay.pythonanywhere.com/api/v1/transactions/'),
                                  body: jsonEncode(<String, String>{
                                    "user_id": widget.userID,
                                    "send_code": sendCode,
                                    "receive_code":
                                        destinationAddressController.text,
                                    "amount": amountToSendController.text
                                  }),
                                  headers: <String, String>{
                                    "Content-Type": "application/json"
                                  });

                              print(
                                  "Code de la reponse : [${response.statusCode}]");
                              print(
                                  "Contenue de la reponse : ${response.body}");

                              if (response.statusCode == 200) {
                                print("Transaction reussie");
                              } else {
                                print("Transaction échouée");
                              }
                            } catch (e) {
                              print(e.toString());
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [Text("Transaction inutile")],
                            )));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text("Votre solde est insuffisant")
                            ],
                          )));
                        }
                      },
                      child: Text(
                        "Envoyer",
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
