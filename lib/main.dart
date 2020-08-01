import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:loading_gifs/loading_gifs.dart';
import 'package:mime_type/mime_type.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  bool _isLoadingChoose = false;
  bool _isLoadingUpload = false;
  List<File> listFiles = new List<File>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: !_isLoadingUpload
              ? <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: RaisedButton(
                          onPressed: () {
                            getImage();
                          },
                          color: Colors.white,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(7.0)),
                          child: SizedBox(
                            width: 90,
                            height: 90,
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.deepOrange,
                                size: 30.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ConstrainedBox(
                      constraints: new BoxConstraints(
                        minHeight: 5.0,
                        minWidth: 5.0,
                        maxHeight: 500.0,
                        maxWidth: 500.0,
                      ),
                      child: Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: _isLoadingChoose == true
                            ? FutureBuilder(
                                future: getListImages(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                    case ConnectionState.waiting:
                                      return new Text('loading...');
                                    default:
                                      if (snapshot.hasError)
                                        return new Text('${snapshot.error}');
                                      else
                                        return createListView(
                                            context, snapshot);
                                  }
                                },
                              )
                            : Text(""),
                      )),
                  SizedBox(
                      height: 40,
                      child: RaisedButton(
                          onPressed: uploadImages,
                          textColor: Colors.white,
                          color: Colors.red,
                          padding: const EdgeInsets.all(8.0),
                          child: new Text(
                            "Upload",
                          )))
                ]
              : <Widget>[
                  Center(
                      child: Image.asset(cupertinoActivityIndicator, scale: 5))
                ],
        ));
  }

  Future getImage() async {

    List<File> resultList = await FilePicker.getMultiFile(
      type: FileType.custom,
      allowedExtensions: ['jpeg', 'png'],
    );

    setState(() {
      _isLoadingChoose = true;
      listFiles.clear();
      listFiles.addAll(resultList);
    });
  }

  Future<List<File>> getListImages() async {
    return listFiles;
  }

  Future uploadImages() async {
    setState(() {
      _isLoadingUpload = true;
    });
    var request = http.MultipartRequest('POST',
        Uri.parse("https://fashionshopuit-server.azurewebsites.net/upload"));

    for (File fPath in listFiles) {
      List<String> typeImage = mime(fPath.path).split("/");
      request.files.add(await http.MultipartFile.fromPath(
          'multi-files', fPath.path,
          contentType: new MediaType(typeImage[0], typeImage[1])));
    }

    var res = await request.send();

    print(await res.stream.bytesToString());

    setState(() {
      listFiles.clear();
      _isLoadingUpload = false;
    });
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return Text("error createListView");
    }

    if (!snapshot.hasData) {
      return Text("");
    }

    List<File> values = snapshot.data;

    return new ListView.builder(
      shrinkWrap: true,
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        return new Column(
          children: <Widget>[
            Image.file(
              values[index],
              width: 300,
              height: 100,
            ),
            SizedBox(
              height: 10,
            ),
          ],
        );
      },
    );
  }
}
