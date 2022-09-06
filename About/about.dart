import 'package:flutter/material.dart';

import '../../components/constants.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("À propos"),
      ),
      body: Column(
        children: [
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                      "\tInstapay est une application de payement en ligne revolutionnaire, qui reuni plusieurs système de payement bancaire ou non en une seule application. \n\n\tInstapay vous permettra éffectuer des transaction en ligne de façon aisé et sécurisé..."),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                  "Dévéloppé par : \n\n Axel - Ezéchiel - Fabrice - Moïse - Kady - Jordan"),
            ),
          ),
        ],
      ),
    );
  }
}
