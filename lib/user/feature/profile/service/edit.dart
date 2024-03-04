import 'dart:convert';
import 'package:mstoo/user/core/core_export.dart';
import '../../../api/api.dart';
import 'package:http/http.dart' as http;

enum Featured { yes, no }
enum Availability { yes, no }

class EditService extends StatefulWidget {
  var id;
  EditService({Key? key, required this.id}) : super(key: key);

  @override
  State<EditService> createState() => _EditServiceState();
}

const List<String> list = <String>['yes', 'no'];

class _EditServiceState extends State<EditService> {

  Featured? _featured;
  Availability? availability;

  var _formKey = GlobalKey<FormState>();

  TextEditingController serviceNameController = TextEditingController();
  TextEditingController serviceDescController = TextEditingController();
  TextEditingController servicePriceController = TextEditingController();
  TextEditingController serviceSubCatController = TextEditingController();

  // String availability = list.first;

  var data;
  var images;
  var dashboard;
  var cat_id;
  var orderId;

  bool loadingImages = false;

  var coverImgUrl;
  var thumbnailImgUrl;

  XFile? serviceImg;
  XFile? thumbnailImg;

  final ImagePicker picker = ImagePicker();

  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;

  @override
  void initState() {
    getService();
    // _getUserInfo();
    getAllCat();
    super.initState();
  }

