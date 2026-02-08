import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../../core/config/zego_config.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  /// Initialize ZegoCloud Call Kit with Signaling Plugin
  /// This should be called after a user logs in successfully.
  Future<void> onUserLogin(String userId, String userName) async {

    
    try {
      // CRITICAL: Use await to ensure initialization completes
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: ZegoConfig.appID,
        appSign: ZegoConfig.appSign,
        userID: userId,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
        
        // CRITICAL for Killed/Terminated state support
        notificationConfig: ZegoCallInvitationNotificationConfig(
          androidNotificationConfig: ZegoCallAndroidNotificationConfig(
            showOnFullScreen: true, // For Android 14+ (requests USE_FULL_SCREEN_INTENT)
            showOnLockedScreen: true, // To show when device is locked
            // fullScreenBackgroundAssetURL: 'assets/images/call_bg.png', // Use asset URL if needed
            callChannel: ZegoCallAndroidNotificationChannelConfig(
              channelID: "ZegoData",
              channelName: "Call Notifications",
              sound: 'default', // Use default system ringtone
              vibrate: true,
            ),
            missedCallChannel: ZegoCallAndroidNotificationChannelConfig(
              channelID: "ZegoMissedCall",
              channelName: "Missed Call Notifications",
            ),
          ),
          iOSNotificationConfig: ZegoCallIOSNotificationConfig(
            // systemCallingIconName: 'CallKitIcon',
          ),
        ),
      
      // Customize the invitation UI (optional)
      ringtoneConfig: ZegoCallRingtoneConfig(
        // incomingCallPath: "assets/ringtone/incoming.mp3", 
        // outgoingCallPath: "assets/ringtone/outgoing.mp3",
      ),
      
      // Configure call UI based on call type (audio or video)
      requireConfig: (ZegoCallInvitationData data) {
        var config = ZegoCallInvitationType.videoCall == data.type
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
            
        // CUSTOM UI CUSTOMIZATION
        // In 4.22.2, use backgroundBuilder instead of backgroundColor
        config.audioVideoView.backgroundBuilder = (context, size, user, extraInfo) {
          return Container(color: AppTheme.backgroundLight);
        };
        
        // Customize the audio/video view
        config.audioVideoView.showAvatarInAudioMode = true;
        config.audioVideoView.showSoundWavesInAudioMode = true;
        
        // CRITICAL: Enable camera and microphone for video calls
        if (ZegoCallInvitationType.videoCall == data.type) {
          config.turnOnCameraWhenJoining = true;
          config.turnOnMicrophoneWhenJoining = true;
        } else {
          config.turnOnCameraWhenJoining = false;
          config.turnOnMicrophoneWhenJoining = true;
        }
        
        // Customize Bottom Menu Bar
        config.bottomMenuBar.backgroundColor = Colors.white;
        config.bottomMenuBar.buttons = [
          ZegoCallMenuBarButtonName.toggleMicrophoneButton,
          ZegoCallMenuBarButtonName.hangUpButton,
          ZegoCallMenuBarButtonName.showMemberListButton,
          ZegoCallMenuBarButtonName.switchAudioOutputButton,
        ];
        
        // Customize Top Menu Bar
        config.topMenuBar.backgroundColor = Colors.transparent;
        config.topMenuBar.isVisible = true;

        // Avatar styling for a "charming" look
        config.avatarBuilder = (context, size, user, extraInfo) {
          final String initials = (user?.name.isNotEmpty == true) 
              ? user!.name[0].toUpperCase() 
              : "U";
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          );
        };

        // Note: memberConfig.waitingForResponseAppName is unavailable in this version config
        // Customizations for waiting screen can be done via ZegoCallInvitationUIConfig in init if needed

        return config;
      },
      );

    
    // Signaling connection happens asynchronously - no need to wait
    // The call UI will appear as soon as the connection is ready
    
    } on UnsupportedError catch (e) {
      // This is expected on web (Platform._operatingSystem not available)
      // The initialization still succeeds, so we continue

    } catch (e, stackTrace) {

    }
  }

  /// Send a call invitation to another user
  void sendCallInvitation(String targetUserId, String targetUserName) {

    
    try {
      // Use ZegoUIKitPrebuiltCallInvitationService directly (correct API for 4.22.2)

      
      ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [
          ZegoCallUser(targetUserId, targetUserName),
        ],
        isVideoCall: false, // Audio call
      );
      

    } catch (e, stackTrace) {

    }
  }

  /// Send a VIDEO call invitation to another user
  void sendVideoCallInvitation(String targetUserId, String targetUserName) {

    
    try {
      // Use ZegoUIKitPrebuiltCallInvitationService for video call

      
      ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [
          ZegoCallUser(targetUserId, targetUserName),
        ],
        isVideoCall: true, // Video call
      );
      

    } catch (e, stackTrace) {

    }
  }

  /// Uninitialize ZegoCloud Call Kit
  /// This should be called when the user logs out.
  void onUserLogout() {

    try {
      ZegoUIKitPrebuiltCallInvitationService().uninit();

    } catch (e) {

    }
  }
}
