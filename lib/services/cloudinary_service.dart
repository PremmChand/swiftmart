import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String?> uploadToCloudinary(File file) async {
  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  if (cloudName.isEmpty || uploadPreset.isEmpty) {
    print("Cloudinary credentials not set.");
    return null;
  }

  var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
  var request = http.MultipartRequest("POST", uri);

  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  request.fields['upload_preset'] = uploadPreset;

  var response = await request.send();
  var responseBody = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    final data = json.decode(responseBody);
    return data['secure_url']; // ✅ Cloudinary image URL
  } else {
    print("Upload failed: $responseBody");
    return null;
  }
}



// Future<bool> uploadToCloudinary(FilePickerResult? filePickerResult) async {
//   if (filePickerResult == null || filePickerResult.files.isEmpty) {
//     print("No file selected");
//     return false;
//   }

//   File file = File(filePickerResult.files.single.path!);

//   String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
//   String upload_preset_data = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
//   //curl https://api.cloudinary.com/v1_1/<CLOUD_NAME>/image/upload -X POST --data 'file=<FILE>&timestamp=<TIMESTAMP>&api_key=<API_KEY>&signature=<SIGNATURE>'
//   var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");
//   var request = http.MultipartRequest("POST", uri);

//   var fileBytes = await file.readAsBytes();

//   var multipartFile = http.MultipartFile.fromBytes(
//     'file',
//     fileBytes,
//     filename: file.path.split("/").last,
//   );

//   // add the file part to the request
//   request.files.add(multipartFile);
//   request.fields['upload_preset'] = "upload_preset_data";
//   request.fields['resource_type'] = "raw";

//   // send request and await the response
//   var response = await request.send();

//   // get the response as text

//   var responseBody = await response.stream.bytesToString();

//   print(responseBody);

//   if (response.statusCode == 200) {
//     print("Upload successful!");
//     return true;
//   }else{
//     print("Upload failed with status: ${response.statusCode}");
//     return false;
//   }
// }
