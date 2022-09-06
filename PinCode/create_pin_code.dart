// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home/home_screen.dart';
import 'components/pin_widget.dart';
import '../../components/constants.dart';
import '../Login/login.dart';

///
///     CreatePinCode
///     -----------
/// Cette page consiste à Permettre à l'utilisateur qui vient de se connecter ou de s'inscrire
/// de créer un code PIN pour acceder à la page d'accueil de l'application
///

// Element de l'interface de code pin
// Image de profile
// Texte de bienvenue
// Contact
// boutton de code pin
// clavier numérique

class CreatePinCode extends StatefulWidget {
  final String userContact;
  const CreatePinCode({Key? key, required this.userContact}) : super(key: key);

  @override
  State<CreatePinCode> createState() => _CreatePinCodeState();
}

class _CreatePinCodeState extends State<CreatePinCode> {
  int pinLenght = 5;
  bool codepinDisMatch = false;
  MPinController mPinController = MPinController();
  List<int> firstRow = [1, 2, 3], secondRow = [4, 5, 6], thirdRow = [7, 8, 9];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: kToolbarHeight,
          ),
          // Logo ou Image de profile
          Image.asset(
            "assets/images/profile.png",
            height: 70,
            width: 70,
          ),

          // message de binevenue
          const Text(
            "Enregistrez un code PIN",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
          ),

          // contact de l'utilisateur présentément connecté
          Text(widget.userContact),
          const SizedBox(height: 5),

          // Point du code PIN
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Les points de marquage d'entrer ou pas d'un chiffre du code PIN
                MPinWidget(
                    pinLegth: 5,
                    controller: mPinController,
                    onCompleted: (code) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SavePinCode(
                              userContact: widget.userContact,
                              codePin: code,
                            ),
                          ));
                    }),
              ],
            ),
          ),

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

///
///       SavePinCode
///       -----------
/// Cette page permet de Confirmer et sauvegarder le code pin
///

class SavePinCode extends StatefulWidget {
  final String codePin;
  final String userContact;
  const SavePinCode(
      {Key? key, required this.codePin, required this.userContact})
      : super(key: key);

  @override
  State<SavePinCode> createState() => _SavePinCodeState();
}

class _SavePinCodeState extends State<SavePinCode> {
  int pinLenght = 5;
  bool codepinDisMatch = false;
  MPinController mPinController = MPinController();
  List<int> firstRow = [1, 2, 3], secondRow = [4, 5, 6], thirdRow = [7, 8, 9];

  // Fonction de chargement de la page d'acceuil après enregistrement du code pin
  goToHomePage(String code) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Hasher le code pin
    var encodePin = utf8.encode(code);
    String pingHash = sha256.convert(encodePin).toString();

    // Stocker dans la memoire de l'appareil
    await pref.setString("pin", pingHash);
    debugPrint("Code Pin : $code / $pingHash");

    // Obtention des données de l'utilisateur enregistrées lors de la connexion ou l'inscription
    String? userDataSaved = pref.getString("user");
    if (userDataSaved != null) {
      var userData = jsonDecode(userDataSaved);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userData: userData),
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [Text("Aucune données, veuillez vous reconnecter")],
      )));
      await pref.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: kToolbarHeight,
          ),

          // Logo ou Image de profile
          Image.asset(
            "assets/images/profile.png",
            height: 70,
            width: 70,
          ),

          // message de binevenue
          const Text(
            "Confirmez votre code PIN",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
          ),

          // contact de l'utilisateur présentément connecté
          Text(widget.userContact),
          const SizedBox(
            height: 5,
          ),

          // Boutton d'entre de code pin
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Les points de marquage d'entrer ou pas d'un chiffre du code PIN
                MPinWidget(
                    pinLegth: 5,
                    controller: mPinController,
                    onCompleted: (codePin) {
                      if (codePin == widget.codePin) {
                        goToHomePage(codePin);
                      } else {
                        // Animation mauvais code PIN
                        mPinController.notifyWrongInput();
                        codepinDisMatch = true;
                        setState(() {});
                      }
                    }),
              ],
            ),
          ),

          // Bouton de code PIN oublié en cas d'une entrée incorrecte
          (codepinDisMatch)
              ? TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreatePinCode(
                                userContact: widget.userContact)));
                  },
                  child: const Text("Recommencer",
                      style: TextStyle(color: kPrimaryColor, fontSize: 12)),
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
