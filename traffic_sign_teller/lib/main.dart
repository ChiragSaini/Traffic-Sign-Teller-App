import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Sign Teller',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        accentColor: Colors.amberAccent,
      ),
      home: MyHomePage(title: 'Traffic Sign Teller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _pickedImage;
  String result = '';
  final String url_API =
      "https://trafficsigntellerapi.herokuapp.com/classifier/run";

  Future<void> selectFromGallery() async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 900,
    );
    if (image == null) {
      return;
    }
    setState(() {
      _pickedImage = image;
    });
  }

  Future<void> selectFromCamera() async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 900,
    );
    if (image == null) {
      return;
    }
    setState(() {
      _pickedImage = image;
    });
  }

  Future<String> predictImage(String imagePath) async {
    Dio dio = new Dio();
    FormData formdata = new FormData();
    var _image = File(imagePath);
    var uploadURL = url_API;
    formdata.files
        .add(MapEntry("photo", await MultipartFile.fromFile(_image.path)));
    var response = await dio.post(uploadURL,
        data: formdata,
        options: Options(method: 'POST', responseType: ResponseType.json));
    print(response.toString());
    return (response.toString());
  }

  void _showDialog(BuildContext context, String result) {
  final alert = AlertDialog(
    title: Text(result),
    actions: [FlatButton(child: Text("OK"), onPressed: () {
      Navigator.of(context).pop();
    })],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.save,
            ),
            label: Text(
              "Saved Signs",
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 500,
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: (_pickedImage == null)
                          ? Text(
                              "No Image Selected",
                              textAlign: TextAlign.center,
                            )
                          : Column(
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  height: 450,
                                  child: Image.file(
                                    _pickedImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                FlatButton(
                                  child: Text(
                                    "Predict Image",
                                  ),
                                  color: Theme.of(context).accentColor,
                                  onPressed: () async {
                                    predictImage(_pickedImage.path).then((response) {
                                      _showDialog(context, response.toString());
                                    });
                                    
                                  },
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton.icon(
                icon: Icon(
                  Icons.camera,
                ),
                label: Text(
                  "Take a Picture",
                  textAlign: TextAlign.center,
                ),
                color: Theme.of(context).accentColor,
                elevation: 0,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: selectFromCamera,
              ),
              RaisedButton.icon(
                icon: Icon(
                  Icons.filter,
                ),
                label: Text(
                  "Select from Gallery",
                  textAlign: TextAlign.center,
                ),
                color: Theme.of(context).accentColor,
                elevation: 0,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: selectFromGallery,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

