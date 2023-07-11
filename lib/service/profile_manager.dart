import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:square_web/bloc/contact/recent_search_contact_bloc.dart';
import 'package:square_web/bloc/contact/search_contacts_bloc.dart';

import 'package:square_web/bloc/message_bloc_event.dart';
import 'package:square_web/bloc/profile/player_profile_bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/command/command_feedback.dart';
import 'package:square_web/command/command_friend.dart';
import 'package:square_web/command/command_profile.dart';
import 'package:square_web/constants/server_error_code.dart';
import 'package:square_web/dao/ws_dao.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/feedback/report_problem_model.dart';
import 'package:square_web/model/feedback/suggest_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/service/room_manager.dart';

class ProfileManager {
  static ProfileManager? _instance;

  ProfileManager._internal();

  factory ProfileManager() => _instance ??= ProfileManager._internal();

  static void destroy() {
    _instance = null;
  }

  PlayerProfileBloc? currentPlayerProfileBloc;


  Future<int> updateProfile({ String? profileImgUrl, String? nftId, String? nickname, String? statusMessage }) async {
    if(nickname == "") {
      nickname = null;
    }
    if(statusMessage == "") {
      statusMessage = null;
    }
    UpdateProfileCommand command = UpdateProfileCommand(profileImgUrl: profileImgUrl, nftId: nftId, nickname: nickname, statusMessage: statusMessage);
    if(await DataService().request(command)) {

      MeModel().contact!.updateProfile(profileImgUrl, nftId, nickname, statusMessage);

      BlocManager.getBloc<MyProfileBloc>()!.add(Update());

      return command.status!;
    }

    return command.status!;
  }

  Future<String?> uploadThumbnail(Uint8List imageFile) async {
    LogWidget.debug("_pickImage : selected");
   /* if (await WebsocketDao().waitUntilConnect(3000) == false) {
      LogWidget.debug("waitUntilConnect failed");
      return null;
    }*/

    LogWidget.debug("waitUntilConnect : success");

    UploadThumbnailCommand uploadThumbnailCommand = UploadThumbnailCommand(image: imageFile, imageFormat: "png", objectKey: "profileImgUrl");
    if (await DataService().request(uploadThumbnailCommand)) {
      LogWidget.debug("uploadedPath : ${uploadThumbnailCommand.uploadedUrl}");

    }
    return uploadThumbnailCommand.uploadedUrl;
  }

  Future<bool> setProfileImgUrl({Uint8List? imageFile, String? nftId}) async {
    String? profileImgUrl;

    if(imageFile != null) {
      profileImgUrl = await uploadThumbnail(imageFile);

      if(profileImgUrl == null)
        return false;
    }

    SetUrlProfileCommand setUrlProfileCommand = SetUrlProfileCommand(MeModel().playerId, profileImgUrl, nftId: nftId);
    if (await DataService().request(setUrlProfileCommand)) {
      MeModel().contact?.modTime = DateTime.now().millisecondsSinceEpoch;
      MeModel().contact?.profileImgNftId = nftId;
      MeModel().contact?.profileImgUrl = profileImgUrl;

      BlocManager.getBloc<MyProfileBloc>()?.add(Update());
      return true;
    }

    return false;
  }

  Future<bool> setTargetNickname(ContactModel contactModel, String? nickname, PlayerProfileBloc? playerProfileBloc) async {

    if(nickname == null || nickname.trim() == "") {
      nickname= null;
    }

    SetTargetNicknameCommand command = SetTargetNicknameCommand(MeModel().playerId, contactModel.playerId, nickname);
    if(await DataService().request(command)) {

      LogWidget.debug("target nickname changed! ${nickname}");
      contactModel.targetNickname = nickname;
      ContactModelPool().playerMap[contactModel.playerId]?.targetNickname = nickname;
      playerProfileBloc?.add(ReloadPlayerProfileEvent(contactModel));

      ContactManager().updateContact(contactModel.playerId, nickname);
      RoomManager().updateTargetRoomMember(contactModel, nickname ?? contactModel.playerId);
      BlocManager.getBloc<ChatPageBloc>()?.add(Update());
      BlocManager.getBloc<RecentSearchContactBloc>()?.add(ReloadEvent());
      BlocManager.getBloc<SearchContactsBloc>()?.add(ReloadSearchContactsEvent());
      RoomManager().currentMessageBloc?.add(ReloadMessage());

      return true;
    } else {

      switch(command.resPacket!.getStatus()) {
        case ErrorCode.FOUND:
          break;
        default:
          break;
      }
    }

    return false;
  }

  Future<String?> reportProblemBySendFeedback(ReportProblemModel reportProblemModel) async {
    ReportProblemCommand command = ReportProblemCommand(reportProblemModel);
    await DataService().request(command);
    return command.feedbackId;
  }

  Future<String?> suggestBySendFeedback(SuggestModel suggestModel) async {
    SuggestCommand command = SuggestCommand(suggestModel);
    await DataService().request(command);
    return command.feedbackId;
  }

  Future<List<String>> uploadFileList(List<PlatformFile> fileList) async {

    UploadFileCommand command = UploadFileCommand(fileList);
    if (await DataService().request(command)) {
      LogWidget.debug("UploadFileCommand : ${command.uploadedUrlList}");

      return command.uploadedUrlList;
    }

    return [];
  }
}
