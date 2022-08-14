typedef LoadingProgress = void Function(PlaybackDisposition disposition);

void noProgress(PlaybackDisposition disposition) {}

///===============================================================================================
class PlaybackDisposition {
  final PlaybackDispositionState state;
  final double progress;
  final Duration duration;
  final Duration position;

  PlaybackDisposition.zero()
      : state = PlaybackDispositionState.init,
        progress = 1.0,
        position = Duration(seconds: 0),
        duration = Duration(seconds: 0);

  PlaybackDisposition(
      this.state, {
        this.progress = 1.0,
        this.position = Duration.zero,
        this.duration = Duration.zero,
      });

  PlaybackDisposition.init()
      : state = PlaybackDispositionState.init,
        progress = 0.0,
        position = Duration.zero,
        duration = Duration.zero;

  PlaybackDisposition.preload()
      : state = PlaybackDispositionState.preload,
        progress = 0.0,
        position = Duration.zero,
        duration = Duration.zero;

  PlaybackDisposition.loading({required this.progress})
      : state = PlaybackDispositionState.loading,
        position = Duration.zero,
        duration = Duration.zero;

  PlaybackDisposition.loaded()
      : state = PlaybackDispositionState.loaded,
        progress = 1.0,
        position = Duration.zero,
        duration = Duration.zero;

  PlaybackDisposition.error()
      : state = PlaybackDispositionState.error,
        progress = 1.0,
        position = Duration.zero,
        duration = Duration.zero;

  PlaybackDisposition.recording({required this.duration})
      : state = PlaybackDispositionState.recording,
        progress = 1.0,
        position = Duration.zero;

  @override
  String toString() {
    return 'duration: $duration, '
        'position: $position';
  }
}
///===============================================================================================
enum PlaybackDispositionState {
  init,
  preload,
  loading,
  loaded,
  error,
  playing,
  stopped,
  recording
}