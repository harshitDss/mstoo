// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:mstoo/user/core/core_export.dart';

import 'package:http/http.dart' as http;
import 'package:mstoo/user/feature/profile/service/all.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:mstoo/razor_credentials.dart' as razorCredentials;

import '../../../api/api.dart';

class AddService extends StatefulWidget {
  const AddService({Key? key}) : super(key: key);

  @override
  State<AddService> createState() => _AddServiceState();
}

enum Featured { yes, no }

enum Availability { yes, no }

const List<String> list = <String>['yes', 'no'];

class _AddServiceState extends State<AddService> {
  final _razorpay = Razorpay();

  Featured? _featured = Featured.no;
  Availability? availability = Availability.yes;

  var _formKey = GlobalKey<FormState>();

  TextEditingController pickUpDateController = TextEditingController();

  TextEditingController serviceNameController = TextEditingController();

  TextEditingController servicePriceController = TextEditingController();

  //vehicle
  TextEditingController mileageController = TextEditingController();

  //cloth
  TextEditingController clothSizeController = TextEditingController();

  //property
  TextEditingController squareFootageController = TextEditingController();

  //common
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController availabilityController = TextEditingController();
  TextEditingController contactInfoController = TextEditingController();
  TextEditingController depositsController = TextEditingController();
  TextEditingController documentsController = TextEditingController();
  TextEditingController additionalInfoController = TextEditingController();
  TextEditingController deliveryController = TextEditingController();
  TextEditingController safetyController = TextEditingController();
  TextEditingController termsController = TextEditingController();

  // service
  TextEditingController serviceImageController = TextEditingController();
  TextEditingController serviceDescController = TextEditingController();
  TextEditingController serviceThumbnailsController = TextEditingController();
  TextEditingController serviceStatusController = TextEditingController();
  TextEditingController serviceSubCatController = TextEditingController();

  //electronics
  TextEditingController storageCapacityController = TextEditingController();
  TextEditingController resolutionController = TextEditingController();
  TextEditingController connectivityController = TextEditingController();

  //equipment
  TextEditingController dimensionsController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  var catName;
  var catType;

  var data;
  var dashboard;
  // String catId = "74218494-1abb-4dea-81cb-30db33ff6d06";
  String? catId;
  var subCatId;

  var orderId;

  var serviceImgUrl;
  var thumbnailImgUrl;

  bool loadingImages = false;

  XFile? serviceImg;
  XFile? thumbnailImg;

  final ImagePicker picker = ImagePicker();

  List<File> selectedImages = [];

  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;

  var featuredPrice;
  var featuredAdPrice;

  @override
  void initState() {
    // _getUserInfo();
    // getFields();
    getAllCat();

    // razorpay
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    });
    //

    super.initState();
  }

  // Razorpay
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Do something when payment succeeds
    log(response.paymentId.toString());

    setState(() {
      _isLoading = true;
    });

    var serviceImgPath = serviceImg!.path;

    var serviceImgBase64 = "";

    File serviceFile = File(serviceImgPath); //convert Path to File
    Uint8List serviceBytes = await serviceFile.readAsBytes(); //convert to bytes
    serviceImgBase64 =
        base64.encode(serviceBytes); //convert bytes to base64 string

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var uri = Uri.parse(
        'https://mstooapp.design-street.com.au/api/v1/provider/add_service');
    var request = http.MultipartRequest('POST', uri);

    request.fields['name'] = serviceNameController.text.toString();
    request.fields['cover_image'] = serviceImgBase64.toString();
    request.fields['description'] = serviceDescController.text.toString();
    request.fields['sub_category_id'] = subCatId.toString();
    request.fields['price'] = servicePriceController.text.toString();
    request.fields['availability'] = availability!.name.toString();
    request.fields['is_featured'] = _featured!.name.toString();

    // payment
    request.fields['order_id'] = response.orderId!.toString();
    request.fields['payment_id'] = response.paymentId!.toString();
    // request.fields['signature'] = response.signature.toString();

    if (catName == "vehicle") {
      request.fields['cat_name'] = catName;
      // request.fields['vehicle_type'] = vehicleType!;
      request.fields['vehicle_brand'] = vehicleBrand!;
      request.fields['model_year'] = modelYear!;
      request.fields['mileage'] = mileageController.text.toString();
      request.fields['fuel_type'] = fuelType!;
      request.fields['transmission'] = transmissionType!;
      request.fields['condition'] = condition!;
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['safety'] = safetyController.text.toString();
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "service") {
      request.fields['cat_name'] = catName;
      request.fields['service_type'] = serviceType!;
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['safety'] = safetyController.text.toString();
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "equipment") {
      request.fields['cat_name'] = catName;
      request.fields['equipment_type'] = equipmentType!;
      request.fields['equipment_brand'] = equipmentBrand!;
      request.fields['condition'] = condition!;
      request.fields['power_source'] = powerSource!;
      request.fields['weight'] = weightController.text.toString();
      request.fields['dimensions'] = dimensionsController.text.toString();
      request.fields['location'] = locationController.text.toString();
      request.fields['weight'] = weightController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['safety'] = safetyController.text.toString();
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "property") {
      request.fields['cat_name'] = catName;
      request.fields['property_type'] = propertyType!;
      request.fields['bedrooms'] = bedrooms!;
      request.fields['bathrooms'] = bathrooms!;
      request.fields['square_footage'] =
          squareFootageController.text.toString();
      request.fields['furnished'] = furnishedType!;
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['utilities'] = jsonEncode(utilitiesValues);
      request.fields['pets'] = jsonEncode(petsValues);
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "furniture") {
      request.fields['cat_name'] = catName;
      request.fields['furniture_type'] = furnitureType!;
      request.fields['furniture_brand'] = furnitureBrand!;
      request.fields['condition'] = condition!;
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "electronic") {
      request.fields['cat_name'] = catName;
      request.fields['electronic_type'] = electronicType!;
      request.fields['electronic_brand'] = electronicsBrand!;
      request.fields['model_year'] = modelYear!;
      request.fields['condition'] = condition!;
      request.fields['operating_system'] = operatingSystem!;
      request.fields['screen_size'] = screenSize!;
      request.fields['storage_capacity'] =
          storageCapacityController.text.toString();
      request.fields['camera_resolution'] =
          resolutionController.text.toString();
      request.fields['connectivity'] = connectivityController.text.toString();
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "cloth") {
      request.fields['cat_name'] = catName;
      request.fields['cloth_type'] = clothType!;
      request.fields['cloth_size'] = clothSize!;
      request.fields['cloth_brand'] = clothBrand!;
      request.fields['condition'] = condition!;
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['t_and_c'] = termsController.text.toString();
    }

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

    var responseData = await request.send();
    if (responseData.statusCode == 200) {
      print('Images uploaded successfully.');
      customSnackBar("Service added successfully", isError: false);
      _formKey.currentState!.reset();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AllServices()),
      );
    } else {
      customSnackBar(
          "Something went wrong... Error : ${responseData.reasonPhrase}");
    }

    setState(() {
      _isLoading = false;
    });

    print(response);
    verifySignature(
      signature: response.signature,
      paymentId: response.paymentId,
      orderId: response.orderId,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(response);
    // Do something when payment fails
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? ''),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print(response);
    // Do something when an external wallet is selected
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.walletName ?? ''),
      ),
    );
  }

