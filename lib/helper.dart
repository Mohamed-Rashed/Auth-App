import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:untitled5/main.dart';

void showMessage(String text,BuildContext context) {
  var alert = AlertDialog(content: Text(text), actions: <Widget>[
    TextButton(
        child: const Text('Ok'),
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        })
  ]);
  showDialog(context: context, builder: (BuildContext context) => alert);
}

void showSnackBar(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

 final Config config = Config(
  tenant: '',
  clientId: '',
  scope: '',
  clientSecret: "",
  navigatorKey: navigatorKey,
  loader: SizedBox(),
  domainHint:"consumers",

);

final AadOAuth oauth = AadOAuth(config);