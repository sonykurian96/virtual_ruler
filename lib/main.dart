import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const markerHeight = 3.00;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: MainImageScreen(),
    );
  }
}

class MainImageScreen extends StatefulWidget {
  @override
  _MainImageScreenState createState() => _MainImageScreenState();
}

class _MainImageScreenState extends State<MainImageScreen> {
  Rect? _rect, _objectRect, _referenceRect;
  Offset? _start, _finish;
  PageController? _pageViewController = PageController();

  File? selectedImage;

  Future _getImage() async {
    final returnedImage =
        await ImagePicker().getImage(source: ImageSource.camera);

    if (returnedImage == null) {
      print("not taking photo");
      return;
    }
    setState(() {
      selectedImage = File(returnedImage.path);
      print("it took photo");
    });
  }

  @override
  Widget build(BuildContext context) {
    print("another........");
    return Scaffold(
      appBar: AppBar(
        title: Text("Measure Height"),
        centerTitle: true,
        elevation: 25,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (context, _) => Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: selectedImage != null
                        ? CustomPaint(
                            child: Image.file(
                              selectedImage!,
                            ),
                            foregroundPainter: MyRectPainter(rect: _rect),
                          )
                        : Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  elevation: 5, shadowColor: Colors.white),
                              icon: Icon(Icons.camera),
                              onPressed: () {
                                print("tapped");
                                _getImage();
                                Future.delayed(Duration(seconds: 10));
                              },
                              label: Text("measure"),
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onPanDown: (detail) {
                        setState(() {
                          _start = detail.localPosition;
                        });
                      },
                      onPanUpdate: (detail) {
                        setState(() {
                          _finish = detail.localPosition;
                          _rect = Rect.fromPoints(_start!, _finish!);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5.0),
            height: 51,
            child: Row(
              children: <Widget>[
                SizedBox(
                  height: double.infinity,
                  child: ElevatedButton(
                    child: Text(
                      "Back",
       
                    ),
                    onPressed: () {
                      _pageViewController!.previousPage(
                          duration: Duration(milliseconds: 151),
                          curve: Curves.ease);
                      setState(() {
                        selectedImage = null;
                      });
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: PageView(
                    controller: _pageViewController,
                    children: <Widget>[
                      ElevatedButton(
                        child: Text(
                          "Select Reference",
                     
                        ),
                        onPressed: () {
                          _referenceRect = _rect;
                          _pageViewController!.nextPage(
                              duration: Duration(milliseconds: 151),
                              curve: Curves.ease);
                          setState(() {
                            _rect = null;
                          });
                        },
                      ),
                      ElevatedButton(
                        child: Text(
                          "Select Object",
                 
                        ),
                        onPressed: () {
                          _objectRect = _rect;
                          _pageViewController!.nextPage(
                              duration: Duration(milliseconds: 151),
                              curve: Curves.ease);
                          setState(() {
                            _rect = null;
                          });
                        },
                      ),
                      ElevatedButton(
                        child: Text(
                          "Show Result",
                
                        ),
                        onPressed: () async {
                          print("object height: ${_objectRect!.height}");
                          print("reference height: ${_referenceRect!.height}");

                          var objectLength = _objectRect!.height /
                              (_referenceRect!.height / markerHeight);
                          
                          objectLength =
                              double.parse(objectLength.toStringAsFixed(2));
                          
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "Calculation Completed!",
                                    ),
                                    ListTile(
                                      leading: Text("Object Height:"),
                                      title: Text("$objectLength"),
                                      trailing: Text("In"),
                                    ),
                               
                                    ElevatedButton(
                                      child: Text(
                                        "Done",

                                      
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      // body: selectedImage != null? Image.file(selectedImage!) : Text("oh no!!!")
    );
  }
}

// class Original extends StatefulWidget {
//   const Original({Key? key}) : super(key: key);

//   @override
//   State<Original> createState() => _OriginalState();
// }

// class _OriginalState extends State<Original> {
//   Rect? _rect, _objectRect, _referenceRect;
//   Offset? _start, _finish;
//   PageController? _pageViewController = PageController();

//   @override
//   Widget build(BuildContext context) {
//     return ;
//   }
// }

class MyRectPainter extends CustomPainter {
  MyRectPainter({required this.rect});
  final Rect? rect;

  @override
  void paint(Canvas canvas, Size size) {
    if (rect != null) {
      canvas.drawRect(
          rect!,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.green);
    } else {
      canvas.drawRect(Rect.fromPoints(Offset(0, 0), Offset(0, 0)), Paint());
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