  Future getService() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var response = await CallApi().getDataById(
        token, '/api/v1/provider/getservice/', widget.id.toString());
    print(response.body.toString());
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      // print(jsonData);
      setState(() {
        data = jsonData['content']['service'];
        images = jsonData['content']['images'];
        print(images);
        coverImgUrl = images['cover_image'] != null
            ? images['cover_image'].toString()
            : "";
        thumbnailImgUrl =
            images['thumbnail'] != null ? images['thumbnail'].toString() : "";
        serviceNameController.text = data['name'].toString();
        serviceDescController.text = data['description'].toString();
        servicePriceController.text = data['price'];

        if(data['availability'].toString() == "yes"){
          availability = Availability.yes;
        }
         if(data['availability'].toString() == "no"){
          availability = Availability.no;
        }

        if(data['is_featured'].toString() == "yes"){
          _featured = Featured.yes;
        }
         if(data['is_featured'].toString() == "no"){
          _featured = Featured.no;
        }

      });
    }
  }

  List categoryItemlist = [];
  Future getAllCat() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var response = await CallApi().getData(token, '/api/v1/getallsubcat');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      setState(() {
        categoryItemlist = jsonData['content'];
      });
    }
  }

  openImages() async {
    try {
      var pickedfiles = await imgpicker.pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      if (pickedfiles != null) {
        imagefiles = pickedfiles;
        setState(() {});
      } else {
        print("No image is selected.");
      }
    } catch (e) {
      print("error while picking file.");
    }
  }

  //we can upload image from camera or from gallery based on parameter

  Future getserviceImg(ImageSource gallery) async {
    var img = await picker.pickImage(source: gallery);

    setState(() {
      serviceImg = img;
    });
  }

  Future getThumbnailImg(ImageSource gallery) async {
    var img = await picker.pickImage(source: gallery);

    setState(() {
      thumbnailImg = img;
    });
  }

  bool _isLoading = false;

  postData() async {
    setState(() {
      _isLoading = true;
    });

    var serviceImgPath = serviceImg!.path;
    var thumbnailImgPath = thumbnailImg!.path;

    var serviceImgBase64 = "";
    var thumbnailImgBase64 = "";

    File serviceFile = File(serviceImgPath); //convert Path to File
    Uint8List serviceBytes = await serviceFile.readAsBytes(); //convert to bytes
    serviceImgBase64 =
        base64.encode(serviceBytes); //convert bytes to base64 string

    File thumbnailFile = File(thumbnailImgPath); //convert Path to File
    Uint8List thumbnailBytes =
        await thumbnailFile.readAsBytes(); //convert to bytes
    thumbnailImgBase64 =
        base64.encode(thumbnailBytes); //convert bytes to base64 string

    var data = {
      'name': serviceNameController.text.toString(),
      'cover_image': serviceImgBase64.toString(),
      'description': serviceDescController.text.toString(),
      'thumbnail': thumbnailImgBase64.toString(),
      'sub_category_id': cat_id.toString(),
      'price': servicePriceController.text.toString(),
      'availability': availability.toString(),
    };

    print(availability);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');

    try {
      var res =
          await CallApi().putData(token, data, '/api/v1/provider/update_service/',widget.id.toString());
      var body = json.decode(res.body);
      print(body);
      if (res.statusCode == 200) {
        customSnackBar("Updated successfully");
      } else {
        body["errors"].forEach((key, messages) {
          if ("cover_image" == key) {
            for (var message in messages) {
              customSnackBar(message);
            }
          } else if ("thumbnail" == key) {
            for (var message in messages) {
              customSnackBar(message);
            }
          } else if ("availability" == key) {
            for (var message in messages) {
              customSnackBar(message);
            }
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

    _uploadImages() async {
    setState(() {
      _isLoading = true;
    });

    var serviceImgPath = serviceImg!.path;

    var serviceImgBase64 = "";

    File serviceFile = File(serviceImgPath); //convert Path to File
    Uint8List serviceBytes = await serviceFile.readAsBytes(); //convert to bytes
    serviceImgBase64 =
        base64.encode(serviceBytes); //convert bytes to base64 string

    var data = {
      'name': serviceNameController.text.toString(),
      'cover_image': serviceImgBase64.toString(),
      'description': serviceDescController.text.toString(),
      'sub_category_id': cat_id.toString(),
      'price': servicePriceController.text.toString(),
      'availability': availability.toString(),
    };

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var uri = Uri.parse(
        'https://mstooapp.design-street.com.au/api/v1/provider/update_service/${widget.id}');
    var request = http.MultipartRequest('POST', uri);

    request.fields['name'] = serviceNameController.text.toString();
    request.fields['cover_image'] = serviceImgBase64.toString();
    request.fields['description'] = serviceDescController.text.toString();
    request.fields['sub_category_id'] = cat_id.toString();
    request.fields['price'] = servicePriceController.text.toString();
    request.fields['availability'] = availability!.name.toString();
    request.fields['is_featured'] = _featured!.name.toString();

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    for (var imageFile in imagefiles!) {
      var stream = http.ByteStream(
        imageFile.openRead().cast(),
      ); // Convert the file to byte stream.
      var length = await imageFile.length(); // get image size
      var multipartFile = http.MultipartFile(
        'images[]', // ? or images[]. To you really need to label the parameter with a array definition at the end ?
        stream, //File as a stream
        length, //File size
        filename: imageFile.path.split('/').last, //File name without path.
      );
      request.files.add(multipartFile);
    }

    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('Images uploaded successfully.');
      customSnackBar("Service added successfully", isError: false);
    } else {
      customSnackBar(
          "Something went wrong... Error : ${response.reasonPhrase}");
    }

    setState(() {
      _isLoading = false;
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
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColorLight,
            ]),
      ),
      child: InkWell(
        onTap: () => {
          if (_formKey.currentState!.validate())
            {
              // postData(),
              _uploadImages(),
            }
          else
            {}
        },
        child: Text(
          _isLoading ? 'Loading...' : 'Update Service',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget formWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Select sub category",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButtonFormField(
                      hint: Text('Select Category'),
                      items: categoryItemlist.map((item) {
                        return DropdownMenuItem(
                          value: item['id'].toString(),
                          child: Text(item['name'].toString(),
                              style:
                                  TextStyle(fontSize: 15, color: Colors.red)),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          cat_id = newVal;
                          // print(cat_id);
                        });
                      },
                      value: cat_id,
                      validator: (value) => value == null
                            ? 'Please select a category': null,
                    ),
                    SizedBox(height: 20),
                    // _submitButton(),
                  ],
                ),

                const Text(
                  "Service Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                    controller: serviceNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter service name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        fillColor: Color(0xfff3f3f4),
                        filled: true)),
                const Text(
                  "Image",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        coverImgUrl != ""
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      coverImgUrl,
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      height: 200,
                                    )),
                              )
                            : Image.asset(
                                'assets/images/noimage.png',
                                width: MediaQuery.of(context).size.width / 3,
                                height: 200,
                              ),
                        ElevatedButton(
                            onPressed: () {
                              getserviceImg(ImageSource.gallery);
                             }, child: Text("Service Image")),
                      ],
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        serviceImg != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    //to show image, you type like this.
                                    File(serviceImg!.path),
                                    fit: BoxFit.cover,
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    height: 200,
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  getserviceImg(ImageSource.gallery);
                                },
                                child: dashboard != null
                                    ? dashboard['cover_image'] != null
                                        ? Image.network(
                                            coverImgUrl,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            height: 200,
                                          )
                                        : Image.asset(
                                            'assets/images/upload.png',
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            height: 200,
                                          )
                                    : Image.asset(
                                        'assets/images/upload.png',
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        height: 200,
                                      )),
                        ElevatedButton(
                            onPressed: () {
                              getserviceImg(ImageSource.gallery);
                            },
                            child: Text("click to upload new image")),
                      ],
                    ),
                  ],
                ),

                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                    controller: serviceDescController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                    maxLines: 8,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        fillColor: Color(0xfff3f3f4),
                        filled: true)),
                // const Text(
                //   "Thumbnail",
                //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                // ),
                // const SizedBox(
                //   height: 10,
                // ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     Column(
                //       children: [
                //         thumbnailImgUrl != ""
                //             ? Padding(
                //                 padding:
                //                     const EdgeInsets.symmetric(horizontal: 20),
                //                 child: ClipRRect(
                //                     borderRadius: BorderRadius.circular(8),
                //                     child: Image.network(
                //                       thumbnailImgUrl,
                //                       width:
                //                           MediaQuery.of(context).size.width / 3,
                //                       height: 200,
                //                     )),
                //               )
                //             : Image.asset(
                //                 'assets/images/noimage.png',
                //                 width: MediaQuery.of(context).size.width / 3,
                //                 height: 200,
                //               ),
                //         ElevatedButton(
                //             onPressed: () {
                //               // getserviceImg(ImageSource.gallery);
                //              }, child: Text("Thumbnail Image")),
                //       ],
                //     ),
                //   ],
                // ),

                const Text(
                  "Thumbnails",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          openImages();
                        },
                        child: Text("Select thumbnail images")),
                    Divider(),
                    Text("Picked Files:"),
                    Divider(),
                    imagefiles != null
                        ? Wrap(
                            children: imagefiles!.map((imageone) {
                              return Container(
                                  child: Card(
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  child: Image.file(File(imageone.path)),
                                ),
                              ));
                            }).toList(),
                          )
                        : Container()
                  ],
                ),

                

                const Text(
                  "Service price for rent/day",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                    controller: servicePriceController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter service price';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        fillColor: Color(0xfff3f3f4),
                        filled: true)),

                Text("Service Available"),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: const Text('Yes'),
                      leading: Radio<Availability>(
                        value: Availability.yes,
                        groupValue: availability,
                        onChanged: (Availability? value) {
                          setState(() {
                            availability = value;
                          });
                          debugPrint(availability!.name);
                        },
                      ),
                    )),
                    Expanded(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        title: const Text('No'),
                        leading: Radio<Availability>(
                          value: Availability.no,
                          groupValue: availability,
                          onChanged: (Availability? value) {
                            setState(() {
                              availability = value;
                            });
                            debugPrint(availability!.name);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                Text("Is Featured?"),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: const Text('Yes'),
                      leading: Radio<Featured>(
                        value: Featured.yes,
                        groupValue: _featured,
                        onChanged: (Featured? value) {
                          setState(() {
                            _featured = value;
                          });
                          debugPrint(_featured!.name);
                        },
                      ),
                    )),
                    Expanded(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        title: const Text('No'),
                        leading: Radio<Featured>(
                          value: Featured.no,
                          groupValue: _featured,
                          onChanged: (Featured? value) {
                            setState(() {
                              _featured = value;
                            });
                            debugPrint(_featured!.name);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Update service"),
      body: data != null
            ?
      SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 15,
              ),
              formWidget(),
              const SizedBox(
                height: 15,
              ),
              _submitButton(),
            ],
          ),
        ),
      ) : Center( child: CircularProgressIndicator(),),
    );
  }
}
