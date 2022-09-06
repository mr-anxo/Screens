// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../components/constants.dart';

class SignUpScreenTopImage extends StatelessWidget {
  const SignUpScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Je veux m'inscrire à instapay",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: defaultPadding / 2),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 2,
              child: SvgPicture.asset(
                "assets/icons/signup.svg",
              ),
            ),
            const Spacer(),
          ],
        ),
        //SizedBox(height: defaultPadding),
      ],
    );
  }
}
