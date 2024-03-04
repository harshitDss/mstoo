import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mstoo/user/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactUsPage extends StatefulWidget {
  ContactUsPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  var _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  bool _isLoading = false;
  bool _isData = false;

  @override
  void initState() {
    // _getUserInfo();
    // getUser();
    super.initState();
  }
  

  // void getUser() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   var token = localStorage.getString('token');

  //   // var res = await CallApi().postData(token, data, 'add_driver');
  //   var res = await CallApi().getData(token, 'user');
  //   var body = json.decode(res.body);
  //   print(body);

  //   setState(() {
  //     nameController.text = body['name'];
  //     mailController.text = body['email'];
  //     _isData = true;
  //     // dashboard = body;
  //   });
  //   // print(body);
  // }

  postData(String message) async {
    setState(() {
      _isLoading = true;
    });
    var data = {
      'message': message,
    };

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');

    try {
      var res = await CallApi().postData(token, data, 'api/v1/customer/add_contact');
      // var res = await CallApi().getData('student');
      var body = json.decode(res.body);
      // print(body);
      // print(body['errors']);

      if (res.statusCode == 200) {
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text(body['message'])));
                AwesomeDialog(
          context: context,
          headerAnimationLoop: false,
          dialogType: DialogType.noHeader,
          title: 'Success',
          desc: body['message'],
          btnOkOnPress: () {
            debugPrint('OnClcik');
          },
          btnOkIcon: Icons.check_circle,
        ).show();

        // _isLoading = false;

        // var data = jsonDecode(response.body.toString());
        // print(body['token']);
        // print('Login successfully');
      } else {
        body["errors"].forEach((key, messages) {
          if ("email" == key) {
            // show email errors like this
            for (var message in messages) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
            }
          } else if ("password" == key) {
            // show password erros like this
            for (var message in messages) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
            }
          }
        });
        // print('failed');
        //  ScaffoldMessenger.of(context).showSnackBar(body['message']);

        // _isLoading = false;

      }
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isLoading = false;
      // getUser();
    });
  }


  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          color: Colors.green
          ),
      child: InkWell(
        onTap: () => {
          // login(mailController.text.toString(), passwordController.text.toString()),
          // _formKey.currentState!.validate(),
          if (_formKey.currentState!.validate())
            {
              postData(
                messageController.text.toString(),
              ),
            }
          else
            {
              // login(mailController.text.toString(), passwordController.text.toString()),
            }
        },
        child: Text(
          _isLoading ? 'Loading...' : 'Send message',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }



  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        // _emailField("Email id"),
        // _passwordField("Password", isPassword: true),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        fillColor: Color(0xfff3f3f4),
                        filled: true)),
                const Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                    controller: mailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Email';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        fillColor: Color(0xfff3f3f4),
                        filled: true)),
                
                const Text(
                  "Phone",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                    controller: phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Phone No';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        fillColor: Color(0xfff3f3f4),
                        filled: true)),
                const Text(
                  "Message",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                    maxLines: 4,
                    controller: messageController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter message';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        fillColor: Color(0xfff3f3f4),
                        filled: true)),
                        
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text("Send Message"),
        ),
        body: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // SizedBox(height: height * .2),
                      // _title(),
                      // SizedBox(height: 50),
                      _emailPasswordWidget(),
                      SizedBox(height: 20),
                      _submitButton(),

                      // _divider(),
                      // _facebookButton(),
                      SizedBox(height: height * .055),
                      // _createAccountLabel(),
                    ],
                  ),
                ),
              ),
              // Positioned(top: 40, left: 0, child: _backButton()),
            ],
          ),
        ));
  }
}
