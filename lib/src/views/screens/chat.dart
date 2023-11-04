import 'dart:io';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mime/mime.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helper/styles.dart';
import '../../controllers/message_controller.dart';
import '../widgets/chat_message_item.dart';

class ChatScreen extends StatefulWidget {
  String rideId;
  ChatScreen(this.rideId, {Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends StateMVC<ChatScreen> {
  late MessageController _con;
  String newMessage = '';
  File? _file;
  Timer? timer;
  bool gettingMessages = false;
  bool loading = false;
  TextEditingController _messageController = TextEditingController();

  final _picker = ImagePicker();
  final _listViewController = ScrollController();

  _ChatScreenState() : super(MessageController()) {
    _con = controller as MessageController;
  }

  @override
  void initState() {
    print('ride: ${widget.rideId}');
    refreshMessages();
    executaChecagemNovaMensagem();
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  void executaChecagemNovaMensagem() {
    timer = Timer.periodic(new Duration(seconds: 5), (timer) async {
      if (!gettingMessages) {
        gettingMessages = true;
        if (_con.messages.length < 1) {
          await refreshMessages();
        } else {
          await _con.listenForMessages(
            widget.rideId,
            lastMessage: _con.messages.last.createdAt,
          );
        }
        gettingMessages = false;
      }
    });
  }

  Future<void> refreshMessages() async {
    setState(() {
      _con.messages.clear();
      loading = true;
      gettingMessages = true;
    });
    await _con.listenForMessages(widget.rideId);
    setState(() {
      loading = false;
      gettingMessages = false;
    });
  }

  void _onImageButtonPressed(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _file = File(pickedFile.path);
      }
    });
  }

  void _scrollToEnd() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _listViewController.jumpTo(_listViewController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_con.needsScroll) {
      _scrollToEnd();
      _con.needsScroll = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context)!.ride} #${widget.rideId}',
          overflow: TextOverflow.fade,
          maxLines: 1,
          style: khulaBold.copyWith(letterSpacing: 1.3),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                loading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : _con.messages.length < 1
                        ? Expanded(
                            child: Center(
                              child: Text(
                                  AppLocalizations.of(context)!.noMessages),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              controller: _listViewController,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              itemCount: _con.messages.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                bool showNip = true;
                                if (index > 0 &&
                                    _con.messages[index].sender.id ==
                                        _con.messages[index - 1].sender.id) {
                                  showNip = false;
                                }
                                return ChatMessageItem(
                                  _con.messages[index],
                                  showNip: showNip,
                                );
                              },
                            ),
                          ),
              ],
            ),
          ),
          if (_file != null && lookupMimeType(_file!.path)!.startsWith('image'))
            Image.file(_file!, height: 100)
          else if (_file != null)
            Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 2),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 5),
                  Icon(
                    Icons.attach_file,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    _file!.path.split('/').last,
                    style: khulaBold.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      FontAwesomeIcons.xmark,
                      color: Theme.of(context).errorColor,
                    ),
                    onPressed: () => setState(
                      () {
                        _file = null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).bottomAppBarColor,
                      borderRadius: BorderRadius.circular(35.0),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 3),
                            blurRadius: 5,
                            color: Colors.grey)
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            keyboardType: TextInputType.text,
                            onChanged: (String value) {
                              newMessage = value;
                            },
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                contentPadding: EdgeInsets.all(5),
                                hintStyle: Theme.of(context).textTheme.caption,
                                hintText:
                                    AppLocalizations.of(context)!.enterAMessage,
                                border: InputBorder.none),
                          ),
                        ),
                        if (_file == null)
                          IconButton(
                            icon: Icon(FontAwesomeIcons.filePdf,
                                color: Theme.of(context).primaryColor),
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                              );
                              if (result != null) {
                                setState(() {
                                  _file = File(result.files.single.path!);
                                });
                              }
                            },
                          ),
                        _file == null
                            ? PopupMenuButton(
                                onSelected: (val) =>
                                    _onImageButtonPressed(val as ImageSource),
                                child: Icon(Icons.photo_camera,
                                    color: Theme.of(context).primaryColor,
                                    size: 30),
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: Row(
                                          children: [
                                            Icon(Icons.photo_camera,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            SizedBox(width: 5),
                                            Text(AppLocalizations.of(context)!
                                                .camera),
                                          ],
                                        ),
                                        value: ImageSource.camera,
                                      ),
                                      PopupMenuItem(
                                        child: Row(
                                          children: [
                                            Icon(Icons.image,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            SizedBox(width: 5),
                                            Text(AppLocalizations.of(context)!
                                                .gallery),
                                          ],
                                        ),
                                        value: ImageSource.gallery,
                                      ),
                                    ])
                            : _file != null &&
                                    lookupMimeType(_file!.path)!
                                        .startsWith('image')
                                ? IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Theme.of(context).primaryColor),
                                    onPressed: () => setState(
                                      () {
                                        _file = null;
                                      },
                                    ),
                                  )
                                : SizedBox(),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 5),
                _con.sendingMessage
                    ? Container(
                        width: 50,
                        padding: const EdgeInsets.only(left: 10, right: 5),
                        child: CircularProgressIndicator())
                    : Container(
                        width: 50,
                        padding: const EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle),
                        child: IconButton(
                          icon: Icon(Icons.send_rounded,
                              color: Theme.of(context).highlightColor),
                          onPressed: () async {
                            if (_file != null || newMessage.isNotEmpty) {
                              final tempFile = _file;
                              final tempMessage = newMessage;
                              setState(() {
                                _file = null;
                                newMessage = '';
                                _messageController.clear();
                              });
                              await _con.sendNewMessage(
                                widget.rideId,
                                msg: tempMessage,
                                file: tempFile,
                              );
                            }
                          },
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
