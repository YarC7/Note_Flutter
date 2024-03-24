import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image/image.dart'as Img;
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:just_audio/just_audio.dart';
import 'package:screenshot/screenshot.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import 'package:uri_to_file/uri_to_file.dart';
import '../constants/common.dart';
import '../models/dateTimePicker.dart';
import '../models/note.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:path_provider/path_provider.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/notificate.dart';
import 'package:http/http.dart' as http;

class EditScreen extends StatefulWidget {
  final Note? note;
  const EditScreen({super.key, this.note});


  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  //main note
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  late final TextDirection textDirection;

  //image
  PlatformFile? pickedFile;
  String? imageUrl;
  String? pathname;

  //markdown
  String description ='';
  QuillController _controller = QuillController.basic();
  String? json;
  String? _base64 = "";

  //photedit
  bool? viewImage = true;
  String imagepath = "";
  Uint8List? bytesImage;


  //record
  Uint8List? bytesAudio;
  bool recordingPlayer = false;
  String? audioFileUrl ;
  bool isplaying = false;
  bool audioplayed = false;
  bool isPlaying = false;
  PlatformFile? pickSoundFile;
  File? fileAudio;
  String? fileName;
  String? recordBase64 = "";
  String? recordUrl;
  final destination = 'record/';

  //player
  final _player = AudioPlayer();


  //musicfile

  // bool soundPlayer = false;
  // String? soundFilePath ;
  // bool soundIsPlaying = false;
  // bool soundplayed = false;
  // String? fileNameSound;
  // File? fileSound;
  // final soundDestination = 'sound/';

  FirebaseStorage storage = FirebaseStorage.instance;
  ScreenshotController screenshotController = ScreenshotController();
  String _color ="";
  Uint8List? _screenshot;
  bool isDarkMode = true;
  FocusNode _editorFocusNode = FocusNode();
  DateTime scheduleTime = DateTime.now();
  MyStream myStream = new MyStream();
  String? screenshotsPath;


  @override
  void initState() {
    // TODO: implement initState
    if (widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);


      print("Style : ${json.toString()}");
      if (widget.note!.style !=null){
        json = widget.note!.style;
        //
        print("Style : ${json.toString()}");
        var myJSON = jsonDecode(json!);
        _controller = QuillController(
          document: Document.fromJson(myJSON),
          selection: TextSelection.collapsed(offset: 0),
        );
      }
      if (widget.note!.image != ""){
        setState(() {
          _base64 = widget.note!.image;
          bytesImage = const Base64Decoder().convert(_base64!);
        });
      }

      if (widget.note!.record != null && widget.note!.record != ""){
        setState(() {
          fileName = widget.note!.record;
          recordingPlayer = true;
        });
        downloadFile();
        _init();
      }
      if (widget.note!.color != ""){
        setState(() {
          _color = widget.note!.color;
        });
      }
      // if (widget.note!.sound != ""){
      //   setState(() {
      //     fileNameSound = widget.note!.record;
      //     soundPlayer = true;
      //   });
      //   downloadFile();
      // }

    }

