// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../../components/constants.dart';

import '../Home/component/qrcode_container.dart';

class ReceiveMoney extends StatefulWidget {
  final String userID;
  const ReceiveMoney({Key? key, required this.userID}) : super(key: key);

  @override
  State<ReceiveMoney> createState() => _ReceiveMoneyState();
}

class _ReceiveMoneyState extends State<ReceiveMoney> {
  TextEditingController myTransactionaddress = TextEditingController();
  String mysolde = "";
  String receiveCode = "";

  String hashSomeThing(var data) {
    var dataEncoded = utf8.encode(data.toString());
    Digest hash = sha256.convert(dataEncoded);
    return hash.toString();
  }

  String generateNewAddress(String receiveCode) {
    double random = Random().nextDouble() * 999999.9;
    String address = hashSomeThing(random).substring(0, 10);
    address = "$receiveCode@$address";
    String addressHashed = "addr${hashSomeThing(address)}";
    return addressHashed;
  }

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
          receiveCode = tmp['receive_code'].toString();
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
      //appBar: buildAppBar(),
      body: Column(
        children: <Widget>[
          appBarBottomSection(),
          const SizedBox(
            height: 50,
          ),
          mainBody(),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: kPrimaryColor,
      leading: const Padding(
        padding: EdgeInsets.only(left: 20, top: 15),
        child: Text(
          "Recevoir",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
      ),
      leadingWidth: 500,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 0),
          child: IconButton(
            onPressed: () => print('Chargement de la page des notifications'),
            icon: const Icon(Icons.notifications),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: () => print('Chargement du menu'),
            icon: Image.asset(
              'assets/images/menu.png',
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ],
    );
  }

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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  height: 0.9,
                ),
              ),
              const Text(
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
            height: 8,
          ),
          const SizedBox(
            height: 32,
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Expanded mainBody() {
    Size size = MediaQuery.of(context).size;

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: defaultPadding, horizontal: defaultPadding * 2),
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(29),
                    color: Colors.transparent,
                    border: Border.all(color: kPrimaryColor, width: 1.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: defaultPadding,
                        horizontal: defaultPadding * 2),
                    child: QrcodeContainer(
                      data: receiveCode,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 40,
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                    border: Border.all(color: kPrimaryColor, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            receiveCode,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: defaultPadding * 2,
                ),
                /*
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: defaultPadding, horizontal: defaultPadding * 3),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        generateNewAddress(receiveCode);
                      });
                    },
                    child: const Text(
                      "Générer une nouvvelle adresse",
                    ),
                  ),
                ),
                */
                const SizedBox(height: defaultPadding),
              ],
            ),
          ),
          const SizedBox(
            height: 80,
          ),
          const Text(
            "Se recharger à partir de :",
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/moov.png',
                  height: 50,
                  //width: 80,
                ),
                Image.asset(
                  'assets/images/mtn.png',
                  height: 50,
                  //width: 80,
                ),
                Image.asset(
                  'assets/images/orange.png',
                  height: 50,
                  //width: 80,
                ),
                Image.asset(
                  'assets/images/uba.png',
                  height: 50,
                  //width: 80,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