// create order
  void createOrder() async {
    String username = razorCredentials.keyId;
    String password = razorCredentials.keySecret;
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final now = DateTime.now();
    var uniqueID = now.microsecondsSinceEpoch.toString();

    Map<String, dynamic> body = {
      "amount": 100 * featuredAdPrice,
      "currency": "INR",
      "receipt": "OD-$uniqueID",
    };
    var res = await http.post(
      Uri.https(
          "api.razorpay.com", "v1/orders"), //https://api.razorpay.com/v1/orders
      headers: <String, String>{
        "Content-Type": "application/json",
        'authorization': basicAuth,
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      openGateway(jsonDecode(res.body)['id']);
    }
    print(res.body);
  }

  openGateway(String orderId) {
    var options = {
      'key': razorCredentials.keyId,
      'amount': 100 * featuredAdPrice, //in the smallest currency sub-unit.
      'name': 'MSTOO',
      'order_id': orderId, // Generate order_id using Orders API
      'description': '$catName',
      'timeout': 60 * 5, // in seconds // 5 minutes
      // 'prefill': {
      //   'contact': '9123456789',
      //   'email': 'ary@example.com',
      // }
    };
    _razorpay.open(options);
  }

  verifySignature({
    String? signature,
    String? paymentId,
    String? orderId,
  }) async {
    Map<String, dynamic> body = {
      'razorpay_signature': signature,
      'razorpay_payment_id': paymentId,
      'razorpay_order_id': orderId,
    };

    var parts = [];
    body.forEach((key, value) {
      parts.add('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value)}');
    });
    var formData = parts.join('&');
    var res = await http.post(
      Uri.https(
        "10.0.2.2", // my ip address , localhost
        "razorpay_signature_verify.php",
      ),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded", // urlencoded
      },
      body: formData,
    );

    print(res.body);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.body),
        ),
      );
    }
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners

    super.dispose();
  }

  // Razorpay
  List categoryItemlist = [];
  List subCategoryItemlist = [];

  List<String> dropdownData = [];

  bool isLoading = false;

  // Vehicle
  String? vehicleType;
  String? vehicleBrand;
  String? modelYear;
  String? fuelType;
  String? transmissionType;
  String? condition;
  List<String> vehicleTypeList = [];
  List<String> vehicleBrandList = [];
  List<String> fuelTypeList = [];
  List<String> transmissionTypeList = [];

  // service
  String? serviceType;
  List<String> serviceTypeList = [];

  // clothes
  String? clothType;
  String? clothBrand;
  String? clothSize;
  List<String> clothTypeList = [];
  List<String> clothBrandList = [];
  List<String> clothSizeList = [];

  // common
  List<String> conditionList = [];
  List<String> modelYearList = [];

  // Electronics
  String? electronicType;
  String? electronicsBrand;
  String? operatingSystem;
  String? screenSize;
  List<String> electronicTypeList = [];
  List<String> electronicsBrandList = [];
  List<String> operatingSystemList = [];
  List<String> screenSizeList = [];

  // Equipment
  String? equipmentType;
  String? equipmentBrand;
  String? powerSource;
  List<String> equipmentTypeList = [];
  List<String> equipmentBrandList = [];
  List<String> powerSourceList = [];

  // Furniture
  String? furnitureType;
  String? furnitureBrand;
  List<String> furnitureTypeList = [];
  List<String> furnitureBrandList = [];

  //property
  String? propertyType;
  String? bedrooms;
  String? bathrooms;
  String? furnishedType;
  List<String> propertyTypeList = [];
  List<String> bedroomsList = [];
  List<String> bathroomsList = [];
  List<String> furnishedTypeList = [];

  List<String> deliveryValues = [];
  List<String> utilitiesValues = [];
  List<String> petsValues = [];
  List<String> allOptions = ['delivery', 'pickup'];
  List<String> allUtilities = ['water', 'electricity', 'gas'];
  List<String> petsAllowed = ['pets allowed'];

  Future getAllCat() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var response = await CallApi().getData(token, '/api/v1/getallcat');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      // print(jsonData);
      setState(() {
        categoryItemlist = jsonData['content'];
        getFieldsById();
        getAllSubCat();
      });
    }
  }

  Future getFieldsById() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var response = await CallApi()
        .getDataById(token, '/api/v1/getfieldsbyid/', catId.toString());

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      print(data);
      setState(() {
        isLoading = false;
        catName = data['category_name'];
        featuredPrice = data['featured_price'];
        featuredAdPrice = int.parse(featuredPrice);
        print(featuredAdPrice.runtimeType);

        // vehicles
        if (data['vehicle_type'] != null) {
          vehicleTypeList = List<String>.from(data['vehicle_type']);
        }
        if (data['vehicle_brand'] != null) {
          vehicleBrandList = List<String>.from(data['vehicle_brand']);
        }
        if (data['fuel_type'] != null) {
          fuelTypeList = List<String>.from(data['fuel_type']);
        }
        if (data['transmission'] != null) {
          transmissionTypeList = List<String>.from(data['transmission']);
        }
        if (data['condition'] != null) {
          conditionList = List<String>.from(data['condition']);
        }
        if (data['model_year'] != null) {
          modelYearList = List<String>.from(data['model_year']);
        }

        //electronics
        if (data['electronic_type'] != null) {
          electronicTypeList = List<String>.from(data['electronic_type']);
        }

        if (data['electronic_brand'] != null) {
          electronicsBrandList = List<String>.from(data['electronic_brand']);
        }

        if (data['model_year'] != null) {
          modelYearList = List<String>.from(data['model_year']);
        }

        if (data['screen_size'] != null) {
          screenSizeList = List<String>.from(data['screen_size']);
        }

        //service
        if (data['service_type'] != null) {
          serviceTypeList = List<String>.from(data['service_type']);
          print(serviceTypeList);
        }

        //equipment
        if (data['equipment_type'] != null) {
          equipmentTypeList = List<String>.from(data['equipment_type']);
          print(equipmentTypeList);
        }
        if (data['equipment_brand'] != null) {
          equipmentBrandList = List<String>.from(data['equipment_brand']);
          print(equipmentBrandList);
        }
        if (data['power_source'] != null) {
          powerSourceList = List<String>.from(data['power_source']);
          print(powerSourceList);
        }

        //furniture
        if (data['furniture_type'] != null) {
          furnitureTypeList = List<String>.from(data['furniture_type']);
          print(equipmentTypeList);
        }
        if (data['furniture_brand'] != null) {
          furnitureBrandList = List<String>.from(data['furniture_brand']);
          print(furnitureBrandList);
        }

        //property
        if (data['property_type'] != null) {
          propertyTypeList = List<String>.from(data['property_type']);
          print(propertyTypeList);
        }
        if (data['bedrooms'] != null) {
          bedroomsList = List<String>.from(data['bedrooms']);
          print(furnitureBrandList);
        }
        if (data['bathrooms'] != null) {
          bathroomsList = List<String>.from(data['bathrooms']);
          print(bathroomsList);
        }
        if (data['furnished'] != null) {
          furnishedTypeList = List<String>.from(data['furnished']);
          print(furnishedTypeList);
        }

        //cloth
        if (data['cloth_type'] != null) {
          clothTypeList = List<String>.from(data['cloth_type']);
          print(clothTypeList);
        }
        if (data['cloth_size'] != null) {
          clothSizeList = List<String>.from(data['cloth_size']);
          print(clothSizeList);
        }
        if (data['cloth_brand'] != null) {
          clothBrandList = List<String>.from(data['cloth_brand']);
          print(clothBrandList);
        }
      });
    } else {
      // Handle errors
      print('Failed to fetch data');
    }
  }

  Future getAllSubCat() async {
    print("get all sub cat");
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var response = await CallApi()
        .getDataById(token, '/api/v1/getallsubcatbyid/', catId.toString());

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      // print(jsonData);
      setState(() {
        subCategoryItemlist = jsonData['content'];
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

    // print(serviceImgBase64);

    // print(thumbnailImgBase64);

    var data = {
      'name': serviceNameController.text.toString(),
      'cover_image': serviceImgBase64.toString(),
      'description': serviceDescController.text.toString(),
      'thumbnail': thumbnailImgBase64.toString(),
      'sub_category_id': subCatId.toString(),
      'price': servicePriceController.text.toString(),
      'availability': availability.toString(),
    };

    print(availability);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');

    try {
      var res =
          await CallApi().postData(token, data, '/api/v1/provider/add_service');
      var body = json.decode(res.body);
      print(body);
      if (res.statusCode == 200) {
        customSnackBar("Added successfully");
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

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var uri = Uri.parse(
        'https://mstooapp.design-street.com.au/api/v1/provider/add_service');
    var request = http.MultipartRequest('POST', uri);

    request.fields['name'] = serviceNameController.text.toString();
    request.fields['cover_image'] = serviceImgBase64.toString();
    request.fields['description'] = serviceDescController.text.toString();
    request.fields['sub_category_id'] = subCatId.toString();
    request.fields['price'] = servicePriceController.text.toString();
    request.fields['availability'] = availability!.name.toString();
    request.fields['is_featured'] = _featured!.name.toString();

    if (catName == "vehicle") {
      request.fields['cat_name'] = catName;
      request.fields['vehicle_type'] = vehicleType!;
      request.fields['vehicle_brand'] = vehicleBrand!;
      request.fields['model_year'] = modelYear!;
      request.fields['mileage'] = mileageController.text.toString();
      request.fields['fuel_type'] = fuelType!;
      request.fields['transmission'] = transmissionType!;
      request.fields['condition'] = condition!;
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['safety'] = safetyController.text.toString();
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "service") {
      request.fields['cat_name'] = catName;
      request.fields['service_type'] = serviceType!;
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['safety'] = safetyController.text.toString();
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "equipment") {
      request.fields['cat_name'] = catName;
      request.fields['equipment_type'] = equipmentType!;
      request.fields['equipment_brand'] = equipmentBrand!;
      request.fields['condition'] = condition!;
      request.fields['power_source'] = powerSource!;
      request.fields['weight'] = weightController.text.toString();
      request.fields['dimensions'] = dimensionsController.text.toString();
      request.fields['location'] = locationController.text.toString();
      request.fields['weight'] = weightController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['safety'] = safetyController.text.toString();
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "property") {
      request.fields['cat_name'] = catName;
      request.fields['property_type'] = propertyType!;
      request.fields['bedrooms'] = bedrooms!;
      request.fields['bathrooms'] = bathrooms!;
      request.fields['square_footage'] =
          squareFootageController.text.toString();
      request.fields['furnished'] = furnishedType!;
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['utilities'] = jsonEncode(utilitiesValues);
      request.fields['pets'] = jsonEncode(petsValues);
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "furniture") {
      request.fields['cat_name'] = catName;
      request.fields['furniture_type'] = furnitureType!;
      request.fields['furniture_brand'] = furnitureBrand!;
      request.fields['condition'] = condition!;
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "electronic") {
      request.fields['cat_name'] = catName;
      request.fields['electronic_type'] = electronicType!;
      request.fields['electronic_brand'] = electronicsBrand!;
      request.fields['model_year'] = modelYear!;
      request.fields['condition'] = condition!;
      request.fields['operating_system'] = operatingSystem!;
      request.fields['screen_size'] = screenSize!;
      request.fields['storage_capacity'] =
          storageCapacityController.text.toString();
      request.fields['camera_resolution'] =
          resolutionController.text.toString();
      request.fields['connectivity'] = connectivityController.text.toString();
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['t_and_c'] = termsController.text.toString();
    }

    if (catName == "cloth") {
      request.fields['cat_name'] = catName;
      request.fields['cloth_type'] = clothType!;
      request.fields['cloth_size'] = clothSize!;
      request.fields['cloth_brand'] = clothBrand!;
      request.fields['condition'] = condition!;
      request.fields['location'] = locationController.text.toString();
      request.fields['availability_date'] =
          availabilityController.text.toString();
      request.fields['contact_info'] = contactInfoController.text.toString();
      request.fields['deposits'] = depositsController.text.toString();
      request.fields['doc_required'] = documentsController.text.toString();
      request.fields['additional_info'] =
          additionalInfoController.text.toString();
      request.fields['delivery_pickup'] = jsonEncode(deliveryValues);
      request.fields['t_and_c'] = termsController.text.toString();
    }

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
    if (response.statusCode == 200) {
      print('Images uploaded successfully.');
      customSnackBar("Service added successfully", isError: false);
      _formKey.currentState!.reset();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AllServices()),
      );
    } else {
      customSnackBar(
          "Something went wrong... Error : ${response.reasonPhrase}");
    }

    setState(() {
      _isLoading = false;
    });
  }

  String? gender; //no radio button will be selected on initial

  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.shade200,
              offset: const Offset(2, 4),
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
              _featured!.name == "no" ? _uploadImages() : createOrder(),
              // _uploadImages(),
            }
          else
            {}
        },
        child: Text(
          _featured!.name == "no"
              ? _isLoading
                  ? 'Loading...'
                  : 'Add Service'
              : _isLoading
                  ? 'Loading...'
                  : 'Pay',
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget formWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Select category",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    DropdownButtonFormField(
                      hint: const Text('Select Category'),
                      items: categoryItemlist.map((item) {
                        return DropdownMenuItem(
                          value: item['id'].toString(),
                          child: Text(item['name'].toString(),
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        print(newVal);
                        setState(() {
                          catId = newVal!;
                          isLoading = true;
                          print(catId);
                        });
                        getAllSubCat();
                        getFieldsById();
                        // Vehicle
                        vehicleTypeList.clear();
                        vehicleBrandList.clear();
                        fuelTypeList.clear();
                        transmissionTypeList.clear();

                        // service
                        serviceTypeList.clear();

                        // common
                        conditionList.clear();
                        modelYearList.clear();

                        // Electronics
                        electronicTypeList.clear();
                        electronicsBrandList.clear();
                        operatingSystemList.clear();
                        screenSizeList.clear();

                        // furniture
                        furnitureTypeList.clear();
                        furnitureBrandList.clear();

                        // Property
                        propertyTypeList.clear();
                        bedroomsList.clear();
                        bathroomsList.clear();
                        furnishedTypeList.clear();

                        // equipment
                        equipmentTypeList.clear();
                        equipmentBrandList.clear();
                        powerSourceList.clear();

                        // cloth
                        clothTypeList.clear();
                        clothBrandList.clear();
                        clothSizeList.clear();
                      },
                      value: catId,
                      validator: (value) {
                        if (value == null) {
                          return 'Please select category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // _submitButton(),
                  ],
                ),
                isLoading == false
                    ? SingleChildScrollView(
                        child: Column(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "Select sub category",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              DropdownButtonFormField(
                                hint: const Text('Select sub category'),
                                items: subCategoryItemlist.map((item) {
                                  return DropdownMenuItem(
                                    value: item['id'].toString(),
                                    child: Text(item['name'].toString(),
                                        style: const TextStyle(
                                            fontSize: 15, color: Colors.black)),
                                  );
                                }).toList(),
                                onChanged: (newVal) {
                                  setState(() {
                                    subCatId = newVal;
                                    // print(cat_id);
                                  });
                                },
                                value: subCatId,
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select sub category';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // _submitButton(),
                            ],
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              const Text(
                                "Title",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              TextFormField(
                                  controller: serviceNameController,
                                  maxLines: 2,
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
                            ],
                          ),
                          // SizedBox(height: 10,),
                          // vehicleTypeList.isNotEmpty
                          //     ? Container(
                          //       padding: EdgeInsets.all(5.0),
                          //       decoration: BoxDecoration(
                          //         border: Border.all(color: Colors.grey),
                          //         borderRadius: BorderRadius.circular(5),
                          //       ),
                          //       child: Column(
                          //           crossAxisAlignment: CrossAxisAlignment.start,
                          //           children: <Widget>[
                          //             Row(
                          //               mainAxisAlignment:
                          //                   MainAxisAlignment.spaceBetween,
                          //               children: [
                          //                 const Text(
                          //                   "Vehicle type",
                          //                   style: TextStyle(
                          //                       fontWeight: FontWeight.bold,
                          //                       fontSize: 15),
                          //                 ),
                          //                 DropdownButtonFormField(
                          //                   hint:
                          //                       const Text('Select vehicle type'),
                          //                   items: vehicleTypeList.map((item) {
                          //                     return DropdownMenuItem(
                          //                       value: item.toString(),
                          //                       child: Text(item.capitalize(),
                          //                           style: const TextStyle(
                          //                               fontSize: 15,
                          //                               color: Colors.black)),
                          //                     );
                          //                   }).toList(),
                          //                   onChanged: (newVal) {
                          //                     print(newVal);
                          //                     setState(() {
                          //                       vehicleType = newVal.toString();

                          //                       print(vehicleType);
                          //                     });
                          //                   },
                          //                   value: vehicleType,
                          //                 ),
                          //               ],
                          //             ),
                          //             const SizedBox(height: 20),
                          //             // _submitButton(),
                          //           ],
                          //         ),
                          //     )
                          //     : const Column(),
                          // SizedBox(height: 10,),
                          electronicTypeList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Product type",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Container(
                                            width: 200,
                                            child: DropdownButtonFormField(
                                              hint: const Text(
                                                  'Select product type'),
                                              items:
                                                  electronicTypeList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item.toString(),
                                                  child: Text(item.capitalize(),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                              onChanged: (newVal) {
                                                print(newVal);
                                                setState(() {
                                                  electronicType =
                                                      newVal.toString();
                                            
                                                  print(electronicType);
                                                });
                                              },
                                              value: electronicType,
                                              validator: (value) {
                                              if (value == null) {
                                                return 'Please select';
                                              }
                                              return null;
                                            },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // _submitButton(),
                                    ],
                                  ),
                                )
                              : const Column(),
                          // SizedBox(height: 10,),
                          equipmentTypeList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Equipment type",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Container(
                                            width: 200,
                                            child: DropdownButtonFormField(
                                              hint: const Text(
                                                  'Select type'),
                                              items:
                                                  equipmentTypeList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item.toString(),
                                                  child: Text(item.capitalize(),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                              onChanged: (newVal) {
                                                print(newVal);
                                                setState(() {
                                                  equipmentType =
                                                      newVal.toString();
                                            
                                                  print(equipmentType);
                                                });
                                              },
                                              value: equipmentType,
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // _submitButton(),
                                    ],
                                  ),
                                )
                              : const Column(),
                          // SizedBox(height: 10,),
                          equipmentBrandList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Equipment brand",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Container(
                                            width: 200,
                                            child: DropdownButtonFormField(
                                              hint: const Text(
                                                  'Select brand'),
                                              items:
                                                  equipmentBrandList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item.toString(),
                                                  child: Text(item.capitalize(),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                              onChanged: (newVal) {
                                                print(newVal);
                                                setState(() {
                                                  equipmentBrand =
                                                      newVal.toString();
                                            
                                                  print(equipmentBrand);
                                                });
                                              },
                                              value: equipmentBrand,
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // _submitButton(),
                                    ],
                                  ),
                                )
                              : const Column(),
                          // SizedBox(height: 10,),
                          furnitureTypeList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Furniture type",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint:
                                              const Text('Select furniture type'),
                                          items: furnitureTypeList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              furnitureType = newVal.toString();
                                        
                                              print(furnitureTypeList);
                                            });
                                          },
                                          value: furnitureType,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),

                          propertyTypeList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Property type",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint:
                                              const Text('Select property type'),
                                          items: propertyTypeList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              propertyType = newVal.toString();
                                              print(propertyType);
                                            });
                                          },
                                          value: propertyType,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),

                          // service
                          // SizedBox(height: 10,),
                          serviceTypeList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Service type",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Container(
                                        width: 200,
                                            child: DropdownButtonFormField(
                                              hint: const Text(
                                                  'Select service type'),
                                              items: serviceTypeList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item.toString(),
                                                  child: Text(item.capitalize(),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                              onChanged: (newVal) {
                                                print(newVal);
                                                setState(() {
                                                  serviceType = newVal.toString();
                                            
                                                  print(serviceType);
                                                });
                                              },
                                              value: serviceType,
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // _submitButton(),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          clothTypeList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Item type",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint: const Text('Select item type'),
                                          items: clothTypeList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              clothType = newVal.toString();
                                        
                                              print(clothType);
                                            });
                                          },
                                          value: clothType,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          clothSizeList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Size",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint: const Text('Select size'),
                                          items: clothSizeList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              clothSize = newVal.toString();
                                        
                                              print(clothSize);
                                            });
                                          },
                                          value: clothSize,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          clothBrandList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Brand",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint: const Text('Select brand'),
                                          items: clothBrandList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              clothBrand = newVal.toString();
                                        
                                              print(clothSize);
                                            });
                                          },
                                          value: clothBrand,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          bedroomsList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Bedrooms",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint: const Text('Select bedrooms'),
                                          items: bedroomsList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              bedrooms = newVal.toString();
                                              print(bedrooms);
                                            });
                                          },
                                          value: bedrooms,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          bathroomsList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Bathrooms",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint: const Text('Select bathrooms'),
                                          items: bathroomsList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              bathrooms = newVal.toString();
                                              print(bathrooms);
                                            });
                                          },
                                          value: bathrooms,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          vehicleBrandList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Brand/Make",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Container(
                                        width: 200,
                                            child: DropdownButtonFormField(
                                              hint:
                                                  const Text('Select brand/make'),
                                              items: vehicleBrandList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item.toString(),
                                                  child: Text(item.capitalize(),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                              onChanged: (newVal) {
                                                print(newVal);
                                                setState(() {
                                                  vehicleBrand =
                                                      newVal.toString();
                                            
                                                  print(vehicleBrand);
                                                });
                                              },
                                              value: vehicleBrand,
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // _submitButton(),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          electronicsBrandList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Electronics Brand",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint: const Text('Select brand type'),
                                          items: electronicsBrandList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              electronicsBrand =
                                                  newVal.toString();
                                        
                                              print(electronicsBrand);
                                            });
                                          },
                                          value: electronicsBrand,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          furnitureBrandList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Furniture brand",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint: const Text(
                                              'Select brand'),
                                          items: furnitureBrandList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              furnitureBrand = newVal.toString();
                                        
                                              print(furnitureBrand);
                                            });
                                          },
                                          value: furnitureBrand,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),

                          const SizedBox(height: 10),

                          modelYearList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Model year",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Container(
                                        width: 200,
                                            child: DropdownButtonFormField(
                                              hint:
                                                  const Text('Select model year'),
                                              items: modelYearList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item.toString(),
                                                  child: Text(item.capitalize(),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                              onChanged: (newVal) {
                                                print(newVal);
                                                setState(() {
                                                  modelYear = newVal.toString();
                                                  print(modelYear);
                                                });
                                              },
                                              value: modelYear,
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // _submitButton(),
                                    ],
                                  ),
                                )
                              : const Column(),

                          catName == "property"
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Square footage",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      TextFormField(
                                          controller: squareFootageController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter square footage';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true)),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Service price for rent/day",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                TextFormField(
                                    controller: servicePriceController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter service price';
                                      } else if (int.parse(value) < 499) {
                                        return 'Minimum price is ₹ 500';
                                      }

                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        fillColor: Color(0xfff3f3f4),
                                        filled: true)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          conditionList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Condition",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Container(
                                        width: 200,
                                            child: DropdownButtonFormField(
                                              hint:
                                                  const Text('Select condition '),
                                              items: conditionList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item.toString(),
                                                  child: Text(item.capitalize(),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                              onChanged: (newVal) {
                                                print(newVal);
                                                setState(() {
                                                  condition = newVal.toString();
                                                  print(condition);
                                                });
                                              },
                                              value: condition,
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // _submitButton(),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          catName == "vehicle"
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Mileage",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      TextFormField(
                                          controller: mileageController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter mileage';
                                            }

                                            return null;
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true)),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          fuelTypeList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Fuel type",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Container(
                                        width: 200,
                                            child: DropdownButtonFormField(
                                              hint:
                                                  const Text('Select fuel type'),
                                              items: fuelTypeList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item.toString(),
                                                  child: Text(item.capitalize(),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                              onChanged: (newVal) {
                                                print(newVal);
                                                setState(() {
                                                  fuelType = newVal.toString();
                                                  print(fuelType);
                                                });
                                              },
                                              value: fuelType,
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // _submitButton(),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          transmissionTypeList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Transmission",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Container(
                                        width: 200,
                                            child: DropdownButtonFormField(
                                              hint: const Text(
                                                  'Select transmission'),
                                              items: transmissionTypeList
                                                  .map((item) {
                                                return DropdownMenuItem(
                                                  value: item.toString(),
                                                  child: Text(item.capitalize(),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                              onChanged: (newVal) {
                                                print(newVal);
                                                setState(() {
                                                  transmissionType =
                                                      newVal.toString();
                                                  print(transmissionType);
                                                });
                                              },
                                              value: transmissionType,
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // _submitButton(),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          furnishedTypeList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Furnished type",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint:
                                              const Text('Select furnished type'),
                                          items: furnishedTypeList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              furnishedType = newVal.toString();
                                              print(furnishedType);
                                            });
                                          },
                                          value: furnishedType,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          operatingSystemList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Operating system",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint: const Text(
                                              'Select operating system'),
                                          items: operatingSystemList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              operatingSystem = newVal.toString();
                                        
                                              print(operatingSystem);
                                            });
                                          },
                                          value: operatingSystem,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          screenSizeList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Screen size",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        width: 200,
                                        child: DropdownButtonFormField(
                                          hint: const Text('Select screen size'),
                                          items: screenSizeList.map((item) {
                                            return DropdownMenuItem(
                                              value: item.toString(),
                                              child: Text(item.capitalize(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                            );
                                          }).toList(),
                                          onChanged: (newVal) {
                                            print(newVal);
                                            setState(() {
                                              screenSize = newVal.toString();
                                        
                                              print(screenSize);
                                            });
                                          },
                                          value: screenSize,
                                          validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          catName == "electronic"
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Storage capacity",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      TextFormField(
                                          controller: storageCapacityController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter storage capacity';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true)),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          catName == "electronic"
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Camera resolution",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      TextFormField(
                                          controller: resolutionController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter resolution';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true)),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          catName == "electronic"
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Connectivity",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      TextFormField(
                                          controller: connectivityController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter connectivity';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true)),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          powerSourceList.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Power source",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Container(
                                        width: 200,
                                            child: DropdownButtonFormField(
                                              hint: const Text(
                                                  'Select power source'),
                                              items: powerSourceList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item.toString(),
                                                  child: Text(item.capitalize(),
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black)),
                                                );
                                              }).toList(),
                                              onChanged: (newVal) {
                                                setState(() {
                                                  powerSource = newVal.toString();
                                                  print(powerSource);
                                                });
                                              },
                                              value: powerSource,
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please select';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          catName == "equipment"
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Weight capacity",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      TextFormField(
                                          controller: serviceDescController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter weight capacity';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true)),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          catName == "equipment"
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Dimensions",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      TextFormField(
                                          controller: dimensionsController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter dimensions';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              fillColor: Color(0xfff3f3f4),
                                              filled: true)),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Description",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
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
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Thumbnails",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      openImages();
                                    },
                                    child:
                                        const Text("Select thumbnail images")),
                                const Divider(),
                                const Text("Picked Files:"),
                                const Divider(),
                                imagefiles != null
                                    ? Wrap(
                                        children: imagefiles!.map((imageone) {
                                          return Container(
                                              child: Card(
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              child: Image.file(
                                                  File(imageone.path)),
                                            ),
                                          ));
                                        }).toList(),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      "Image",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    serviceImg != null
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                //to show image, you type like this.
                                                File(serviceImg!.path),
                                                fit: BoxFit.cover,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3,
                                                height: 200,
                                              ),
                                            ),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              getserviceImg(
                                                  ImageSource.gallery);
                                            },
                                            child: dashboard != null
                                                ? dashboard['odometer_img'] !=
                                                        null
                                                    ? Image.network(
                                                        serviceImgUrl,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            3,
                                                        height: 200,
                                                      )
                                                    : Image.asset(
                                                        'assets/images/upload.png',
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            3,
                                                        height: 200,
                                                      )
                                                : Image.asset(
                                                    'assets/images/upload.png',
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3,
                                                    height: 200,
                                                  )),
                                    ElevatedButton(
                                        onPressed: () {
                                          getserviceImg(ImageSource.gallery);
                                        },
                                        child: const Text(
                                            "click to select image")),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Location",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                TextFormField(
                                    controller: locationController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter location';
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
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Availability Calendar",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                TextFormField(
                                    controller: availabilityController,
                                    readOnly:
                                        true, //set it true, so that user will not able to edit text
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(
                                                  2000), //DateTime.now() - not to allow to choose before today.
                                              lastDate: DateTime(2101));

                                      if (pickedDate != null) {
                                        print(
                                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                        String formattedDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(pickedDate);
                                        print(
                                            formattedDate); //formatted date output using intl package =>  2021-03-16
                                        //you can implement different kind of Date Format here according to your requirement

                                        setState(() {
                                          var dateinput;
                                          availabilityController.text =
                                              formattedDate; //set output date to TextField value.
                                        });
                                      } else {
                                        print("Date is not selected");
                                      }
                                    },

                                    // obscureText: true,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        fillColor: Color(0xfff3f3f4),
                                        filled: true)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Contact Information",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                TextFormField(
                                    controller: contactInfoController,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter contact information';
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
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Deposit and Security",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                TextFormField(
                                    controller: depositsController,
                                    validator: (value) {},
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        fillColor: Color(0xfff3f3f4),
                                        filled: true)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Documents Required",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                TextFormField(
                                    maxLines: 4,
                                    controller: documentsController,
                                    validator: (value) {},
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        fillColor: Color(0xfff3f3f4),
                                        filled: true)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Additional information",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                TextFormField(
                                    maxLines: 4,
                                    controller: additionalInfoController,
                                    validator: (value) {},
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        fillColor: Color(0xfff3f3f4),
                                        filled: true)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          catName != "property"
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    children: allOptions.map((String option) {
                                      return CheckboxListTile(
                                        title: Text(option.capitalize()),
                                        value: deliveryValues.contains(option),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value != null && value) {
                                              deliveryValues.add(option);
                                              print(deliveryValues);
                                            } else {
                                              deliveryValues.remove(option);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          catName == "property"
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text("Utilites Included: "),
                                      Column(
                                        children:
                                            allUtilities.map((String option) {
                                          return CheckboxListTile(
                                            title: Text(option.capitalize()),
                                            value: utilitiesValues
                                                .contains(option),
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value != null && value) {
                                                  utilitiesValues.add(option);
                                                  print(utilitiesValues);
                                                } else {
                                                  utilitiesValues
                                                      .remove(option);
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                      const Text("Pets "),
                                      Column(
                                        children:
                                            petsAllowed.map((String option) {
                                          return CheckboxListTile(
                                            title: Text(option.capitalize()),
                                            value: petsValues.contains(option),
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value != null && value) {
                                                  petsValues.add(option);
                                                  print(petsValues);
                                                } else {
                                                  petsValues.remove(option);
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Safety guidlines",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                TextFormField(
                                    maxLines: 4,
                                    controller: safetyController,
                                    validator: (value) {},
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        fillColor: Color(0xfff3f3f4),
                                        filled: true)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Terms & Conditions",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                TextFormField(
                                    maxLines: 4,
                                    controller: termsController,
                                    validator: (value) {},
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        fillColor: Color(0xfff3f3f4),
                                        filled: true)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              const Text("Featured service?"),
                              Row(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Radio<Featured>(
                                        value: Featured.yes,
                                        groupValue: _featured,
                                        onChanged: (Featured? value) {
                                          setState(() {
                                            _featured = value;
                                            print(_featured!.name);
                                          });
                                        },
                                      ),
                                      Text("Yes"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<Featured>(
                                        value: Featured.no,
                                        groupValue: _featured,
                                        onChanged: (Featured? value) {
                                          setState(() {
                                            _featured = value;
                                            print(_featured!.name);
                                          });
                                        },
                                      ),
                                      Text("No"),
                                    ],
                                  ),
                                  // ListTile(
                                  //   title: const Text('Yes'),
                                  //   leading: Radio<Featured>(
                                  //     value: Featured.yes,
                                  //     groupValue: _featured,
                                  //     onChanged: (Featured? value) {
                                  //       setState(() {
                                  //         _featured = value;
                                  //         print(_featured!.name);
                                  //       });
                                  //     },
                                  //   ),
                                  // ),
                                  // ListTile(
                                  //   title: const Text('No'),
                                  //   leading: Radio<Featured>(
                                  //     value: Featured.no,
                                  //     groupValue: _featured,
                                  //     onChanged: (Featured? value) {
                                  //       setState(() {
                                  //         _featured = value;
                                  //         print(_featured!.name);
                                  //       });
                                  //     },
                                  //   ),
                                  // ),
                                ],
                              ),
                              _featured!.name == "yes"
                                  ? Text("Charges: $featuredAdPrice")
                                  : Column(),
                            ],
                          ),
                        ]),
                      )
                    : const Center(child: CircularProgressIndicator())
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
      appBar: const CustomAppBar(title: "Add service"),
      body: SingleChildScrollView(
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
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
