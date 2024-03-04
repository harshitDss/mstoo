import 'dart:convert';
import 'dart:io';

import 'package:mstoo/user/core/core_export.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CallApi{

  final String _url = AppConstants.baseUrl;

  login(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setHeaders()
    );
  }

  resetPassword(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setHeaders()
    );
  }

  postData(token, data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
  }

  deleteData(token,data, apiUrl, id) async {
    var fullUrl = _url + apiUrl;
    return await http.delete(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
  }

  getUser(token, apiUrl, id ) async {
     String fullUrl = _url + apiUrl + id;
    // print(fullUrl);
    
    // var fullUrl = "https://wow.design-street.com.au/api/edit_driver/25";
    return await http.post(
      Uri.parse(fullUrl),
      // body: jsonEncode(data),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
  }

  deleteUser(token, apiUrl, id ) async {
     String fullUrl = _url + apiUrl + id;
    // print(fullUrl);
    
    // var fullUrl = "https://wow.design-street.com.au/api/edit_driver/25";
    return await http.delete(
      Uri.parse(fullUrl),
      // body: jsonEncode(data),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
  }

  updateUser(token, data, apiUrl, id ) async {
     String fullUrl = _url + apiUrl + id;
    print(fullUrl);
    
    // var fullUrl = "https://wow.design-street.com.au/api/edit_driver/25";
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
  }


    updateData(token, data, apiUrl, id ) async {
     String fullUrl = _url + apiUrl + id;
    print(fullUrl);
    
    // var fullUrl = "https://wow.design-street.com.au/api/edit_driver/25";
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
  }

    putData(token, data, apiUrl, id ) async {
     String fullUrl = _url + apiUrl + id;
    print(fullUrl);
    
    // var fullUrl = "https://wow.design-street.com.au/api/edit_driver/25";
    return await http.put(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
  }


  getDataById(token, apiUrl, id ) async {
     String fullUrl = _url + apiUrl + id;
    print(fullUrl.toString());
  
    return await http.get(
      Uri.parse(fullUrl),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
  }


    getGuestDataById(apiUrl, id ) async {
     String fullUrl = _url + apiUrl + id;
    print(fullUrl.toString());
  
    return await http.get(
      Uri.parse(fullUrl),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    }
    );
  }

Future<void> uploadImage(File imageFile) async {
  final url = Uri.parse('https://example.com/api/upload');

  var request = http.MultipartRequest('POST', url);
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('Image uploaded successfully!');
    } else {
      print('Image upload failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('Image upload failed with error: $e');
  }
}

    // getData(apiUrl) async {
    //    var fullUrl = _url + apiUrl + await _getToken(); 
    //    return await http.get(
    //      Uri.parse(fullUrl),
    //      headers: _setHeaders()
    //    );
    // }

   getData(token, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.get(
      Uri.parse(fullUrl),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
  }

  tokenData(token, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(
      Uri.parse(fullUrl),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
  }


  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'application/json'
  };

  _getToken() async {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        var token = localStorage.getString('token');
        return '?token=$token';
    }
 

}