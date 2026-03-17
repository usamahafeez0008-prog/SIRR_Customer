import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/model/ChatVideoContainer.dart';
import 'package:customer/model/conversation_model.dart';
import 'package:customer/model/inbox_model.dart';
import 'package:customer/themes/app_colors.dart';

import 'package:customer/ui/chat_screen/FullScreenImageViewer.dart';
import 'package:customer/ui/chat_screen/FullScreenVideoViewer.dart';

import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../dashboard_screen.dart';

class ChatScreens extends StatefulWidget {
  final String? orderId;
  final String? customerId;
  final String? customerName;
  final String? customerProfileImage;
  final String? driverId;
  final String? driverName;
  final String? driverProfileImage;
  final String? token;

  const ChatScreens(
      {Key? key,
      this.orderId,
      this.customerId,
      this.customerName,
      this.driverName,
      this.driverId,
      this.customerProfileImage,
      this.driverProfileImage,
      this.token})
      : super(key: key);

  @override
  State<ChatScreens> createState() => _ChatScreensState();
}

class _ChatScreensState extends State<ChatScreens> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    setSeen();
  }

  Future<void> setSeen() async {
    FireStoreUtils.setDriverChatSeen(
        orderId: widget.orderId ?? '', driverId: widget.driverId ?? '');
  }

  @override
  void dispose() {
    FireStoreUtils.stopDriverSeenListener();
    super.dispose();
  }

  Future<void> startRecording() async {
    if (await record?.hasPermission() == true) {
      final dir = await getTemporaryDirectory();
      recordedFilePath =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await record?.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 44100,
            bitRate: 128000,
            numChannels: 1,
          ),
          path: recordedFilePath!);
    }
  }

  AudioRecorder? record = AudioRecorder();
  bool isStartRecording = false;
  String? recordedFilePath;

  Future<String?> stopRecording() async {
    return await record?.stop();
  }

  final player = AudioPlayer();
  Future<void> playVoice(String url) async {
    await player.setUrl(url);
    player.play();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0,
        backgroundColor: themeChange.getThem() ? AppColors.darkBackground : AppColors.lightprimary,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.offAll(DashBoardScreen()),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    height: 40,
                    width: 40,
                    imageUrl: widget.driverProfileImage ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                    errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.driverName.toString(),
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  /*Text(
                    "#${widget.orderId.toString()}",
                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w400),
                  ),*/
                ],
              ),
            ),
          ],
        ),
       /* actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],*/
      ),

      backgroundColor: themeChange.getThem() ? AppColors.darkBackground : AppColors.moroccoBackground,
      body: Padding(
        padding: const EdgeInsets.only(left: 0.0, right: 0, bottom: 8),

        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(CollectionName.chat)
                        .doc(widget.orderId)
                        .collection("thread")
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Constant.loader(
                            isDarkTheme: themeChange.getThem());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return SizedBox();
                      }
                      final docs = snapshot.data!.docs;
                      return ListView.builder(
                          reverse: true,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            ConversationModel inboxModel =
                                ConversationModel.fromJson(
                                    docs[index].data() as Map<String, dynamic>);
                            return chatItemView(
                                inboxModel.senderId ==
                                    FireStoreUtils.getCurrentUid(),
                                inboxModel);
                          });
                    }),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  "I'm Coming",
                  "I'm Here",
                  "I'm looking for you",
                  "Traffic jams",
                  "Ok",
                ].map((text) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        _sendMessage(text.tr, null, '', 'text');
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: themeChange.getThem() ? AppColors.darkTextField : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (themeChange.getThem() ? AppColors.moroccoGreen : AppColors.moroccoRed).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          text.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: themeChange.getThem() ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: themeChange.getThem() ? AppColors.darkTextField : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    /*IconButton(
                      onPressed: _onCameraClick,
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        color: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightprimary,
                        size: 26,
                      ),
                    ),*/
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.send,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller: _messageController,
                        cursorColor: AppColors.lightprimary,
                        decoration: InputDecoration(
                          hintText: isStartRecording ? 'Recording...'.tr : '    Type message...'.tr,
                          hintStyle: GoogleFonts.outfit(
                            color: isStartRecording ? AppColors.moroccoRed : Colors.grey[500],
                            fontWeight: isStartRecording ? FontWeight.bold : FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onSubmitted: (value) async {
                          if (_messageController.text.isNotEmpty) {
                            _sendMessage(_messageController.text, null, '', 'text');
                            _messageController.clear();
                          }
                        },
                      ),
                    ),
                    /*GestureDetector(
                      onLongPress: () async {
                        setState(() => isStartRecording = true);
                        await startRecording();
                      },
                      onLongPressUp: () async {
                        setState(() => isStartRecording = false);
                        final path = await stopRecording();
                        if (path != null) {
                          ShowToastDialog.showLoader("Please wait");
                          String? url = await Constant().uploadVoiceMessage(path);
                          final duration = await player.setFilePath(path);
                          _sendMessage(_messageController.text, Url(url: url), '', 'voice', voiceTimer: duration?.inSeconds);
                          ShowToastDialog.closeLoader();
                          _messageController.clear();
                          setState(() {});
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: isStartRecording 
                            ? AppColors.moroccoRed.withOpacity(0.1) 
                            : Colors.transparent,
                          child: Icon(
                            Icons.mic,
                            color: isStartRecording ? AppColors.moroccoRed : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),*/
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: IconButton(
                        onPressed: () async {
                          if (_messageController.text.isNotEmpty) {
                            _sendMessage(_messageController.text, null, '', 'text');
                            _messageController.clear();
                          } else {
                            ShowToastDialog.showToast("Please enter text".tr);
                          }
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.lightprimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40,)

          ],
        ),
      ),
    );
  }

  Widget chatItemView(bool isMe, ConversationModel data) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      height: 30,
                      width: 30,
                      imageUrl: widget.driverProfileImage ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                      errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                    ),
                  ),
                ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: isMe 
                      ? AppColors.lightprimary 
                      : (themeChange.getThem() ? AppColors.darkGray : Colors.grey[200]),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 5),
                      bottomRight: Radius.circular(isMe ? 5 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.messageType == "text")
                        Text(
                          data.message.toString(),
                          style: GoogleFonts.outfit(
                            color: isMe ? Colors.white : (themeChange.getThem() ? Colors.white : Colors.black87),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        )
                      else if (data.messageType == "image")
                        GestureDetector(
                          onTap: () => Get.to(FullScreenImageViewer(imageUrl: data.url!.url)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Hero(
                              tag: data.url!.url,
                              child: CachedNetworkImage(
                                imageUrl: data.url!.url,
                                placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                        )
                      else if (data.messageType == "voice")
                        VoiceBubble(
                          url: data.url!.url,
                          durationSec: data.recordingTimer ?? 0,
                          isme: isMe,
                        )
                      else
                        IconButton(
                          onPressed: () => Get.to(FullScreenVideoViewer(
                            heroTag: data.id.toString(),
                            videoUrl: data.url!.url,
                          )),
                          icon: const Icon(Icons.play_circle_fill_rounded, size: 40, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
              if (isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      height: 30,
                      width: 30,
                      imageUrl: widget.customerProfileImage ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                      errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : 42,
              right: isMe ? 42 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Constant.dateAndTimeFormatTimestamp(data.createdAt),
                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[500]),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    data.seen == true ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 14,
                    color: data.seen == true ? Colors.blue : Colors.grey[500],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(
      String message, Url? url, String videoThumbnail, String messageType,
      {int? voiceTimer}) async {
    List<String> senderReceiverId = [widget.driverId!, widget.customerId!];
    InboxModel inboxModel = InboxModel(
        senderReceiverId: senderReceiverId,
        lastSenderId: widget.customerId,
        senderId: widget.customerId,
        receiverId: widget.driverId,
        createdAt: Timestamp.now(),
        orderId: widget.orderId,
        lastMessage: _messageController.text,
        lastMessageType: messageType,
        type: 'userchat');

    await FireStoreUtils.addInBox(inboxModel);

    ConversationModel conversationModel = ConversationModel(
        id: const Uuid().v4(),
        message: message,
        senderId: FireStoreUtils.getCurrentUid(),
        receiverId: widget.driverId,
        createdAt: Timestamp.now(),
        url: url,
        orderId: widget.orderId,
        messageType: messageType,
        videoThumbnail: videoThumbnail,
        recordingTimer: voiceTimer,
        seen: false);

    if (url != null) {
      if (url.mime.contains('image')) {
        conversationModel.message = "sent an image";
      } else if (url.mime.contains('video')) {
        conversationModel.message = "sent an Video";
      } else if (url.mime.contains('audio')) {
        conversationModel.message = "Sent a audio message";
      } else if (messageType == 'voice') {
        conversationModel.message = "Sent a voice message";
      }
    }

    await FireStoreUtils.addChat(conversationModel);

    Map<String, dynamic> playLoad = <String, dynamic>{
      "type": "chat",
      "driverId": widget.driverId,
      "customerId": widget.customerId,
      "orderId": widget.orderId,
    };

    SendNotification.sendOneNotification(
        title:
            "${widget.customerName} ${messageType == "image" ? messageType == "video" ? messageType == "voice" ? "sent voice record to you" : "sent video to you" : "sent image to you" : "sent message to you"}",
        body: conversationModel.message.toString(),
        token: widget.token.toString(),
        payload: playLoad);
  }

  final ImagePicker _imagePicker = ImagePicker();

  void _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'Send Media'.tr,
        style: const TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Get.back();
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              Url url = await Constant()
                  .uploadChatImageToFireStorage(File(image.path));
              _sendMessage('', url, '', 'image');
            }
          },
          child: Text("Choose image from gallery".tr),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? galleryVideo =
                await _imagePicker.pickVideo(source: ImageSource.gallery);
            if (galleryVideo != null) {
              ChatVideoContainer? videoContainer = await Constant()
                  .uploadChatVideoToFireStorage(File(galleryVideo.path));
              if (videoContainer != null) {
                _sendMessage('', videoContainer.videoUrl,
                    videoContainer.thumbnailUrl, 'video');
              } else {
                ShowToastDialog.showToast("Message sent failed");
              }
            }
          },
          child: Text("Choose video from gallery".tr),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              Url url = await Constant()
                  .uploadChatImageToFireStorage(File(image.path));
              _sendMessage('', url, '', 'image');
            }
          },
          child: Text("Take a Photo".tr),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? recordedVideo =
                await _imagePicker.pickVideo(source: ImageSource.camera);
            if (recordedVideo != null) {
              ChatVideoContainer? videoContainer = await Constant()
                  .uploadChatVideoToFireStorage(File(recordedVideo.path));
              if (videoContainer != null) {
                _sendMessage('', videoContainer.videoUrl,
                    videoContainer.thumbnailUrl, 'video');
              } else {
                ShowToastDialog.showToast("Message sent failed");
              }
            }
          },
          child: Text("Record video".tr),
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          'Cancel'.tr,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}

