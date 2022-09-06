import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../../components/constants.dart';

class Home extends StatefulWidget {
  String userID;
  Home({Key? key, required this.userID}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String mysolde = "";
  dynamic? transactionsItem;
  int i = 0;
  bool testTransaction = false;

  void accountRequest(String userID) async {
    debugPrint("ACCOUNT REQUEST - HOME");

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
          i += 1;
          debugPrint("-----  $i -------");
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
  void transactionsRequest(String userID) async {
    debugPrint("TRANSACTIONS REQUEST - HOME");

    try {
      debugPrint(
          "Tentative de recupération des infos des transactions [${api}users/$userID/accounts/]");
      Response responseTransactions =
          await get(Uri.parse('${api}users/$userID/transactions/'));

      debugPrint("Code de la reponse : [${responseTransactions.statusCode}]");
      debugPrint("Contenue de la reponse : ${responseTransactions.body}");

      if (responseTransactions.statusCode == 200) {
        Map<String, dynamic> tmp =
            jsonDecode(responseTransactions.body.toString());

        debugPrint("Retour du solde du client");
        setState(() {
          transactionsItem = tmp['user_sender'];
          debugPrint("Transactions : $transactionsItem");
        });
      } else {
        debugPrint("La requete e échouée");

        setState(() {
          i += 1;
          debugPrint("-----  $i -------");
          transactionsItem = jsonDecode("[{}]");
        });
        debugPrint("Transactions  : $transactionsItem");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    // ignore: todo
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    accountRequest(widget.userID);
    transactionsRequest(widget.userID);
    debugPrint("Le solde définitif : $mysolde");
    debugPrint("Liste des Transactions  : $transactionsItem");

    return Scaffold(
      body: Column(
        children: <Widget>[
          appBarBottomSection(),
          mainBody(),
        ],
      ),
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
          Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: kWeightBoldColor,
              borderRadius: BorderRadius.circular(30),
              border:
                  Border.all(color: kPrimaryColor.withOpacity(0.1), width: 2),
              boxShadow: [
                BoxShadow(
                  color: kWeightBoldColor.withOpacity(0.4),
                  offset: const Offset(0, 8),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Vous disposez de',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mysolde,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
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
              ],
            ),
          ),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  Expanded mainBody() {
    /*List<TransactionsModel> transactionList = [
      const TransactionsModel(
        toSend: false,
        name: "Kouassi Ezechiel",
        date: "26/08/2022 - 21:05",
        amount: "0.0",
      ),
      const TransactionsModel(
        toSend: true,
        name: "Bado Moïse",
        date: "26/08/2022 - 21:03",
        amount: "0.0",
      ),
    ];*/

    debugPrint(
        "\n--------------------------------\n $transactionsItem \n -------------------------\n");

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 32,
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        'Résumé transactions',
                        style: TextStyle(
                          color: kWeightBoldColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
                transactionsWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionsWidget() {
    if (transactionsItem == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [Text("Aucune transaction éffectuée")],
      );
    } else {
      return ListView.separated(
        primary: false,
        shrinkWrap: true,
        separatorBuilder: (context, index) => const Divider(),
        itemCount: transactionsItem.length,
        itemBuilder: (context, index) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 60,
            height: 60,
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.center,
            decoration: const BoxDecoration(),
            child: (transactionsItem[index]["sender"] == widget.userID)
                ? const Icon(Icons.call_made, size: 20)
                : const Icon(Icons.call_received, size: 20),
          ),
          title: Text(
            transactionsItem[index]["recipient"],
            style: const TextStyle(
              color: kWeightBoldColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            "${transactionsItem[index]["datetime"]}",
            style: TextStyle(
              color: kWeightBoldColor.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Text(
            "${transactionsItem[index]["amount"]}",
            style: const TextStyle(
              color: kWeightBoldColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }
}
