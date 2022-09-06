// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:instapay/Screens/Home/home_screen.dart';
import 'package:instapay/Screens/PinCode/create_pin_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/pin_widget.dart';
import '../../components/constants.dart';
import '../Login/login.dart';

///
///     PinCodeAuth
///     -----------
/// Cette page a pour but de s'assurer que l'individu qui tente d'acceder à l'application est
/// bien celui qui est connecté actuellement. Car celui-ci a été invité a enregistrer un cde PIN qui
/// le permettra d'acceder à la page d'accueil de l'application.
///

class PinCodeAuth extends StatefulWidget {
  final String userContact;
  const PinCodeAuth({Key? key, required this.userContact}) : super(key: key);

  @override
  State<PinCodeAuth> createState() => _PinCodeAuthState();
}

class _PinCodeAuthState extends State<PinCodeAuth> {
  int pinLenght = 5;
  bool forgetPin = false;
  MPinController mPinController = MPinController();
  List<int> firstRow = [1, 2, 3], secondRow = [4, 5, 6], thirdRow = [7, 8, 9];

  // Condui
  verifyCodePin(String code) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    //hasher le code pin pour le comparer avec celui qui a été déjà enregistré
    var encodePin = utf8.encode(code);
    String pinHash = sha256.convert(encodePin).toString();
    String? pinHashed = pref.getString("pin");

    if (pinHashed != null) {
      // Un code PIN a été enregistré
      debugPrint(" PIN  saved : $pinHashed \n PIN entred : $pinHash");
      if (pinHashed == pinHash) {
        // Le code PIN entré est correct
        debugPrint("Le code PIN est correcte");
        String? savedData = pref.getString("user");

        if (savedData != null) {
          Map<String, dynamic> userData = jsonDecode(savedData);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(userData: userData)));
        }
      } else {
        // le code PIN entré est incorret
        debugPrint("Le code PIN est incorrecte");
        mPinController.notifyWrongInput();
        forgetPin = true;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text("Mauvais code PIN")],
        )));
      }
    } else {
      // Aucun code PIN n'a été enregistré, conduire l'utilisateur à la page de connexion
      debugPrint("Aucun code PIN n'as été enregistré");
      await pref.clear();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreatePinCode(
              userContact: widget.userContact,
            ),
          ));
    }
    setState(() {});
  }

  void logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
    debugPrint("Déconnexon de l'utilisateur ...");

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: kToolbarHeight,
          ),

          // Bouton de déconnexion
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    logout();
                  },
                  child: const Text(
                    "Déconnexion",
                    style: TextStyle(color: Colors.red, fontSize: 10),
                  )),
            ],
          ),

          // Logo ou Image de profile
          Image.asset(
            "assets/images/profile.png",
            height: 70,
            width: 70,
          ),

          // message de binevenue
          const Text(
            "Welcome",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
          ),

          // contact de l'utilisateur présentément connecté
          Text(widget.userContact),
          const SizedBox(
            height: 5,
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Les points de marquage d'entrer ou pas d'un chiffre du code PIN
                MPinWidget(
                    pinLegth: 5,
                    controller: mPinController,
                    onCompleted: (mPin) {
                      verifyCodePin(mPin);
                    }),
              ],
            ),
          ),

          // Bouton de code PIN oublié en cas d'une entrée incorrecte
          (forgetPin)
              ? TextButton(
                  onPressed: () {},
                  child: const Text("Code Pin oublié ?",
                      style: TextStyle(color: Colors.black, fontSize: 12)),
                )
              : Container(),

          // Espace entre les Widgets d'en haut et celui du clavier numerique en bas
          const Spacer(),

          // Clavier numérique
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: firstRow.map((e) => buildMaterialButton(e)).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: secondRow.map((e) => buildMaterialButton(e)).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: thirdRow.map((e) => buildMaterialButton(e)).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                onPressed: () {
                  debugPrint("Deverouillage par empreinte");
                },
                textColor: kPrimaryColor,
                child: const Icon(Icons.fingerprint),
              ),
              buildMaterialButton(0),
              MaterialButton(
                onPressed: () {
                  mPinController.delete();
                },
                textColor: kPrimaryColor,
                child: const Icon(Icons.backspace),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  // Widget de construction des bouttons du clavier numérique

  MaterialButton buildMaterialButton(int number) {
    return MaterialButton(
      onPressed: () {
        mPinController.addInput('$number');
      },
      textColor: kPrimaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Text(
          '$number',
          style: const TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
