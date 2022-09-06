// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:instapay/Screens/Login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/constants.dart';
import '../UserProfile/profile.dart';
import '../About/about.dart';

import '../MainPages/home.dart';
import '../MainPages/transaction.dart';
import '../MainPages/send_money.dart';
import '../MainPages/receive_money.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  late Map<String, dynamic> userAccountData = jsonDecode("{}");

  HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int i = 0;
  String mysolde = "null";
  Map<String, dynamic> account = jsonDecode("{}");

  void accountRequest(String userID) async {
    debugPrint("ACCOUNT REQUEST");
    //Map<String, dynamic> account = jsonDecode("{}");

    debugPrint("$account");
    debugPrint("$api/users/$userID/accounts/");

    try {
      debugPrint("Tentative de recupération des infos solde");
      Response response = await get(Uri.parse('$api/users/$userID/accounts/'));

      debugPrint("Code de la reponse : [${response.statusCode}]");
      debugPrint("Contenue de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        String userAccountData = response.body.toString();
        Map<String, dynamic> tmp = jsonDecode(userAccountData);

        account = tmp['account_owner'][0];
        debugPrint("Retour du solde du client");
        setState(() {
          i += 1;
          debugPrint("-----  $i -------");
          mysolde = account['amount'].toString();
          debugPrint("Mon solde mis a jour : $mysolde");
        });
      } else {
        debugPrint("La requete e échouée");
        mysolde = "0.0";

        debugPrint("Mon solde mis a jour : $mysolde");
      }
    } catch (e) {
      debugPrint(e.toString());
      mysolde = "0.0";
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("INFOS OBTENUS : ${widget.userData}");
    //accountRequest(widget.userData['user_id']);

    //debugPrint("Le solde définitif : $mysolde");

    List<Widget> screens = [
      Home(userID: widget.userData["user_id"]),
      Transaction(solde: mysolde),
      SendMoney(userID: widget.userData["user_id"]),
      ReceiveMoney(userID: widget.userData["user_id"])
    ];

    List<String> titles = [
      widget.userData['contact'],
      "Transactions",
      "Envoyer",
      "Recevoir"
    ];

    return Scaffold(
      appBar: buildAppBar(titles[_selectedIndex]),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF501CE2),
        ),
        child: BottomAppBar(
          child: SizedBox(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconBottomBar(
                        text: "Accueil",
                        icon: (_selectedIndex == 0)
                            ? Icons.home
                            : Icons.home_outlined,
                        selected: _selectedIndex == 0,
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 0;
                          });
                        }),
                    /*IconBottomBar(
                        text: "Transactions",
                        icon: (_selectedIndex == 0)
                            ? Icons.currency_exchange
                            : Icons.currency_exchange_outlined,
                        selected: _selectedIndex == 1,
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        }),*/
                    IconBottomBar(
                        text: "Envoyer",
                        icon: (_selectedIndex == 2)
                            ? Icons.send
                            : Icons.send_outlined,
                        selected: _selectedIndex == 2,
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 2;
                          });
                        }),
                    IconBottomBar(
                        text: "Recevoir",
                        icon: (_selectedIndex == 3)
                            ? Icons.currency_franc
                            : Icons.currency_franc_outlined,
                        selected: _selectedIndex == 3,
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 3;
                          });
                        }),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(String title) {
    void logout() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.clear();
      debugPrint("Déconnexon de l'utilisateur");

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }

    return AppBar(
      title: Text(title),
      //centerTitle: true,
      elevation: 0,
      backgroundColor: kPrimaryColor,
      automaticallyImplyLeading: false,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 0),
          child: IconButton(
            onPressed: () {
              debugPrint('Chargement de la page des notifications');
            },
            icon: const Icon(Icons.notifications),
          ),
        ),
        PopupMenuButton(
          icon: Image.asset(
            'assets/images/menu.png',
            fit: BoxFit.fitWidth,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: "profil",
              child: Row(
                children: const [
                  Icon(
                    Icons.person,
                    color: kWeightBoldColor,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: defaultPadding),
                    child: Text("Mon profile"),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: "invite",
              child: Row(
                children: const [
                  Icon(
                    Icons.share,
                    color: kWeightBoldColor,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: defaultPadding),
                    child: Text("Inviter un ami"),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: "about",
              child: Row(
                children: const [
                  Icon(
                    Icons.info,
                    color: kWeightBoldColor,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: defaultPadding),
                    child: Text("A propos"),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: "settings",
              child: Row(
                children: const [
                  Icon(
                    Icons.settings,
                    color: kWeightBoldColor,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: defaultPadding),
                    child: Text("Paramètres"),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: "logout",
              child: Row(
                children: const [
                  Icon(
                    Icons.logout,
                    color: kWeightBoldColor,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: defaultPadding),
                    child: Text("Se déconecter"),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case "profil":
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserProfil(
                          data: widget.userData,
                        )));
                break;
              case "invite":
                debugPrint("Inviter un ami");
                break;
              case "about":
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AboutPage()));
                break;
              case "settings":
                debugPrint("Chargement des paramètres");
                break;
              case "logout":
                logout();
                break;
              default:
            }
          },
        ),
      ],
    );
  }
}

class IconBottomBar extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;

  const IconBottomBar(
      {Key? key,
      required this.text,
      required this.icon,
      required this.selected,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon,
              size: 25, color: (selected) ? kWeightBoldColor : Colors.grey),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            height: .1,
            color: (selected) ? kWeightBoldColor : Colors.grey,
          ),
        )
      ],
    );
  }
}
