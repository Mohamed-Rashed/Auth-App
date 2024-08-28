import 'dart:io';

import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'package:add_to_wallet/widgets/add_to_wallet_button.dart';
import 'package:flutter/material.dart';
import 'package:microsoft_graph_api/models/user/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled5/helper.dart';
import 'package:untitled5/pass.dart';
import 'package:untitled5/pass_provider.dart';
import 'package:uuid/uuid.dart';

final String _passId = const Uuid().v4();
const String _passClass = '1234567890';
const String _issuerId = '3388000000022293749';
const String _issuerEmail = 'mohamedrashed88@gmail.com';

class ResultScreen extends StatefulWidget {
  final User userInfo;

  const ResultScreen({super.key, required this.userInfo});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _passLoaded = false;
  List<int> _pkPassData = [];
  @override
  void initState() {
    super.initState();
    //initPlatformState();
  }

  Future<void> initPlatformState() async {
    final pass = await passProvider();

    if (!mounted) return;

    setState(() {
      _pkPassData = pass;
      _passLoaded = true;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 30, top: 100, right: 30, bottom: 70),
            height: 350,
            width: 400,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Display Name : ${widget.userInfo.displayName ?? ""}",
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "job Title : ${widget.userInfo.jobTitle ?? ""}",
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "email : ${widget.userInfo.mail ?? ""}",
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "mobile Phone : ${widget.userInfo.mobilePhone ?? ""}",
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "surname : ${widget.userInfo.surname ?? ""}",
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "given Name : ${widget.userInfo.givenName ?? ""}",
                ),
              ],
            ),
          ),
          AddToGoogleWalletButton(
            pass: """ 
    {
      "iss": "$_issuerEmail",
      "aud": "google",
      "typ": "savetowallet",
      "origins": [],
      "payload": {
        "genericObjects": [
          {
            "id": "$_issuerId.$_passId",
            "classId": "$_issuerId.$_passClass",
            "genericType": "GENERIC_TYPE_UNSPECIFIED",
            "hexBackgroundColor": "#4285f4",
            "logo": {
              "sourceUri": {
                "uri": "https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/pass_google_logo.jpg"
              }
            },
            "cardTitle": {
              "defaultValue": {
                "language": "en",
                "value": "Ejada Business Card"
              }
            },
            "subheader": {
              "defaultValue": {
                "language": "en",
                "value": "${widget.userInfo.jobTitle}"
              }
            },
            "header": {
              "defaultValue": {
                "language": "en",
                "value": "${widget.userInfo.surname}"
              }
            },
            "barcode": {
              "type": "QR_CODE",
              "value": "$_passId"
            },
            "heroImage": {
              "sourceUri": {
                "uri": "https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/google-io-hero-demo-only.jpg"
              }
            },
            "textModulesData": [
              {
                "header": "POINTS",
                "body": "1234",
                "id": "points"
              }
            ]
          }
        ]
      }
    }
""",
            onSuccess: () => showSnackBar(context, 'Success!'),
            onCanceled: () => showSnackBar(context, 'Action canceled.'),
            onError: (Object error) {
              print("kkkk ${error.toString()}");
              showSnackBar(context, error.toString());
            },
            locale: const Locale.fromSubtags(
              languageCode: 'en',
              countryCode: 'EN',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              generateWalletPassFromPath();
            },
            child: Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Add To Apple Wallet",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              logout();
            },
            child: Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "LogOut",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void logout() async {
    //await FirebaseAuth.instance.signOut();
    await oauth.logout();
    showMessage('Logged out', context);
  }
}
class DownloadPass extends StatelessWidget {
  final List<int> pkPass;

  const DownloadPass({Key? key, required this.pkPass}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: _onPressed, child: Text('🧷 pkpass'));
  }

  void _onPressed() async {
    print("The button was pressed, we could let the user download the pass for instance!");
    File passFile = await writePassFile();
    Share.shareFiles([passFile.path], text: "Here is your pkPass!");
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localPassFile async {
    final path = await _localPath;
    return File('$path/pass.pkpass');
  }

  Future<File> writePassFile() async {
    final file = await _localPassFile;
    return file.writeAsBytes(pkPass);
  }
}
