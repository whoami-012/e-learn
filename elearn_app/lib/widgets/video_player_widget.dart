import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoId;
  final bool isLocked;

  /// Called when the video finishes playing — use this to auto-advance lessons.
  final VoidCallback? onVideoEnded;

  /// Called on YouTube player errors (error code passed as argument).
  final ValueChanged<YoutubeError>? onError;

  const VideoPlayerWidget({
    required this.videoId,
    this.isLocked = false,
    this.onVideoEnded,
    this.onError,
    super.key,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late YoutubePlayerController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  // Strips full YouTube URLs down to the bare 11-char video ID.
  static String _cleanId(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri != null) {
      if (uri.queryParameters.containsKey('v')) return uri.queryParameters['v']!;
      if (uri.pathSegments.isNotEmpty) {
        final last = uri.pathSegments.last;
        if (last.length == 11) return last;
      }
    }
    return raw;
  }

  @override
  void initState() {
    super.initState();
    _initController(widget.videoId);
  }

  void _initController(String rawId) {
    final id = _cleanId(rawId);
    debugPrint('[VideoPlayer] Loading videoId: $id');

    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        playsInline: true,
        strictRelatedVideos: true,    // keeps recommended vids from other channels away
        showVideoAnnotations: false,
        enableCaption: false,
      ),
    );

    // ── Android fixes ──────────────────────────────────────────────────────
    // youtube_player_iframe uses webview_flutter internally.
    // We access webViewController here to apply two platform-level fixes
    // before the first request is made:
    //
    // 1. UA override: Android WebView appends 'wv' to its User-Agent.
    //    YouTube's CDN detects this and blocks the stream with "An error
    //    occurred. Please try again later." Replacing with a Chrome Mobile
    //    UA removes that signal.
    //
    // 2. MediaPlaybackRequiresUserGesture(false): without this the video
    //    thumbnail shows but the player never starts.
    //
    // Note: webViewController is annotated @internal by the package.
    // We suppress the lint warning here deliberately. If youtube_player_iframe
    // adds official UA/referrer configuration in a future release, remove this.
    // ignore: invalid_use_of_internal_member
    _controller.webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/124.0.6367.82 Mobile Safari/537.36',
      );

    // ignore: invalid_use_of_internal_member
    final platform = _controller.webViewController.platform;
    if (platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true); // remove before prod release
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
    // ───────────────────────────────────────────────────────────────────────

    // Stream-based events — this is the key advantage of youtube_player_iframe
    // over a raw WebView: typed state changes, errors, and position updates.
    _controller.stream.listen(
      (value) {
        if (!mounted) return;

        // Any active state = player loaded successfully
        if (value.playerState == PlayerState.playing ||
            value.playerState == PlayerState.paused ||
            value.playerState == PlayerState.cued) {
          if (_isLoading || _hasError) {
            setState(() { _isLoading = false; _hasError = false; });
          }
        }

        // Video finished — notify parent for auto-advance, analytics, etc.
        if (value.playerState == PlayerState.ended) {
          setState(() => _isLoading = false);
          widget.onVideoEnded?.call();
        }

        // YouTube IFrame API error (e.g. notEmbeddable, videoNotFound)
        if (value.error != YoutubeError.none) {
          debugPrint('[VideoPlayer] YouTube error: ${value.error}');
          widget.onError?.call(value.error);
          if (mounted) setState(() { _isLoading = false; _hasError = true; });
        }
      },
      onError: (e) {
        debugPrint('[VideoPlayer] Stream error: $e');
        if (mounted) setState(() { _isLoading = false; _hasError = true; });
      },
    );

    // Load the video. The controller queues this until the WebView is ready.
    _controller.loadVideoById(videoId: id);

    // Safety fallback: hide spinner after 10s if no state event arrives
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _controller.close(); // stops playback + releases the internal WebView
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _youtubeUrl =>
      'https://www.youtube.com/watch?v=${_cleanId(widget.videoId)}';

  String get _thumbnailUrl =>
      'https://img.youtube.com/vi/${_cleanId(widget.videoId)}/hqdefault.jpg';

  Future<void> _openInYouTube() async {
    final url = Uri.parse(_youtubeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ── Public control methods ────────────────────────────────────────────────
  // Expose these if you need programmatic control from the parent screen.

  Future<void> play()  => _controller.playVideo();
  Future<void> pause() => _controller.pauseVideo();
  Future<void> seekTo(Duration position) =>
      _controller.seekTo(seconds: position.inSeconds.toDouble());

  // ── Locked UI ─────────────────────────────────────────────────────────────

  Widget _buildLockedView() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, size: 36, color: Color(0xFFCBD5E1)),
              SizedBox(height: 8),
              Text(
                'Enroll to Unlock Video',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error UI ──────────────────────────────────────────────────────────────

  Widget _buildErrorView() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0F172A)),
            ),
            Container(color: Colors.black.withValues(alpha: 0.72)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_circle_outline_rounded,
                    size: 56,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Video unavailable.\nThis video may not allow embedding.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _openInYouTube,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Watch on YouTube'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Player UI ─────────────────────────────────────────────────────────────

  Widget _buildPlayerView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            YoutubePlayer(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.isLocked) return _buildLockedView();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _hasError ? _buildErrorView() : _buildPlayerView(),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextButton.icon(
            onPressed: _openInYouTube,
            icon: const Icon(Icons.play_circle_outline, size: 18),
            label: const Text(
              'Video not working? Open in YouTube',
              style: TextStyle(fontSize: 13, color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
