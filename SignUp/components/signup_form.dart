// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:instapay/Screens/Welcome/welcome_screen.dart';
//import 'package:instapay/Screens/PinCode/save_pin_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../components/constants.dart';
import '../../Login/login.dart';
//import '../../Home/home_screen.dart';

class SignUpForm extends StatefulWidget {
  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final int pageIndex = 0;

  ///
  ///     FONCTION D'INSCRIPTION
  ///

  void signUp() async {
    debugPrint("Exécution de la fonction d'inscription ");

    // VERIFIER QUE TOUS LES CHAMPS SONT REMPLIS
    if (userNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty) {
      // VERIFIER SI LES MOTS DE PASS CORRESPONDENT
      if (passwordController.text == confirmPasswordController.text) {
        //hasher le mot de passe avant de l'enoyer à l'api
        debugPrint("Hashage du mot de passe");
        var encodePassword = utf8.encode(passwordController.text);
        String passwordHashed = sha256.convert(encodePassword).toString();

        try {
          debugPrint("Tentative d'inscription");
          Response response = await post(Uri.parse('${api}signup/'),
              body: jsonEncode(<String, String>{
                "first_name": userNameController.text,
                "last_name": userNameController.text,
                "contact": emailController.text,
                "password": passwordHashed
              }),
              headers: <String, String>{"Content-Type": "application/json"});

          debugPrint("requete d'inscription envoyée");
          debugPrint("Code de la reponse : [${response.statusCode}]");
          debugPrint("Contenue de la reponse : ${response.body}");

          if (response.statusCode == 200) {
            debugPrint("L'inscription à été éffectué");
            loadHomePage(response.body.toString());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "Inscription échouée [Code http : ${response.statusCode} ]")
              ],
            )));
          }
        } catch (e) {
          debugPrint("Une erreur est survenue : \n $e");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text("Mot de pass différents")],
        )));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [Text("Remplissez tous les champs")],
      )));
    }
  }

  void loadHomePage(String jsonData) async {
    debugPrint(" Chargement de la page d'accueil");

    SharedPreferences pref = await SharedPreferences.getInstance();

    var userData = jsonDecode(jsonData)['data'][0];
    String userDataToSave = jsonEncode(userData);
    await pref.setString("user", userDataToSave);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const /*SavePinCode*/ WelcomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          buildTextFormField(userNameController, "Nom et Prénoms", false,
              Icons.person, TextInputType.text),
          const SizedBox(
            height: defaultPadding / 2,
          ),
          buildTextFormField(emailController, "Email", false, Icons.email,
              TextInputType.emailAddress),
          const SizedBox(
            height: defaultPadding / 2,
          ),
          buildTextFormField(passwordController, "Mot de passe", true,
              Icons.lock, TextInputType.text),
          const SizedBox(
            height: defaultPadding / 2,
          ),
          buildTextFormField(
              confirmPasswordController,
              "Confirmation du mot de passe",
              true,
              Icons.lock,
              TextInputType.text),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: () {
              signUp();
            },
            child: Text("Inscription".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding / 2),
          AlreadyHaveAnAccountCheck(
            login: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildTextFormField(TextEditingController controller, String hintText,
          bool obscurText, IconData icon, TextInputType textInputType) =>
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        obscureText: obscurText,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Icon(icon),
          ),
        ),
      );
}
