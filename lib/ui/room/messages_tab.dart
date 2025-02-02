import 'dart:convert';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/HelperFunction/chat.dart';
import 'package:retroshare/common/common_methods.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/ui/room/message_delegate.dart';
import 'package:retroshare/common/bottom_bar.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class MessagesTab extends StatefulWidget {
  final Chat chat;
  final bool isRoom;

  MessagesTab({this.chat, this.isRoom});

  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  TextEditingController msgController = TextEditingController();
  double _bottomBarHeight = appBarHeight;
  FocusScopeNode _focusNode;

  bool isShowSticker = false;
  @override
  void dispose() {
    msgController.dispose();
    super.dispose();
  }

  _onEmojiSelected(Emoji emoji) {
    msgController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: msgController.text.length));
  }

  _onBackspacePressed() {
    msgController
      ..text = msgController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: msgController.text.length));
  }

  _sendImage() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 250,
        maxHeight: 250);
    final bytes = image.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;
    if (mb < 3 && image != null) {
      var text = base64.encode(image.readAsBytesSync());
      text = "<img alt='Red dot (png)' src='data:image/png;base64,$text'/>";
      sendMessage(context, widget.chat?.chatId, text,
          (widget.isRoom ? ChatIdType.number3_ : ChatIdType.number2_));
    } else {
      Fluttertoast.showToast(
          msg: "Image Size is too large !",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isShowSticker = false;
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Consumer<RoomChatLobby>(
              builder: (context, messagesList, _) {
                dynamic msgList = (widget.chat?.chatId == null ||
                        messagesList.messagesList == null ||
                        messagesList.messagesList[widget.chat?.chatId] == null)
                    ? []
                    : messagesList.messagesList[widget.chat?.chatId].reversed
                        .toList();
                return Stack(
                  children: <Widget>[
                    ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: msgList == null ? 0 : msgList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return MessageDelegate(
                          data: msgList[index],
                          key: UniqueKey(),
                          bubbleTitle: widget.isRoom &&
                                  (msgList[index] != null) &&
                                  (msgList[index]
                                      .incoming) // Why msgList[index]?.incoming ?? false is not working??
                              ? getChatSenderName(context, msgList[index])
                              : null,
                        );
                      },
                    ),
                    Visibility(
                      visible: msgList?.isEmpty ?? true,
                      child: Center(
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: 250,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                    'assets/icons8/pluto-no-messages-1.png'),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25),
                                  child: Text(
                                      'It seems like there is no messages',
                                      style: Theme.of(context).textTheme.body2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          BottomBar(
            minHeight: _bottomBarHeight,
            maxHeight: _bottomBarHeight * 2.5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.insert_emoticon,
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Future.delayed(Duration(milliseconds: 15));
                      setState(() {
                        isShowSticker = !isShowSticker;
                      });
                    },
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xFFF5F5F5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        readOnly: isShowSticker,
                        onTap: () {
                          if (isShowSticker) {
                            setState(() {
                              isShowSticker = false;
                              Future.delayed(Duration(milliseconds: 15));
                            });
                          }
                          ;
                        },
                        controller: msgController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Type text...'),
                        style: Theme.of(context).textTheme.body2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.image,
                    ),
                    onPressed: () async {
                     await  _sendImage();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                    ),
                    onPressed: () {
                      if (msgController.text.length > 0)
                        sendMessage(
                            context,
                            widget.chat?.chatId,
                            msgController.text,
                            (widget.isRoom
                                ? ChatIdType.number3_
                                : ChatIdType.number2_));
                      msgController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
          Offstage(
            offstage: !isShowSticker,
            child: SizedBox(
              height: 250,
              child: buildSticker(),
            ),
          ),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildSticker() {
    return EmojiPicker(
        onEmojiSelected: (Category category, Emoji emoji) {
          _onEmojiSelected(emoji);
        },
        onBackspacePressed: _onBackspacePressed,
        config: const Config(
            columns: 7,
            emojiSizeMax: 32.0,
            verticalSpacing: 0,
            horizontalSpacing: 0,
            initCategory: Category.RECENT,
            bgColor: Color(0xFFF2F2F2),
            indicatorColor: Colors.blue,
            iconColor: Colors.grey,
            iconColorSelected: Colors.blue,
            progressIndicatorColor: Colors.blue,
            backspaceColor: Colors.blue,
            showRecentsTab: true,
            recentsLimit: 28,
            noRecentsText: 'No Recents',
            noRecentsStyle: TextStyle(fontSize: 20, color: Colors.black26),
            categoryIcons: CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL));
  }
}
