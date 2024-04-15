library;

///Package imports
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:provider/provider.dart';

///Project imports
import 'package:hms_room_kit/src/hls_viewer/hls_player_store.dart';
import 'package:hms_room_kit/src/meeting/meeting_store.dart';
import 'package:hms_room_kit/src/hls_viewer/hls_player_overlay_options.dart';
import 'package:hms_room_kit/src/hls_viewer/hls_waiting_ui.dart';
import 'package:hms_room_kit/src/layout_api/hms_theme_colors.dart';

///[HLSPlayer] is a component that is used to show the HLS Player
class HLSPlayer extends StatelessWidget {
  const HLSPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///We use the hlsAspectRatio from the [MeetingStore] to set the aspect ratio of the player
    ///By default the aspect ratio is 9:16
    return Selector<MeetingStore, bool>(
        selector: (_, meetingStore) => meetingStore.hasHlsStarted,
        builder: (_, hasHLSStarted, __) {
          return Stack(
            children: [
              ///Renders the HLS Player if the HLS has started
              ///Otherwise renders the waiting UI
              hasHLSStarted
                  ? Align(
                      alignment: Alignment.center,
                      child: Selector<HLSPlayerStore, Size>(
                          selector: (_, hlsPlayerStore) =>
                              hlsPlayerStore.hlsPlayerSize,
                          builder: (_, hlsPlayerSize, __) {
                            return AspectRatio(
                              aspectRatio:
                                  hlsPlayerSize.width / hlsPlayerSize.height,
                              child: InkWell(
                                onTap: () => context
                                    .read<HLSPlayerStore>()
                                    .toggleButtonsVisibility(),
                                splashFactory: NoSplash.splashFactory,
                                splashColor: HMSThemeColors.backgroundDim,
                                child: IgnorePointer(
                                  child: const HMSHLSPlayer(
                                    showPlayerControls: false,
                                  ),
                                ),
                              ),
                            );
                          }),
                    )
                  : Center(child: const HLSWaitingUI()),

              ///This renders the overlay controls for HLS Player
              Align(
                alignment: Alignment.center,
                child: Selector<HLSPlayerStore, bool>(
                    selector: (_, hlsPlayerStore) =>
                        hlsPlayerStore.isFullScreen,
                    builder: (_, isFullScreen, __) {
                      return isFullScreen
                          ? Selector<HLSPlayerStore, Size>(
                              selector: (_, hlsPlayerStore) =>
                                  hlsPlayerStore.hlsPlayerSize,
                              builder: (_, hlsPlayerSize, __) {
                                return AspectRatio(
                                  aspectRatio: hlsPlayerSize.width /
                                      hlsPlayerSize.height,
                                  child: HLSPlayerOverlayOptions(
                                    hasHLSStarted: hasHLSStarted,
                                  ),
                                );
                              })
                          : HLSPlayerOverlayOptions(
                              hasHLSStarted: hasHLSStarted);
                    }),
              ),
              Selector<HLSPlayerStore, HMSHLSPlaybackState>(
                selector: (_, hlsPlayerStore) =>
                    hlsPlayerStore.playerPlaybackState,
                builder: (_, state, __) {
                  return state == HMSHLSPlaybackState.BUFFERING
                      ? Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            color: HMSThemeColors.primaryDefault,
                            strokeWidth: 1,
                          ),
                        )
                      : const SizedBox();
                },
              )
            ],
          );
        });
  }
}
