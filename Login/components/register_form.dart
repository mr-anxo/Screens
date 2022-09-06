// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Screens/PinCode/create_pin_code.dart';
import '../../../components/constants.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
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
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final formKey = GlobalKey<FormState>();
  bool obscuretext = true;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final int pageIndex = 0;

  // Fonction d'inscription d'un utilisateur
  void signUp() async {
    debugPrint("Exécution de la fonction d'inscription ");

    // Verifier que tous les champs sont remplis
    if (fullNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty) {
      // Verifier que les mots de passes correspondent
      if (passwordController.text == confirmPasswordController.text) {
        //hasher le mot de passe avant de l'enoyer à l'api
        debugPrint("Hashage du mot de passe");
        var encodePassword = utf8.encode(passwordController.text);
        String passwordHashed = sha256.convert(encodePassword).toString();

        try {
          debugPrint("Tentative d'inscription");
          Response response = await post(Uri.parse('${api}signup/'),
              body: jsonEncode(<String, String>{
                "first_name": fullNameController.text,
                "last_name": fullNameController.text,
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

    Map<String, dynamic> jsonResponse = jsonDecode(jsonData);
    Map<String, dynamic> userData = jsonResponse['data'][0];

    String userDataToSave = jsonEncode(userData);
    await pref.setString("user", userDataToSave);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreatePinCode(
                  userContact: userData['contact'],
                )));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isLogin ? 0.0 : 1.0,
      duration: widget.animationDuration * 5,
      child: Visibility(
        visible: !widget.isLogin,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: widget.size.width,
            height: widget.defaultLoginSize,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: defaultPadding),

                  // texte de bienvenue
                  const Text(
                    'Inscrivez-vous',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(
                    height: defaultPadding,
                  ),

                  // Image d'inscription
                  Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        flex: 4,
                        child: SvgPicture.asset(
                          "assets/images/register.svg",
                          height: 150,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: bigMediumPadding),

                  // formulaire d'inscription
                  Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        // Entree du nom d'utilisateur
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: mediumPadding,
                              vertical: defaultPadding / 2),
                          child: TextFormField(
                            controller: fullNameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: "Nom complet",
                            ),
                            validator: (fullname) {
                              if (fullname != null && fullname.length < 5) {
                                return "Nom complet trop court";
                              }
                            },
                          ),
                        ),

                        // Entree du contact
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: mediumPadding,
                              vertical: defaultPadding / 2),
                          child: TextFormField(
                            controller: emailController,
                            obscureText: false,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.mail),
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

                        // Entree du mot de passe
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: mediumPadding,
                              vertical: defaultPadding / 2),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: obscuretext,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.password),
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

                        // Confirmation du mot de passe
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: mediumPadding,
                              vertical: defaultPadding / 2),
                          child: TextFormField(
                            controller: confirmPasswordController,
                            obscureText: obscuretext,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.password),
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
                        const SizedBox(height: mediumPadding),

                        // Boutton inscripton
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: mediumPadding),
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
                                        "Inscription de l'utilisateur : [${emailController.text} / ${passwordController.text}");
                                    signUp();
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                            "Vos informations ne sont pas valides")
                                      ],
                                    )));
                                  }
                                },
                                child: Text("S'inscrire".toUpperCase())),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
