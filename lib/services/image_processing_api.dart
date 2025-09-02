import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageProcessingAPI {
  static const String _apiKey = "464d522334a04a748ebc13658ef55c7e_4100130d47e341578391d3d9dcf478b2_andoraitools";
  static const String _baseUrl = "https://api.lightxeditor.com/external/api";
  static const int _maxFileSize = 5242880; // 5MB limit
  static const String _contentType = "image/jpeg"; // Assuming JPEG; adjust if needed

  static Future<Uint8List> loadImageBinary(String filePath) async {
    /// Load an image from a file path and return its binary content.
    ///
    /// Args:
    ///   filePath (String): Path to the local image file
    ///
    /// Returns:
    ///   Uint8List: Binary content of the image
    ///
    /// Throws:
    ///   Exception: If the file cannot be read or is not found
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception("Image file not found: $filePath");
      }
      return await file.readAsBytes();
    } catch (e) {
      throw Exception("Failed to read image file: $e");
    }
  }

  static Future<String> generateBackground(Uint8List imageBinary, String textPrompt) async {
    print('DEBUG API: ===== GENERATE BACKGROUND API START =====');
    print('DEBUG API: Image size: ${imageBinary.length} bytes');
    print('DEBUG API: Text prompt: "$textPrompt"');
    
    /// Generate a background for an image using a binary file and text prompt.
    ///
    /// Args:
    ///   imageBinary (Uint8List): Binary content of the input image
    ///   textPrompt (String): Text prompt describing the desired background
    ///
    /// Returns:
    ///   String: URL of the generated background image
    ///
    /// Throws:
    ///   Exception: If upload or background generation fails
    
    // Validate file size
    if (imageBinary.length > _maxFileSize) {
      print('DEBUG API: ERROR - Image size exceeds limit: ${imageBinary.length} > $_maxFileSize');
      throw Exception("Image size exceeds 5MB limit");
    }
    print('DEBUG API: File size validation passed');

    // Get upload URLs
    final headers = {
      "Content-Type": "application/json",
      "x-api-key": _apiKey,
    };
    print('DEBUG API: Headers prepared');

    final payload = {
      "uploadType": "imageUrl",
      "size": imageBinary.length,
      "contentType": _contentType,
    };
    print('DEBUG API: Upload payload: $payload');

    print('DEBUG API: Making upload URL request...');
    final response = await http.post(
      Uri.parse("$_baseUrl/v2/uploadImageUrl"),
      headers: headers,
      body: jsonEncode(payload),
    );

    print('DEBUG API: Upload URL response status: ${response.statusCode}');
    print('DEBUG API: Upload URL response body: ${response.body}');

    if (response.statusCode != 200) {
      print('DEBUG API: ERROR - Failed to get upload URL');
      throw Exception("Failed to get upload URL: ${response.body}");
    }

    final responseData = jsonDecode(response.body);
    print('DEBUG API: Parsed response data: $responseData');
    
    if (responseData["statusCode"] != 2000) {
      print('DEBUG API: ERROR - API returned error status: ${responseData["statusCode"]}');
      throw Exception("API Error: ${responseData['message']}");
    }

    final uploadUrl = responseData["body"]["uploadImage"];
    final imageUrl = responseData["body"]["imageUrl"];
    print('DEBUG API: Upload URL: $uploadUrl');
    print('DEBUG API: Image URL: $imageUrl');

    // Upload image
    print('DEBUG API: Starting image upload...');
    final uploadResponse = await http.put(
      Uri.parse(uploadUrl),
      headers: {"Content-Type": _contentType},
      body: imageBinary,
    );

    print('DEBUG API: Image upload response status: ${uploadResponse.statusCode}');
    if (uploadResponse.statusCode != 200) {
      print('DEBUG API: ERROR - Image upload failed: ${uploadResponse.body}');
      throw Exception("Image upload failed: ${uploadResponse.body}");
    }
    print('DEBUG API: Image upload successful');

    // Generate background
    final bgPayload = {
      "imageUrl": imageUrl,
      "textPrompt": textPrompt,
    };
    print('DEBUG API: Background generation payload: $bgPayload');

    print('DEBUG API: Making background generation request...');
    final bgResponse = await http.post(
      Uri.parse("$_baseUrl/v1/background-generator"),
      headers: headers,
      body: jsonEncode(bgPayload),
    );

    print('DEBUG API: Background generation response status: ${bgResponse.statusCode}');
    print('DEBUG API: Background generation response body: ${bgResponse.body}');

    if (bgResponse.statusCode != 200) {
      print('DEBUG API: ERROR - Failed to initiate background generation');
      throw Exception("Failed to initiate background generation: ${bgResponse.body}");
    }

    final bgResponseData = jsonDecode(bgResponse.body);
    print('DEBUG API: Parsed background response: $bgResponseData');
    
    if (bgResponseData["statusCode"] != 2000) {
      print('DEBUG API: ERROR - Background generation API error: ${bgResponseData["statusCode"]}');
      throw Exception("API Error: ${bgResponseData['message']}");
    }

    final orderId = bgResponseData["body"]["orderId"];
    final maxRetries = bgResponseData["body"]["maxRetriesAllowed"];
    print('DEBUG API: Order ID: $orderId');
    print('DEBUG API: Max retries: $maxRetries');

    // Poll for status
    print('DEBUG API: Starting status polling...');
    for (var i = 0; i < maxRetries; i++) {
      print('DEBUG API: Polling attempt ${i + 1}/$maxRetries');
      
      final statusResponse = await http.post(
        Uri.parse("$_baseUrl/v1/order-status"),
        headers: headers,
        body: jsonEncode({"orderId": orderId}),
      );

      print('DEBUG API: Status check response: ${statusResponse.statusCode}');
      print('DEBUG API: Status check body: ${statusResponse.body}');

      final statusData = jsonDecode(statusResponse.body);
      if (statusData["statusCode"] != 2000) {
        print('DEBUG API: ERROR - Status check failed: ${statusData["statusCode"]}');
        throw Exception("Status check failed: ${statusData['message']}");
      }

      final status = statusData["body"]?["status"];
      print('DEBUG API: Current status: $status');

      if (statusData["body"] != null && status == "active") {
        final output = statusData["body"]["output"];
        print('DEBUG API: SUCCESS - Background generation complete!');
        print('DEBUG API: Output URL: $output');
        print('DEBUG API: ===== GENERATE BACKGROUND API END =====');
        return output;
      } else if (statusData["body"] != null && status == "failed") {
        print('DEBUG API: ERROR - Background generation failed');
        throw Exception("Background generation failed");
      }

      print('DEBUG API: Status not ready yet, waiting 3 seconds...');
      await Future.delayed(const Duration(seconds: 3));
    }

    print('DEBUG API: ERROR - Background generation timed out');
    throw Exception("Background generation timed out");
  }

  static Future<String> removeBackground(Uint8List imageBinary, {String background = "#00000000"}) async {
    /// Remove background from an image using a binary file.
    ///
    /// Args:
    ///   imageBinary (Uint8List): Binary content of the input image
    ///   background (String): Background setting (color name, color code, or URL)
    ///
    /// Returns:
    ///   String: URL of the background-removed image
    ///
    /// Throws:
    ///   Exception: If upload or background removal fails
    // Validate file size
    if (imageBinary.length > _maxFileSize) {
      throw Exception("Image size exceeds 5MB limit");
    }

    // Get upload URLs
    final headers = {
      "Content-Type": "application/json",
      "x-api-key": _apiKey,
    };

    final payload = {
      "uploadType": "imageUrl",
      "size": imageBinary.length,
      "contentType": _contentType,
    };

    final response = await http.post(
      Uri.parse("$_baseUrl/v2/uploadImageUrl"),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to get upload URL: ${response.body}");
    }

    final responseData = jsonDecode(response.body);
    if (responseData["statusCode"] != 2000) {
      throw Exception("API Error: ${responseData['message']}");
    }

    final uploadUrl = responseData["body"]["uploadImage"];
    final imageUrl = responseData["body"]["imageUrl"];

    // Upload image
    final uploadResponse = await http.put(
      Uri.parse(uploadUrl),
      headers: {"Content-Type": _contentType},
      body: imageBinary,
    );

    if (uploadResponse.statusCode != 200) {
      throw Exception("Image upload failed: ${uploadResponse.body}");
    }

    // Initiate background removal
    final bgPayload = {
      "imageUrl": imageUrl,
      "background": background,
    };

    final bgResponse = await http.post(
      Uri.parse("$_baseUrl/v1/remove-background"),
      headers: headers,
      body: jsonEncode(bgPayload),
    );

    if (bgResponse.statusCode != 200) {
      throw Exception("Failed to initiate background removal: ${bgResponse.body}");
    }

    final bgResponseData = jsonDecode(bgResponse.body);
    if (bgResponseData["statusCode"] != 2000) {
      throw Exception("API Error: ${bgResponseData['message']}");
    }

    final orderId = bgResponseData["body"]["orderId"];
    final maxRetries = bgResponseData["body"]["maxRetriesAllowed"];

    // Poll for status
    for (var i = 0; i < maxRetries; i++) {
      final statusResponse = await http.post(
        Uri.parse("$_baseUrl/v1/order-status"),
        headers: headers,
        body: jsonEncode({"orderId": orderId}),
      );

      final statusData = jsonDecode(statusResponse.body);
      if (statusData["statusCode"] != 2000) {
        throw Exception("Status check failed: ${statusData['message']}");
      }

      if (statusData["body"] != null && statusData["body"]["status"] == "active") {
        return statusData["body"]["output"];
      } else if (statusData["body"] != null && statusData["body"]["status"] == "failed") {
        throw Exception("Background removal failed");
      }

      await Future.delayed(const Duration(seconds: 3));
    }

    throw Exception("Background removal timed out");
  }

