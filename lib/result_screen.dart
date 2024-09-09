import 'dart:io';

import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'package:add_to_wallet/widgets/add_to_wallet_button.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:microsoft_graph_api/models/user/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled5/helper.dart';
import 'package:untitled5/pass.dart';
import 'package:untitled5/pass_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

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
    //generatePkPass();
    initPlatformState();
   // generateWalletPassFromPath();
   // createPkpass();
    //modifyPrimaryFieldLabel();
  }

  Future<void> modifyPrimaryFieldLabel() async {
    try {
      // Load the JSON file from assets
      String fileContent = await rootBundle.loadString('assets/passes/pass.json');

      // Parse the JSON content into a Dart Map
      Map<String, dynamic> jsonData = jsonDecode(fileContent);

      // Modify the label of primaryFields[0]
      jsonData['generic']['primaryFields'][0]['label'] = widget.userInfo.jobTitle;
      jsonData['generic']['primaryFields'][0]['value'] = widget.userInfo.displayName;
      jsonData['generic']['secondaryFields'][0]['value'] = widget.userInfo.mail;
      jsonData['generic']['auxiliaryFields'][1]['value'] = widget.userInfo.mobilePhone;
      jsonData['generic']['auxiliaryFields'][0]['value'] = widget.userInfo.businessPhones ?? "";
      jsonData['generic']['backFields'][0]['value'] = widget.userInfo.displayName ?? "";
      jsonData['generic']['backFields'][1]['value'] = widget.userInfo.jobTitle ?? "";
      jsonData['generic']['backFields'][2]['value'] =
          "(KSA): ${widget.userInfo.businessPhones}\r\n(EGY): ${widget.userInfo.mobilePhone}";

      jsonData['generic']['backFields'][3]['value'] = widget.userInfo.mail;

      // Convert the updated data back to JSON
      String updatedJsonContent = jsonEncode(jsonData);

      // Save the updated JSON content to the app's local directory (as assets are read-only)
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/updated_pass.json';
      final file = File(filePath);

      await file.writeAsString(updatedJsonContent);

      print("Successfully updated and saved the file at $filePath.");
      //computeAssetSHA1(filePath);
      generateManifest(passPath : filePath);

    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> generateManifest({required String passPath}) async {
    final assetDirectoryPath = 'assets/passes';

    // Get the list of files in the assets/passes directory
    final manifest = <String, String>{};
    // List of files to include in the manifest
    final fileNames = [
      'pass.json',
      'background.png',
      'background@2x.png',
      'icon.png',
      'icon@2x.png',
      'logo.png',
      'logo@2x.png',
      'thumbnail.png',
      'thumbnail@2x.png',
      // Add other filenames as needed
    ];
    ByteData? fileBytes;
    for (var fileName in fileNames) {
      if(fileName == 'pass.json'){
        fileBytes = await rootBundle.load('$passPath');
      }else{
        fileBytes = await rootBundle.load('$assetDirectoryPath/$fileName');
      }
      // Load the file from assets
      // Calculate the SHA-1 hash of the file
      final sha1Hash = sha1.convert(fileBytes.buffer.asUint8List()).toString();

      // Add the hash to the manifest
      manifest[fileName] = sha1Hash;
    }

    // Convert the manifest to a JSON string
    final manifestJson = jsonEncode(manifest);

    // Write the manifest.json file to the local filesystem
    // Get the local documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Write the manifest.json file to the local documents directory
    final manifestFile = File('${directory.path}/manifest.json');
    await manifestFile.writeAsString(manifestJson, flush: true);

    print("kkkkkkkk ${manifestJson}");
    //API();

    print('manifest.json generated successfully in ${directory.path}.');
  }

  Future<File> generatePkPass() async {
    // Load the files from the assets
    final manifestJson = await rootBundle.load('assets/passes/manifest.json');
    final signatureJson = await rootBundle.load('assets/passes/signature');
    final passJson = await rootBundle.load('assets/passes/pass.json');
    final backgroundPng = await rootBundle.load('assets/passes/background.png');
    final background2Png = await rootBundle.load('assets/passes/background@2x.png');
    final iconPng = await rootBundle.load('assets/passes/icon.png');
    final icon2Png = await rootBundle.load('assets/passes/icon@2x.png');
    final logoPng = await rootBundle.load('assets/passes/logo.png');
    final logo2Png = await rootBundle.load('assets/passes/logo@2x.png');
    final thumbnailPng = await rootBundle.load('assets/passes/thumbnail.png');
    final thumbnail2Png = await rootBundle.load('assets/passes/thumbnail@2x.png');

    // Create an archive and add the files
    final archive = Archive()`1
      ..addFile(ArchiveFile('manifest.json', manifestJson.lengthInBytes, manifestJson.buffer.asUint8List()))
      ..addFile(ArchiveFile('signature', signatureJson.lengthInBytes, signatureJson.buffer.asUint8List()))
      ..addFile(ArchiveFile('pass.json', passJson.lengthInBytes, passJson.buffer.asUint8List()))
      ..addFile(ArchiveFile('background.png', backgroundPng.lengthInBytes, backgroundPng.buffer.asUint8List()))
      ..addFile(ArchiveFile('background@2x.png', background2Png.lengthInBytes, background2Png.buffer.asUint8List()))
      ..addFile(ArchiveFile('icon.png', iconPng.lengthInBytes, iconPng.buffer.asUint8List()))
      ..addFile(ArchiveFile('icon@2x.png', icon2Png.lengthInBytes, icon2Png.buffer.asUint8List()))
      ..addFile(ArchiveFile('logo.png', logoPng.lengthInBytes, logoPng.buffer.asUint8List()))
      ..addFile(ArchiveFile('logo@2x.png', logo2Png.lengthInBytes, logo2Png.buffer.asUint8List()))
      ..addFile(ArchiveFile('thumbnail.png', thumbnailPng.lengthInBytes, thumbnailPng.buffer.asUint8List()))
      ..addFile(ArchiveFile('thumbnail@2x.png', thumbnail2Png.lengthInBytes, thumbnail2Png.buffer.asUint8List()));

    // Encode the archive as a .zip file
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);

    // Get the temporary directory to save the .pkpass file
    final tempDir = await getTemporaryDirectory();
    final pkpassFile = File('${tempDir.path}/pass.pkpass');

    // Write the zip data to the file
    await pkpassFile.writeAsBytes(zipData!);
    print("kkkkk ${pkpassFile.path}");

    initPlatformState();

    return pkpassFile;
  }

  Future<String> computeAssetSHA1(String assetPath) async {
    // Load the asset data as bytes
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();

    // Compute the SHA-1 hash
    final digest = sha1.convert(bytes);
    print("pass.json SHA-1 : $digest");
    return digest.toString();
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
            margin: const EdgeInsets.only(
                left: 30, top: 100, right: 30, bottom: 70),
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
          if (_passLoaded)
            AddToWalletButton(
              pkPass: _pkPassData,
              width: 150,
              height: 30,
              unsupportedPlatformChild: DownloadPass(pkPass: _pkPassData),
              onPressed: () {
                print("🎊Add to Wallet button Pressed!🎊");
              },
            ),
          // InkWell(
          //   onTap: () {
          //     generateWalletPassFromPath();
          //   },
          //   child: Container(
          //     height: 50,
          //     width: 200,
          //     decoration: BoxDecoration(
          //       color: Colors.red,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: const Center(
          //       child: Text(
          //         "Add To Apple Wallet",
          //         style: TextStyle(color: Colors.white, fontSize: 15),
          //       ),
          //     ),
          //   ),
          // ),
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
    print(
        "The button was pressed, we could let the user download the pass for instance!");
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
