import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show Color, rootBundle;
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
  final String response = await rootBundle.loadString('assets/passes/pass.json');
  final data = await json.decode(response);
  final xxx = PasskitPass.fromJson(data);
  final passkitGenerated = await FlutterWalletCard.generatePass(
    id: 'digitalIDPasss',
    pass: xxx, // class instance
    signature: writtenSignature,
    manifest: writtenManifest,

    iconImage: PasskitImage(image:writtenIcon, image2x:writtenIcon2x),
    backgroundImage: PasskitImage(image:writtenBackground, image2x:writtenBackground2x),
    logoImage: PasskitImage(image:writtenLogo, image2x:writtenLogo2x),
    thumbnailImage: PasskitImage(image:writtenThumbnail, image2x:writtenThumbnail2x),

  );

  final passkitFile = passkitGenerated.passkitFile;
  print("kkkkk ${passkitFile.file.path}");
  final x = await FlutterWalletCard.addPasskit(passkitFile);
  print("kkkkk ${x}");
}


/*Future<void> generateWalletPass() async {
  // Load the pass.json file from the assets
  final passJson = await rootBundle.loadString('assets/pass.json');

  // Load other assets if necessary (like images)
  final icon = await rootBundle.load('assets/icon.png');
  final logo = await rootBundle.load('assets/logo.png');

  // Create the WalletPass object using the flutter_wallet_card package
  final walletPass = WalletPass.fromJson(passJson);

  // Add images and other necessary assets
  walletPass.icon = icon.buffer.asUint8List();
  walletPass.logo = logo.buffer.asUint8List();

  // Optionally, you can sign the pass if needed using a certificate (usually required for production)
  // walletPass.sign(passTypeId, teamId, certificatePath, certificatePassword);

  // Save the .pkpass file to the device's file system
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/pass.pkpass';
  final passFile = File(filePath);
  await passFile.writeAsBytes(walletPass.toPkPass());

  print('Wallet pass generated and saved to $filePath');
}*/

Future<void> createPkpass() async {
  final assetDirectoryPath = 'assets';
  final pass = <String, String>{};
  final encoder = ZipEncoder();
  final archive = Archive();

  final files = [
    'pass.json',
    'background.png',
    'background@2x.png',
    'icon.png',
    'icon@2x.png',
    'logo.png',
    'logo@2x.png',
    'thumbnail.png',
    'thumbnail@2x.png'
    // Add other file names as needed
  ];


  for (var fileName in files) {
    // Load the file from assets
    final fileBytes = await rootBundle.load('$assetDirectoryPath/$fileName');
    archive.addFile(ArchiveFile(fileName, fileBytes.elementSizeInBytes, fileBytes));
  }
  final directory = await getApplicationDocumentsDirectory();

  final zipData = encoder.encode(archive);
  final pkpassFile = File('${directory.path}/test.pkpass');
  await pkpassFile.writeAsBytes(zipData!);
  print('Pass generated successfully at: ${pkpassFile.path}');
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
  appLaunchURL: "ewewewewewe",
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
);