static Future<String> removeObject(Uint8List imageBinary, Uint8List maskBinary) async {
    /// Remove an object from an image using a binary image and mask.
    ///
    /// Args:
    ///   imageBinary (Uint8List): Binary content of the input image
    ///   maskBinary (Uint8List): Binary content of the mask image (white for object, black for rest)
    ///
    /// Returns:
    ///   String: URL of the object-removed image
    ///
    /// Throws:
    ///   Exception: If upload or object removal fails
    const int maxRetries = 5;
    const int pollInterval = 3;

    // Validate file sizes
    print('Validating file sizes: imageBinary=${imageBinary.length} bytes, maskBinary=${maskBinary.length} bytes');
    if (imageBinary.length > _maxFileSize || maskBinary.length > _maxFileSize) {
      print('File size validation failed: image or mask exceeds 5MB limit');
      throw Exception("Image or mask size exceeds 5MB limit");
    }

    final headers = {
      "Content-Type": "application/json",
      "x-api-key": _apiKey,
    };
    print('Headers prepared: $headers');

    // Upload main image
    var payload = {
      "uploadType": "imageUrl",
      "size": imageBinary.length,
      "contentType": _contentType,
    };
    print('Uploading main image with payload: $payload');

    var response = await http.post(
      Uri.parse("$_baseUrl/v2/uploadImageUrl"),
      headers: headers,
      body: jsonEncode(payload),
    );
    print('Main image upload response: statusCode=${response.statusCode}, body=${response.body}');

    if (response.statusCode != 200) {
      print('Main image upload failed: ${response.body}');
      throw Exception("Failed to get upload URL for image: ${response.body}");
    }

    var responseData = jsonDecode(response.body);
    print('Main image upload response data: $responseData');
    if (responseData["statusCode"] != 2000) {
      print('Main image API error: ${responseData['message']}');
      throw Exception("API Error: ${responseData['message']}");
    }

    final uploadUrl = responseData["body"]["uploadImage"];
    final imageUrl = responseData["body"]["imageUrl"];
    print('Main image upload URLs: uploadUrl=$uploadUrl, imageUrl=$imageUrl');

    final uploadResponse = await http.put(
      Uri.parse(uploadUrl),
      headers: {"Content-Type": _contentType},
      body: imageBinary,
    );
    print('Main image PUT response: statusCode=${uploadResponse.statusCode}, body=${uploadResponse.body}');

    if (uploadResponse.statusCode != 200) {
      print('Main image PUT failed: ${uploadResponse.body}');
      throw Exception("Image upload failed: ${uploadResponse.body}");
    }

    // Upload mask image
    payload = {
      "uploadType": "imageUrl",
      "size": maskBinary.length,
      "contentType": _contentType,
    };
    print('Uploading mask image with payload: $payload');

    response = await http.post(
      Uri.parse("$_baseUrl/v2/uploadImageUrl"),
      headers: headers,
      body: jsonEncode(payload),
    );
    print('Mask image upload response: statusCode=${response.statusCode}, body=${response.body}');

    if (response.statusCode != 200) {
      print('Mask image upload failed: ${response.body}');
      throw Exception("Failed to get upload URL for mask: ${response.body}");
    }

    responseData = jsonDecode(response.body);
    print('Mask image upload response data: $responseData');
    if (responseData["statusCode"] != 2000) {
      print('Mask image API error: ${responseData['message']}');
      throw Exception("API Error: ${responseData['message']}");
    }

    final maskUploadUrl = responseData["body"]["uploadImage"];
    final maskImageUrl = responseData["body"]["imageUrl"];
    print('Mask image upload URLs: maskUploadUrl=$maskUploadUrl, maskImageUrl=$maskImageUrl');

    final maskUploadResponse = await http.put(
      Uri.parse(maskUploadUrl),
      headers: {"Content-Type": _contentType},
      body: maskBinary,
    );
    print('Mask image PUT response: statusCode=${maskUploadResponse.statusCode}, body=${maskUploadResponse.body}');

    if (maskUploadResponse.statusCode != 200) {
      print('Mask image PUT failed: ${maskUploadResponse.body}');
      throw Exception("Mask upload failed: ${maskUploadResponse.body}");
    }

    // Initiate object removal
    final rmPayload = {
      "imageUrl": imageUrl,
      "maskedImageUrl": maskImageUrl,
    };
    print('Initiating object removal with payload: $rmPayload');

    response = await http.post(
      Uri.parse("$_baseUrl/v1/cleanup-picture"),
      headers: headers,
      body: jsonEncode(rmPayload),
    );
    print('Object removal response: statusCode=${response.statusCode}, body=${response.body}');

    if (response.statusCode != 200) {
      print('Object removal initiation failed: ${response.body}');
      throw Exception("Failed to initiate object removal: ${response.body}");
    }

    responseData = jsonDecode(response.body);
    print('Object removal response data: $responseData');
    if (responseData["statusCode"] != 2000) {
      print('Object removal API error: ${responseData['message']}');
      throw Exception("API Error: ${responseData['message']}");
    }

    final orderId = responseData["body"]["orderId"];
    print('Object removal orderId: $orderId');

    // Poll for status
    for (var i = 0; i < maxRetries; i++) {
      print('Polling status attempt ${i + 1}/$maxRetries for orderId: $orderId');
      final statusResponse = await http.post(
        Uri.parse("$_baseUrl/v1/order-status"),
        headers: headers,
        body: jsonEncode({"orderId": orderId}),
      );
      print('Status response: statusCode=${statusResponse.statusCode}, body=${statusResponse.body}');

      final statusData = jsonDecode(statusResponse.body);
      print('Status response data: $statusData');
      if (statusData["statusCode"] != 2000) {
        print('Status check failed: ${statusData['message']}');
        throw Exception("Status check failed: ${statusData['message']}");
      }

      if (statusData["body"] != null && statusData["body"]["status"] == "active") {
        print('Object removal successful, output URL: ${statusData["body"]["output"]}');
        return statusData["body"]["output"];
      } else if (statusData["body"] != null && statusData["body"]["status"] == "failed") {
        print('Object removal failed: status=failed');
        throw Exception("Object removal failed");
      }

      print('Waiting $pollInterval seconds before next status check');
      await Future.delayed(const Duration(seconds: pollInterval));
    }

    print('Object removal timed out after $maxRetries attempts');
    throw Exception("Object removal timed out");
  }
  /// Download image from URL and return as Uint8List
  static Future<Uint8List> downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception("Failed to download image: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to download image: $e");
    }
  }
}