    // initializeAudio();
    super.initState();

  }

  Future<void> _init() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });
    // Try to load audio from a source and catch any errors.
    if (audioFileUrl!= null ){
      try {
        // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
        await _player.setFilePath(audioFileUrl!);


      } catch (e) {
        print("Error loading audio source: $e");
      }
    }
    else {
      print("AudioFile URL is null");
    }

  }

  @override
  void dispose() {
    _player.dispose();
    myStream.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _player.stop();
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 10),
        child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                  [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            padding: const EdgeInsets.all(0),
                            icon: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: isDarkMode ? Colors.grey.shade800 : Colors.black,
                                      width: 3
                                  ),
                                  color: isDarkMode ? Colors.grey.shade800.withOpacity(.8) : Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child:  Icon(
                                Icons.arrow_back_ios_new,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,

                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    isDarkMode = !isDarkMode;
                                  });
                                },
                                padding: const EdgeInsets.all(0),
                                icon: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isDarkMode ? Colors.grey.shade800 : Colors.black,
                                          width: 3
                                      ),
                                      color: isDarkMode ? Colors.grey.shade800.withOpacity(.8) : Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(
                                    isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                )
                            ),
                            IconButton(
                                onPressed: () {
                                  shareDialog(context);
                                },
                                padding: const EdgeInsets.all(0),
                                icon: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isDarkMode ? Colors.grey.shade800 : Colors.black,
                                          width: 3
                                      ),
                                      color: isDarkMode ? Colors.grey.shade800.withOpacity(.8) : Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child:  Icon(
                                    Icons.share,
                                    color:isDarkMode ? Colors.white : Colors.black,
                                  ),
                                )
                            ),
                            IconButton(
                                onPressed: () {
                                  colorDiaglog(context);
                                },
                                padding: const EdgeInsets.all(0),
                                icon: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isDarkMode ? Colors.grey.shade800 : Colors.black,
                                          width: 3
                                      ),
                                      color: isDarkMode ? Colors.grey.shade800.withOpacity(.8) : Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child:  Icon(
                                    Icons.circle,
                                    color: _color != "" ? Color(int.parse(_color)):Colors.white,
                                  ),
                                )
                            ),
                            IconButton(
                                onPressed: () {
                                  alarmDialog(context);


                                },
                                padding: const EdgeInsets.all(0),
                                icon: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isDarkMode ? Colors.grey.shade800 : Colors.black,
                                          width: 3
                                      ),
                                      color: isDarkMode ? Colors.grey.shade800.withOpacity(.8) : Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child:  Icon(
                                    Icons.snapchat_outlined,
                                    color: Colors.white,
                                  ),
                                )
                            )
                      ],
                      ),],
                    ),
                    Expanded(
                        child: Screenshot(
                          controller: screenshotController,
                          child: ListView(
                              children: [
                                TextField(
                                  controller: _titleController,
                                  style:  TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 30),
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Title',
                                      hintStyle: TextStyle(color: Colors.grey, fontSize: 30)),
                                ),
                                TextField(
                                  focusNode: _editorFocusNode,
                                  onTap: (){
                                    textEditDialog(context);
                                  },
                                  maxLines: null,
                                  controller: _contentController,
                                  style:  TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Type something here',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      )
                                  ),
                                ),
                                // QuillProvider(
                                //     configurations: QuillConfigurations(
                                //       controller: _controller,
                                //       sharedConfigurations: const QuillSharedConfigurations(
                                //         locale: Locale('de'),
                                //       ),
                                //     ),
                                //     child:
                                //         Column(
                                //           children: [
                                //
                                //             Container(
                                //               height: 300,
                                //               decoration: BoxDecoration(
                                //                   border: Border.all(
                                //                       color: isDarkMode ? Colors.grey.shade800 : Colors.black,
                                //                       width: 3
                                //                   ),
                                //                   color: Colors.white,
                                //                   borderRadius: BorderRadius.circular(10)),
                                //               child: QuillEditor.basic(
                                //                 configurations: const QuillEditorConfigurations(
                                //                   readOnly: false,
                                //                 ),
                                //               ),
                                //             ),
                                //             Container(
                                //               decoration: BoxDecoration(
                                //                   border: Border.all(
                                //                       color: isDarkMode ? Colors.grey.shade800 : Colors.black,
                                //                       width: 3
                                //                   ),
                                //                   color: Colors.white,
                                //                   borderRadius: BorderRadius.circular(10)),
                                //               child: QuillToolbar(
                                //                 configurations:  QuillToolbarConfigurations(
                                //
                                //                     toolbarSize: 25,
                                //                     multiRowsDisplay: false
                                //                 ),
                                //               ),
                                //             ),
                                //           ],
                                //         )
                                //
                                //
                                // ),

                                // RichText(
                                //   text: TextSpan(
                                //     children: json!.map((item) {
                                //       final text = item['insert'].toString();
                                //       final attributes = item['attributes'] as Map<String, dynamic>;
                                //
                                //       if (attributes != null && attributes['list'] == 'unchecked') {
                                //         return TextSpan(
                                //           text: text,
                                //           style: TextStyle(
                                //             fontSize: 16.0, // Adjust the font size as needed
                                //             color: Colors.black, // Adjust the text color as needed
                                //             fontWeight: FontWeight.normal, // Adjust the font weight as needed
                                //           ),
                                //         );
                                //       } else {
                                //         // Handle other styling (e.g., checked list items) here if needed
                                //         return TextSpan(
                                //           text: text,
                                //           style: TextStyle(), // Apply default style here
                                //         );
                                //       }
                                //     }).toList(),
                                //   ),
                                // ),

                                if (bytesImage != null && viewImage == true)
                                  Container(
                                    child: Column(
                                      children : [
                                        InkWell(
                                          onTap: () {
                                            confirmDialog(context);
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child:
                                            Image.memory(bytesImage!,width: 300, height: 300),
                                          ),
                                        ),],
                                    ),
                                  ),
                                if (recordingPlayer == true && audioFileUrl !=null)
                                  Container(
                                    decoration:
                                    BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(25)),
                                    child:
                                    Column(
                                        children : [
                                          ControlButtons(_player),
                                          StreamBuilder<PositionData>(
                                            stream: _positionDataStream,
                                            builder: (context, snapshot) {
                                              final positionData = snapshot.data;
                                              return SeekBar(
                                                duration: positionData?.duration ?? Duration.zero,
                                                position: positionData?.position ?? Duration.zero,
                                                bufferedPosition:
                                                positionData?.bufferedPosition ?? Duration.zero,
                                                onChangeEnd: _player.seek,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            onPressed: () async {

                                              try {
                                                Reference storageReference = FirebaseStorage.instance.ref(destination).child('$fileName');
                                                storageReference.delete();
                                                setState(() {
                                                  recordingPlayer = false;
                                                  audioFileUrl = "";
                                                  fileName = "";
                                                });
                                              } catch (e) {
                                                print('error occured');
                                              }
                                            },
                                            icon: Container(
                                              width: 300,
                                              height: 300,
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius: BorderRadius.circular(25)),
                                              child: const Icon(
                                                Icons.delete_outlined,
                                                color: Colors.white,
                                                textDirection: TextDirection.ltr,
                                                size: 30,
                                              ),
                                            ),
                                          )
                                        ]
                                    ),
                                  )

                                // if (soundPlayer == true && soundFilePath !=null)
                                //   Column(
                                //       children : [
                                //         ControlButtons(_player),
                                //         StreamBuilder<PositionData>(
                                //           stream: _positionDataStream,
                                //           builder: (context, snapshot) {
                                //             final positionData = snapshot.data;
                                //             return SeekBar(
                                //               duration: positionData?.duration ?? Duration.zero,
                                //               position: positionData?.position ?? Duration.zero,
                                //               bufferedPosition:
                                //               positionData?.bufferedPosition ?? Duration.zero,
                                //               onChangeEnd: _player.seek,
                                //             );
                                //           },
                                //         ),
                                //       ]
                                //   )
                              ]
                          ),
                        )

                    ),
                    IconButton(
                      onPressed: () async {
                        widgetDialog(context);
                              // Handle file upload action
                      },
                      alignment: Alignment.bottomLeft,
                      iconSize: 57,
                      icon: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: isDarkMode ? Colors.grey.shade800 : Colors.black,
                                width: 3
                            ),
                            color: isDarkMode ? Colors.grey.shade800.withOpacity(.8) : Colors.white,
                            borderRadius: BorderRadius.circular(25)),
                        child: Icon(
                          Icons.add_box_outlined,
                          color: isDarkMode ? Colors.white : Colors.black,
                          textDirection: TextDirection.ltr,
                          size: 30,
                        ),
                      ),
                    ),
                  ]
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(
              context, [_titleController.text, _contentController.text,json,_base64,fileName,_color]);
        },
        elevation: 10,
        backgroundColor: isDarkMode ? Colors.grey.shade800.withOpacity(.8) : Colors.white,
        child: Icon(
          Icons.save,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      )
          );
  }



  Future<void> alarmDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              content: Container(
                height: 150,
                width: 350,

                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children : [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                            ElevatedButton(
                              child: const Text('Set Date Time'),
                              onPressed: () {
                                myStream.setNewData(context);

                                myStream.dateStream.listen((event) {
                                  setState(() {
                                    scheduleTime = event;
                                  });
                                });







                              },
                            ),
                          Container(
                            alignment: Alignment.center,
                            height: 50,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: isDarkMode ? Colors.black : Colors.white,
                                    width: 3
                                ),
                                color: isDarkMode ? Colors.white : Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child:
                            StreamBuilder(
                              stream: myStream.dateStream,
                              builder: (context, snapshot) => Text(

                                snapshot.hasData
                                    ? "${snapshot.data.year.toString()}-${snapshot.data.month.toString().padLeft(2,'0')}-${snapshot.data.day.toString().padLeft(2,'0')}:${snapshot.data.hour.toString().padLeft(2,'0')}:${snapshot.data.minute.toString().padLeft(2,'0')}" :
                                      "${scheduleTime.year.toString()}-${scheduleTime.month.toString().padLeft(2,'0')}-${scheduleTime.day.toString().padLeft(2,'0')}:${scheduleTime.hour.toString().padLeft(2,'0')}:${scheduleTime.minute.toString().padLeft(2,'0')}",
                                style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade800),
                              ),

                            )
                          ),

                        ],
                      ),

                      TextButton(
                        onPressed: () {
                          debugPrint('Notification Scheduled for $scheduleTime');
                          NotificationService().scheduleNotification(
                              title: _titleController.text,
                              body: _contentController.text,
                              scheduledNotificationDateTime: scheduleTime);
                        },
                        child: const Text(
                          'Set Time Remind',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),

                    ]

                ),
              )

          );
        });
  }


  Future<void> textEditDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
                side: BorderSide(
                  color: Colors.black,
                )),
            surfaceTintColor: Colors.black,
            elevation: 2,
            child:
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 30, 5, 10),
              child: QuillProvider(
                configurations: QuillConfigurations(
                  controller: _controller,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('de'),
                  ),
                ),
                child: Column(
                    children:[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              padding: const EdgeInsets.all(0),
                              icon: Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade800.withOpacity(.8),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(
                                  Icons.close_outlined,
                                  color: Colors.white,
                                ),
                              )
                          ),IconButton(
                              onPressed: () async{
                                setState(() {
                                  _contentController.text = _controller.document.toPlainText();
                                  json = serializeQuillDocumentToJson();
                                });
                                Navigator.pop(context);
                              },
                              padding: const EdgeInsets.all(0),
                              icon: Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade800.withOpacity(.8),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              )
                          ),
                        ],
                      ),

                      QuillToolbar(
                        configurations:  QuillToolbarConfigurations(
                            toolbarSize: 25,
                            // multiRowsDisplay: false
                        ),
                      ),
                      Expanded(
                          child:
                          Container(
                            child: QuillEditor.basic(
                              configurations: const QuillEditorConfigurations(
                                readOnly: false,
                              ),
                            ),
                          )
                      )
                    ]
                ),
              ),
            )
        );
      },
    );
  }

  Future<Uint8List> m4aFileToUint8List(String filePath) async {
    final file = File(filePath);
    try {
      final Uint8List uint8List = await file.readAsBytes();
      return uint8List;
    } catch (e) {
      print('Error reading the file: $e');
      return Uint8List(0); // Return an empty Uint8List or handle the error accordingly
    }
  }

  String getHexCode(String input){
    RegExp pattern = RegExp(r"0x([0-9a-fA-F]+)");

    // Use firstMatch to find the pattern in the input string
    Match? match = pattern.firstMatch(input);
    if (match != null) {
      // Extract the hexadecimal value
      String hexValue = match.group(1)!;

      // Add a '#' symbol if needed
      if (hexValue.length % 2 == 1) {
        hexValue = '0' + hexValue;
      }

      String hexCode = '0x' + hexValue;



      return hexCode; // This will print '#9c27b0'
    } else {
      return "0";
    }
  }

  Future<dynamic> shareWithText() async{
    String title = _titleController.text;
    String content = _contentController.text;
    await Share.share("$title \n $content");

  }



  Future<dynamic> shareDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              content: Container(
                height: 200,
                width: 500,

                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                            child:
                              ListTile(
                                onTap: () async {
                                  await shareWithText();
                                } ,
                                title: new Center(child: new Text("Share with text",
                                  style: new TextStyle(
                                      fontWeight: FontWeight.w500, fontSize: 25.0),)),
                            )),
                        Expanded(
                            child:
                            ListTile(
                              onTap: ()  {
                                takeScreenShot();
                              },
                              title: new Center(child: new Text("Share with image",
                                style: new TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 25.0),)),
                            )),
                        Expanded(
                            child:
                            ListTile(
                                onTap: () async {
                                  String imageUrl = await _startServerAndGetImageUrl();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Image URL'),
                                        content: Text(imageUrl),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              title: new Center(child: new Text("Share image online",
                                style: new TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 25.0),)),
                            )),
                        ElevatedButton(
                          child: const Text('Cancle'),
                          onPressed: () {
                            Navigator.of(context).pop(); //dismiss the color picker
                          },
                        )

                      ]
                  ),
              )

          );
        }
    );
  }



  void takeScreenShot()  {
    screenshotController
        .capture(delay: Duration(milliseconds: 10))
        .then((_screenshot) async {
      _saved(_screenshot);
      final buffer = _screenshot!.buffer;
      Share.shareXFiles(
        [
          XFile.fromData(
            buffer.asUint8List(_screenshot.offsetInBytes,_screenshot.lengthInBytes),
            name: "Share Image",
            mimeType: "image/png",
            ),
        ],
        subject: "Share Image"
      );
    }).catchError((onError) {
      print(onError);
    });
  }
  _saved(image) async {
    final result = await ImageGallerySaver.saveImage(image);
    if (result != null && result['isSuccess'] == true) {
      String? filePath = result['filePath']; // Access the 'filePath' key from the result Map
      if (filePath != null) {
        print("File Saved to Gallery at $filePath");
        setState(() {
          screenshotsPath = filePath;
        });
        // Now 'filePath' contains the path of the saved image file
        // Use this 'filePath' as needed in your application
      } else {
        print("File path is null");
      }
    } else {
      print("Failed to save file to gallery");
    }

    print("File Saved to Gallery");
  }

  Future<String> _startServerAndGetImageUrl() async {
    takeScreenShot();
    HttpServer? server;
    try {
      server = await HttpServer.bind('localhost', 8080);
      server.listen((HttpRequest request) async {

        final File file = await toFile(screenshotsPath!);

        request.response.headers.contentType = ContentType('image', 'jpeg');
        file.openRead().pipe(request.response);
      });
      return 'http://localhost:8080/note_image'; // Replace with your local image URL
    } catch (e) {
      print('Failed to start server: $e');
      return 'Server failed to start';
    }
  }


  Future<dynamic> colorDiaglog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40)),
            title: Text('Pick a color!'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: Colors.grey.shade800, //default color
                onColorChanged: (Color color){ //on color picked
                  setState(() {

                    _color = getHexCode((color.toString()));
                  });
                  print(_color);

                },
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('DONE'),
                onPressed: () {
                  Navigator.of(context).pop(); //dismiss the color picker
                },
              ),
            ],
          );
        }
    );
  }


  Future<dynamic> widgetDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.grey.shade800,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              elevation: 2,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () async {
                        selectfile();
                        // Handle file upload action
                      },
                      alignment: Alignment.bottomLeft,
                      iconSize: 57,
                      icon: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(25)),
                        child: const Icon(
                          Icons.image,
                          color: Colors.white,
                          textDirection: TextDirection.ltr,
                          size: 30,
                        ),
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () async {
                    //     selectfile();
                    //     // Handle file upload action
                    //   },
                    //   alignment: Alignment.bottomLeft,
                    //   iconSize: 57,
                    //   icon: Container(
                    //     width: 300,
                    //     height: 300,
                    //     decoration: BoxDecoration(
                    //         color: Colors.black,
                    //         borderRadius: BorderRadius.circular(25)),
                    //     child: const Icon(
                    //       Icons.image_outlined,
                    //       color: Colors.white,
                    //       textDirection: TextDirection.ltr,
                    //       size: 30,
                    //     ),
                    //   ),
                    // ),
                    // IconButton(
                    //   onPressed: () async {
                    //     selectfile();
                    //   },
                    //   alignment: Alignment.bottomLeft,
                    //   iconSize: 57,
                    //   icon: Container(
                    //     width: 300,
                    //     height: 300,
                    //     decoration: BoxDecoration(
                    //         color: Colors.black,
                    //         borderRadius: BorderRadius.circular(25)),
                    //     child: const Icon(
                    //       Icons.audiotrack,
                    //       color: Colors.white,
                    //       textDirection: TextDirection.ltr,
                    //       size: 30,
                    //     ),
                    //   ),
                    // ),
                    IconButton(
                      onPressed: () async {
                        recordDialog(context);
                      },
                      alignment: Alignment.bottomLeft,
                      iconSize: 57,
                      icon: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(25)),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          textDirection: TextDirection.ltr,
                          size: 30,
                        ),
                      ),
                    )
                  ]
              )
          );
        }
    );
  }


  Future<void> recordDialog(BuildContext context) async {
    await showDialog(context: context,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 200),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
                side: BorderSide(
                  color: Colors.black,
                )),
            surfaceTintColor: Colors.black,
            elevation: 2,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SocialMediaRecorder(
                      // maxRecordTimeInSecond: 5,
                      startRecording: () {
                        // function called when start recording
                      },
                      stopRecording: (_time) {
                        // function called when stop recording, return the recording time
                      },


                      sendRequestFunction: (soundFile, _time)  async {
                        print("the current path is ${soundFile.path}");
                        // String tempp = await convertM4AToMP3(soundFile.path);
                        // ByteData bytes = await rootBundle.load(soundFile.path); //load audio from assets
                        // Uint8List audiobytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
                        // Uint8List temp = await m4aFileToUint8List(soundFile.path);
                        String name = soundFile.path.split(Platform.pathSeparator).last;

                        setState(() {
                          recordingPlayer = true;
                          audioFileUrl = soundFile.path;
                          fileAudio = File(audioFileUrl!);
                          // bytesAudio = temp;
                          fileName = name;
                          // recordBase64 = base64.encode(bytesAudio!);




                        });
                        await _init();
                        await uploadFile();
                      },
                      encode: AudioEncoderType.AAC,
                    ),
                  ),
              ]
            )
          );
        }
    );}

  // Future uploadSoundFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //   if (result==null) return;
  //
  //   setState((){
  //     pickSoundFile = result.files.first;
  //   });
  //
  //   if (pickedFile != null){
  //     final soundFile = File(pickSoundFile!.path!);
  //     String name = soundFile.path.split(Platform.pathSeparator).last;
  //     try {
  //       final ref = storage
  //           .ref(soundDestination)
  //           .child('$fileNameSound');
  //       await ref.putFile(fileAudio!);
  //       setState(() {
  //         fileNameSound = name;
  //       });
  //     } catch (e) {
  //       print('error occured');
  //     }
  //   }
  //
  //
  // }

  Future uploadFile() async {


    Reference storageReference = FirebaseStorage.instance.ref(destination).child('$fileName');

    try {
      final ref = storage
          .ref(destination)
          .child('$fileName');
      await ref.putFile(fileAudio!);
      String url = await storageReference.getDownloadURL();
      setState(() {
        recordUrl = url;
      });
    } catch (e) {
      print('error occured');
    }
  }



  Future downloadFile() async {
    Reference storageReference = FirebaseStorage.instance.ref(destination).child('$fileName');
    String dir = (await getApplicationCacheDirectory()).path;

    File file = File(
        "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".m4a");
    storageReference.writeToFile(file);

    if (file != null){
      setState(() {
        audioFileUrl = file.path;
      });
    }

  }

  // Future downloadSoundFile() async {
  //   Reference storageReference = FirebaseStorage.instance.ref(soundDestination).child('$fileNameSound');
  //   String dir = (await getApplicationCacheDirectory()).path;
  //
  //   File file = File(
  //       "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".mp3");
  //   storageReference.writeToFile(file);
  //
  //   if (file != null){
  //     setState(() {
  //       soundFilePath = file.path;
  //     });
  //   }
  //
  // }

  Future deleteImageFromStorage(String imagePath) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(imagePath);
      await ref.delete();
      print('Image deleted from Firebase Storage.');
    } catch (e) {
      print('Error deleting image: $e');
    }
  }



  Future selectfile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result==null) return;

    setState((){
      pickedFile = result.files.first;
    });
    if (pickedFile!= null){
      final file = File(pickedFile!.path!);
      // final path = 'files/${pickedFile!.name}';
      // final ref = FirebaseStorage.instance.ref().child(path);
      // await ref.putFile(file);

      Uint8List imagebytes = await file.readAsBytes();

      final int maxImageSize = 1000 * 1024;

      if (imagebytes != null){
        if (imagebytes!.length > maxImageSize) {
          // Image size exceeds the threshold, resize it
          final Img.Image originalImage = Img.decodeImage(imagebytes!)!;
          final Img.Image resizedImage = Img.copyResize(originalImage, width: 800); // Adjust width as needed
          setState(() {
            imagebytes = Uint8List.fromList(Img.encodeJpg(resizedImage));
          });
        }
      }
      // Get the download URL of the uploaded image
      // final downloadURL = await ref.getDownloadURL();
      setState(() {
        // List<int> listImage = <int>[];
        //convert to bytes
        _base64 = base64.encode(imagebytes); //convert bytes to base64 string
        print(_base64);
        bytesImage = const Base64Decoder().convert(_base64!);
      });
    }
  }

  // void saveAudioFileFromCloud() async {
  //
  //   Uint8List bytes = base64.decode(recordBase64!);
  //   String dir = (await getApplicationCacheDirectory()).path;
  //   File file = File(
  //   "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".mp3");
  //   await file.writeAsBytes(bytes,flush: true);
  //
  //   await Future.delayed(Duration(seconds: 1));
  //   setState(() {
  //     audioFileUrl = file.path;
  //   });
  //   print(audioFileUrl);
  //   _init();
  // }



  void saveDataWithStyle() {
    final deltas = _controller.document.toDelta().toList();
    _contentController.text = ''; // Clear existing text

    for (final delta in deltas) {
      final style = delta.attributes; // Get formatting attributes from the delta
      final text = delta.data.toString(); // Get the text content from the delta
      _contentController.text += applyStyleToText(text, style);
    }
  }
  String applyStyleToText(String text, Map<String, dynamic>? style) {
    // Apply the formatting styles to the text
    String formattedText = text;

    if (style != null) {
      if (style['bold'] == true) {
        formattedText = '**$formattedText**'; // Apply bold formatting
      }
      if (style['italic'] == true) {
        formattedText = '_$formattedText'; // Apply italic formatting
      }
      // Add more style checks as needed
    }

    return formattedText;
  }
  String serializeQuillDocumentToJson() {
    final doc = _controller.document;
    final jsonList = doc.toDelta().toJson(); // Convert the Delta to a JSON format
    return jsonEncode(jsonList);
  }
  Future<String> base64ToImageFile(Uint8List byte) async{

    Img.Image image = Img.decodeImage(byte)!;

    final Directory tempDir = await getTemporaryDirectory();
    final String path = tempDir.path;

    final String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    final String filePath = '$path/$uniqueFileName.jpg';

    File imageFile = File(filePath);

    await imageFile.writeAsBytes(Img.encodePng(image));

    // Img.Image? image = Img.decodeImage(Uint8List.fromList(byte));
    // File imageFile = Img.decodeImage(Uint8List.fromList(byte)) as File;
    if (imageFile != null) {
      // File imageFile = File('/$path/temp/image.jpg'); // Set the desired file path
      // imageFile.writeAsBytesSync(Img.encodeJpg(image));
      return imageFile.path;

    } else {

      throw Exception('Failed to decode base64 string to image');

    }
  }
  Uint8List addTextOverlay(Uint8List editedImage, String text) {
    // Decode the edited image
    Img.Image? image = Img.decodeImage(editedImage);

    // Define text style and position
    final TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
    );

    final Img.Image imageWithText = Img.copyResize(image!, width: image.width);

    // Add text overlay
    Img.drawString(imageWithText, DateTime.now().toString(), font: Img.arial14);

    // Encode the final image as Uint8List
    return Uint8List.fromList(Img.encodePng(imageWithText));
  }
  Future<dynamic> confirmDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            elevation: 10,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () async {

                        var editedImage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageEditor(
                              image: bytesImage,
                            ),
                          ),
                        );
                        if (editedImage != null) {

                          setState(() {
                            bytesImage = editedImage;
                            String base64String = base64Encode(editedImage);
                            _base64 = base64String;
                          });
                        }
                      },
                      icon: const Icon(Icons.edit),
                      tooltip: "Edit Picture"),
                  IconButton(
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child:
                                Image.memory(bytesImage!),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.image_rounded),
                      tooltip: "View Picture"),
                  IconButton(
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Delete"),
                              content: Text("Are you sure you want to delete this picture?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Delete"),
                                  onPressed: () async {
                                    // deleteImageFromStorage(pathname!);
                                    setState(() {
                                        bytesImage = Uint8List.fromList([]);
                                        viewImage = false;
                                        _base64 = "";
                                    });// Delete the file
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(
                          Icons.delete_outline_outlined),
                          tooltip: "Delete Picture")
                ],
            ),
          );
        });
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Opens volume slider dialog
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: player.volume,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),
        // Opens speed slider dialog
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: player.speed,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}