class VoiceBubble extends StatefulWidget {
  final bool? isme;
  final String url;
  final int durationSec;
  const VoiceBubble(
      {super.key,
      required this.isme,
      required this.url,
      required this.durationSec});

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  final player = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _listenAudio();
  }

  void _listenAudio() {
    player.playerStateStream.listen((state) {
      final processingState = state.processingState;
      setState(() => isPlaying = state.playing);
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        setState(() => isLoading = true);
      }
      if (processingState == ProcessingState.ready) {
        setState(() {
          isLoading = false;
          isPlaying = true;
        });
      }
      if (processingState == ProcessingState.completed) {
        setState(() {
          isLoading = false;
          isPlaying = false;
        });
      }

      log("IsPlaying :: $isPlaying");
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Column(
      children: [
        IconButton(
          icon: isLoading == true
              ? CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      themeChange.getThem() ? Colors.black : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Constant.loader(
                        strokeWidth: 2, isDarkTheme: themeChange.getThem()),
                  ))
              : isPlaying
                  ? CircleAvatar(
                      radius: 20,
                      backgroundColor: widget.isme == true
                          ? themeChange.getThem()
                              ? Colors.black
                              : Colors.white
                          : themeChange.getThem()
                              ? Colors.white
                              : Colors.black,
                      child: Icon(
                        Icons.pause,
                        color: widget.isme != true
                            ? themeChange.getThem()
                                ? Colors.black
                                : Colors.white
                            : themeChange.getThem()
                                ? Colors.white
                                : Colors.black,
                      ))
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: widget.isme == true
                          ? themeChange.getThem()
                              ? Colors.black
                              : Colors.white
                          : Colors.black,
                      child: Icon(
                        Icons.play_arrow,
                        color: widget.isme != true
                            ? Colors.white
                            : themeChange.getThem()
                                ? Colors.white
                                : Colors.black,
                      )),
          onPressed: () async {
            if (isPlaying) {
              await player.pause();
              setState(() {
                isPlaying = false;
              });
            } else {
              await player.setUrl(widget.url);
              await player.play();
            }
            setState(() {});
          },
        ),
        Text(Constant().formatDuration(widget.durationSec),
            style: GoogleFonts.poppins(
                fontSize: 10,
                color: widget.isme == true
                    ? themeChange.getThem()
                        ? Colors.black
                        : Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w400)),
      ],
    );
  }
}
