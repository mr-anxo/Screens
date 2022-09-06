import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../../components/constants.dart';

class UserProfil extends StatelessWidget {
  final Map<String, dynamic>? data;
  const UserProfil({Key? key, required this.data}) : super(key: key);

  void changePassword(String userId, oldPassword, newPassword) async {
    print("$userId / $oldPassword / $newPassword");
    try {
      print("Tentative de changement de mot de passe");

      Response response = await post(
          Uri.parse(
              'http://devinstapay.pythonanywhere.com/api/v1/change_password/'),
          body: jsonEncode(<String, String>{
            "user_id": userId,
            "old_password": oldPassword,
            "new_password": newPassword
          }),
          headers: <String, String>{"Content-Type": "application/json"});

      print("Code de la reponse : [${response.statusCode}]");
      print("Contenue de la reponse : ${response.body}");
      //String content = response.body.toString();
      //file.writeAsStringSync(content);

      if (response.statusCode == 200) {
        print("Le changement du mot de passe a été éffectué");
      } else {
        print("le changement de mot de passe a échoué");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController oldPasswordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Mon profile"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                height: 100,
              ),
              Text(
                "Informations personnelles",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 0.9,
                ),
              ),
            ],
          ),
          Divider(),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.person,
                      color: kPrimaryColor,
                      size: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Nom : ",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 0.9,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data!["last_name"],
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    )
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.person,
                      color: kPrimaryColor,
                      size: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Prénoms : ",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 0.9,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data!["first_name"],
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    )
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.numbers,
                      color: kPrimaryColor,
                      size: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Contact : ",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 0.9,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data!["contact"],
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    )
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(
            height: 50,
          ),
          const Text(
            "Changer de mot de passe",
            style: TextStyle(
              color: kWeightBoldColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 2),
            child: TextFormField(
              controller: oldPasswordController,
              textInputAction: TextInputAction.next,
              obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                fillColor: Colors.transparent,
                hintText: "Saisisez le mode passe actuel",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: kWeightBoldColor)),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: defaultPadding, horizontal: defaultPadding * 2),
            child: TextFormField(
              controller: newPasswordController,
              textInputAction: TextInputAction.done,
              //obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                fillColor: Colors.white70,
                hintText: "Saisisez le nouveau mot de passe",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: kWeightBoldColor)),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: defaultPadding, horizontal: defaultPadding * 3),
            child: ElevatedButton(
              onPressed: () {
                print("Hashage du mot de passe");
                var encodeOldPassword = utf8.encode(oldPasswordController.text);
                var encodeNewPassword = utf8.encode(newPasswordController.text);

                String hashOldPassword =
                    sha256.convert(encodeOldPassword).toString();
                String hashNewPassword =
                    sha256.convert(encodeNewPassword).toString();
                print("user ID : ${data!["user_id"]} ");
                print("Old : $hashOldPassword");
                print("new : $hashNewPassword");
                changePassword(
                    data!["user_id"], hashOldPassword, hashNewPassword);
              },
              child: const Text(
                "Valider",
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Instapay, pour des transactions sécurisées"),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
