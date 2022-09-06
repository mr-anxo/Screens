// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:email_validator/email_validator.dart';
import 'package:instapay/Screens/PinCode/create_pin_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/constants.dart';

///
///     LoginForm
///     ---------
/// Dans ce Widget est contruit le formulaire de connexion
///

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
    required this.isLogin,
    required this.animationDuration,
    required this.size,
    required this.defaultLoginSize,
  }) : super(key: key);

  final bool isLogin;
  final Duration animationDuration;
  final Size size;
  final double defaultLoginSize;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();
  bool obscuretext = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Fonction de traitement de la connexion au serveur
  void signIn() async {
    debugPrint("Exécution de la fonction de connexion ");

    // Verifier que tous les champs sont remplis avant d'entreprendre quoique ce soit
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      //hasher le mot de passe avant de l'enoyer à l'api
      debugPrint("Hashage du mot de passe");
      var encodePassword = utf8.encode(passwordController.text);
      String passwordHashed = sha256.convert(encodePassword).toString();
      debugPrint(passwordHashed);

      try {
        debugPrint("Tentative de connexion");
        Response response = await post(Uri.parse('${api}login/'),
            body: jsonEncode(<String, String>{
              "contact": emailController.text,
              "password": passwordHashed
            }),
            headers: <String, String>{"Content-Type": "application/json"});

        debugPrint("requete de connexion envoyée");
        debugPrint("Code de la reponse : [${response.statusCode}]");
        debugPrint("Contenue de la reponse : ${response.body}");

        if (response.statusCode == 200) {
          debugPrint("La connexion à été éffectué");
          loadHomePage(response.body.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Connexion échouée [Code http : ${response.statusCode} ]")
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
        children: const [Text("Remplissez tous les champs")],
      )));
    }
  }

  // Fonction de chargement de la page de connexion
  void loadHomePage(String jsonData) async {
    debugPrint(" Chargement de la page d'accueil");

    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("user", jsonData);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreatePinCode(
                  userContact: jsonDecode(jsonData)['contact'],
                )));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isLogin ? 1.0 : 0.0,
      duration: widget.animationDuration * 4,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: widget.size.width,
          height: widget.defaultLoginSize,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: mediumPadding,
                ),

                // Texte de bienvenue
                const Text(
                  'Bienvenue sur InstaPay',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 40),

                // Image de connexion
                Row(
                  children: [
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: SvgPicture.asset(
                        "assets/icons/login.svg",
                        height: 150,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: bigMediumPadding * 2),

                // Fonrmulaire de connexion
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      // Champ Email
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: mediumPadding),
                        child: TextFormField(
                          controller: emailController,
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.mail_outline),
                            hintText: "Email",
                          ),
                          validator: (email) {
                            return email != null &&
                                    !EmailValidator.validate(email)
                                ? "Entrez un email valide"
                                : null;
                          },
                        ),
                      ),

                      // Champ mot de passe
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: mediumPadding,
                            vertical: defaultPadding),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: obscuretext,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            // Afficer ou cacher le mot de passe
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  obscuretext = !obscuretext;
                                });
                              },
                              child: Icon(obscuretext
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                            hintText: "Mot d epasse",
                          ),
                          validator: (value) {
                            if (value != null && value.length < 8) {
                              return "Mot de passe trop court";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(
                        height: mediumPadding,
                      ),

                      // Boutton de connexion
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: mediumPadding,
                        ),
                        child: SizedBox(
                          height: 60,
                          width: 200,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(),
                              onPressed: () {
                                final isValidForm =
                                    formKey.currentState!.validate();
                                if (isValidForm) {
                                  debugPrint(
                                      "Connexion de l'utilisateur : [${emailController.text} / ${passwordController.text}");
                                  signIn();
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                          "Vos informations ne sont pas valides")
                                    ],
                                  )));
                                }
                              },
                              child: Text("Se connecteer".toUpperCase())),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
