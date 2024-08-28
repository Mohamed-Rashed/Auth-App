import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_wallet_card/core/passkit.dart';
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card/models/PasskitBarcode.dart';
import 'package:flutter_wallet_card/models/PasskitField.dart';
import 'package:flutter_wallet_card/models/PasskitImage.dart';
import 'package:flutter_wallet_card/models/PasskitLocation.dart';
import 'package:flutter_wallet_card/models/PasskitPass.dart';
import 'package:flutter_wallet_card/models/PasskitStructure.dart';
import 'package:path_provider/path_provider.dart';

void generateWalletPassFromPath() async {

  final directory = await getTemporaryDirectory();


  final fileManifest = File('${directory.path}/manifest.json');
  final examplePassManifest = await rootBundle.load('assets/passes/manifest.json');
  final writtenManifest = await fileManifest.writeAsBytes(examplePassManifest.buffer.asUint8List());
  print("writtenManifest : " + writtenManifest.toString());




  final fileSignature = File('${directory.path}/signature');
  final examplePassSignature = await rootBundle.load('assets/passes/signature');
  final writtenSignature = await fileSignature.writeAsBytes(examplePassSignature.buffer.asUint8List());

  final fileIcon = File('${directory.path}/icon.png');
  final examplePassIcon = await rootBundle.load('assets/passes/icon.png');
  final writtenIcon = await fileIcon.writeAsBytes(examplePassIcon.buffer.asUint8List());

  final fileIcon2x = File('${directory.path}/icon@2x.png');
  final examplePassIcon2x = await rootBundle.load('assets/passes/icon@2x.png');
  final writtenIcon2x = await fileIcon2x.writeAsBytes(examplePassIcon2x.buffer.asUint8List());

  final fileBackground = File('${directory.path}/background.png');
  final examplePassBackground = await rootBundle.load('assets/passes/background.png');
  final writtenBackground = await fileBackground.writeAsBytes(examplePassBackground.buffer.asUint8List());

  final fileBackground2x = File('${directory.path}/background@2x.png');
  final examplePassBackground2x = await rootBundle.load('assets/passes/background@2x.png');
  final writtenBackground2x = await fileBackground2x.writeAsBytes(examplePassBackground2x.buffer.asUint8List());

  final fileLogo = File('${directory.path}/logo.png');
  final examplePassLogo = await rootBundle.load('assets/passes/logo.png');
  final writtenLogo = await fileLogo.writeAsBytes(examplePassLogo.buffer.asUint8List());

  final fileLogo2x = File('${directory.path}/logo@2x.png');
  final examplePassLogo2x = await rootBundle.load('assets/passes/logo@2x.png');
  final writtenLogo2x = await fileLogo2x.writeAsBytes(examplePassLogo2x.buffer.asUint8List());


  final fileThumbnail = File('${directory.path}/thumbnail.png');
  final examplePassThumbnail = await rootBundle.load('assets/passes/thumbnail.png');
  final writtenThumbnail = await fileThumbnail.writeAsBytes(examplePassThumbnail.buffer.asUint8List());

  final fileThumbnail2x = File('${directory.path}/thumbnail@2x.png');
  final examplePassThumbnail2x = await rootBundle.load('assets/passes/thumbnail@2x.png');
  final writtenThumbnail2x = await fileThumbnail2x.writeAsBytes(examplePassThumbnail2x.buffer.asUint8List());

  final passkitGenerated = await FlutterWalletCard.generatePass(
    id: 'digitalIDPasss',
    pass: examplePass, // class instance
    signature: writtenSignature,
    manifest: writtenManifest,

    iconImage: PasskitImage(image:writtenIcon, image2x:writtenIcon2x),
    backgroundImage: PasskitImage(image:writtenBackground, image2x:writtenBackground2x),
    logoImage: PasskitImage(image:writtenLogo, image2x:writtenLogo2x),
    thumbnailImage: PasskitImage(image:writtenThumbnail, image2x:writtenThumbnail2x),

  );
  final passkitFile = passkitGenerated.passkitFile;
  print("passkitFile ----- ${passkitFile}");
  await FlutterWalletCard.addPasskit(passkitFile);

}

//
final examplePass = PasskitPass(
  description : "Apple Event Ticket",
  formatVersion : 1,
  organizationName : "Apple Inc.",
  passTypeIdentifier : "pass.sa.gov.fg.testPass",
  serialNumber : "nmyuxofgna",
  teamIdentifier : "YVY69NAPU2",
  webServiceURL : "https://example.com/passes/",
  authenticationToken : "vxwxd7J8AlNNFPS8k0a0FfUFtq0ewzFdc",
  barcodes: [
    PasskitBarcode(
        message: "123456789",
        format: "PKBarcodeFormatPDF417",
        messageEncoding: "iso-8859-1"
    )
  ],
  backgroundColor : Color.fromRGBO(60, 65, 76, 1),
  foregroundColor : Color.fromRGBO(255, 255, 255, 1),
  labelColor: Color.fromRGBO(255, 255, 255, 1),
  logoText: "Ejada Company",
  eventTicket: PasskitStructure(
    primaryFields: [
      PasskitField(
        key: 'event',
        label: 'EVENT',
        value: 'The Beat Goes On',
      )
    ],
    secondaryFields: [
      PasskitField(
          key: 'loc',
          label: 'LOCATION',
          value: 'Tessssst Moscone West'
      )
    ],
    headerFields: [
      PasskitField(
        key: 'staffNumber',
        value: '001',
        label: 'Staff Number',
      )
    ],
  ),
  locations : [
    PasskitLocation(
        longitude : -122.3748889,
        latitude : 37.6189722
    ),
    PasskitLocation(
        longitude : -122.03118,
        latitude : 37.33182
    ),
  ],
  relevantDate : "2026-12-08T13:00-08:00",
);
