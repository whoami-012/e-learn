import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VideoPlayerWidget
//
// Uses a raw WebView that loads an inline HTML page containing a YouTube
// <iframe> embed.  This is the approach Google's own documentation recommends
// for mobile WebView clients:
//
//   "Mobile app with local HTML file: setting the `baseUrl` parameter will
//    set the Referer. Use Android `loadDataWithBaseURL` /
//    iOS `loadHTMLString:baseURL:`"
//   — https://developers.google.com/youtube/terms/required-minimum-functionality
//
// Key decisions:
//   1. baseUrl = 'https://www.youtube-nocookie.com'
//      → Android internally calls `loadDataWithBaseURL`, which sets the HTTP
//        Referer header to this value on every sub-request the player makes.
//      → `youtube-nocookie.com` is the privacy-enhanced embed domain that
//        YouTube also uses as its own iframe origin, so it is always trusted.
//   2. <meta name="referrer" content="strict-origin-when-cross-origin">
//      → Instructs Chromium to send the origin in the Referer header even on
//        cross-origin requests (YouTube ↔ googlevideo CDN).
//   3. referrerpolicy="strict-origin-when-cross-origin" on the <iframe>
//      → Belt-and-suspenders: the iframe element itself also signals the policy.
//   4. Chrome Mobile User-Agent (no "wv" token)
//      → Removes the WebView fingerprint that YouTube's CDN uses to block
//        embedded players.
// ─────────────────────────────────────────────────────────────────────────────

class VideoPlayerWidget extends StatefulWidget {
  final String videoId;
  final bool isLocked;

  /// Called when the video finishes — use this to auto-advance lessons.
  final VoidCallback? onVideoEnded;

  const VideoPlayerWidget({
    required this.videoId,
    this.isLocked = false,
    this.onVideoEnded,
    super.key,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;

  // Strips full YouTube URLs down to the bare 11-char video ID.
  static String _cleanId(String raw) {
    final value = raw.trim();
    final uri = Uri.tryParse(value);
    if (uri != null) {
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v']!;
      }
      if (uri.pathSegments.isNotEmpty) {
        final last = uri.pathSegments.last;
        if (last.length == 11) return last;
      }
    }
    return value;
  }

  // Builds the HTML that hosts the YouTube iframe.
  // The origin and referrerpolicy attributes are the critical identity signals.
  String _buildHtml(String videoId) {
    // Use youtube-nocookie.com embed URL for privacy-enhanced mode and
    // to match the baseUrl origin we set below.
    final embedUrl = 'https://www.youtube-nocookie.com/embed/$videoId'
        '?autoplay=0'
        '&playsinline=1'
        '&rel=0'
        '&modestbranding=1'
        '&enablejsapi=1'
        '&origin=https://www.youtube-nocookie.com';

    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <!--
    strict-origin-when-cross-origin: sends the full origin (scheme + host) as
    Referer on cross-origin requests, which is exactly what YouTube requires to
    identify the embedding client.
  -->
  <meta name="referrer" content="strict-origin-when-cross-origin">
  <meta name="viewport"
        content="width=device-width, initial-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
    .container {
      position: relative;
      width: 100%;
      padding-top: 56.25%; /* 16:9 aspect ratio */
    }
    iframe {
      position: absolute;
      top: 0; left: 0;
      width: 100%; height: 100%;
      border: none;
    }
  </style>
</head>
<body>
  <div class="container">
    <iframe
      src="$embedUrl"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      allowfullscreen
      referrerpolicy="strict-origin-when-cross-origin">
    </iframe>
  </div>
</body>
</html>''';
  }

  @override
  void initState() {
    super.initState();
    _initWebView(widget.videoId);
  }

  void _initWebView(String rawId) {
    final id = _cleanId(rawId);
    debugPrint('[VideoPlayer] Loading videoId: $id');

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Chrome Mobile UA — removes the "wv" (WebView) token that YouTube's
      // CDN detects and uses to block embedded playback.
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/124.0.6367.82 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('[VideoPlayer] WebResource error: ${error.description}');
            // Ignore sub-resource errors (ads, tracking pixels, etc.)
            // Only flag main-frame failures.
            if (error.isForMainFrame == true) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              }
            }
          },
        ),
      );

    // Android-specific tweaks
    final platform = _webViewController.platform;
    if (platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true); // remove before prod
      platform.setMediaPlaybackRequiresUserGesture(false);
    }

    // Load the HTML string with baseUrl = youtube-nocookie.com.
    // Flutter's WebViewController.loadHtmlString() calls:
    //   Android: WebView.loadDataWithBaseURL(baseUrl, ...)
    //   iOS:     WKWebView.loadHTMLString(_:baseURL:)
    // Both of these cause the platform WebView to send the baseUrl as the
    // HTTP Referer header on all subsequent requests made by the page.
    _webViewController.loadHtmlString(
      _buildHtml(id),
      baseUrl: 'https://www.youtube-nocookie.com',
    );

    // Safety fallback: hide spinner after 12 s if no page-finished event fires
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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

  // ── Locked UI ──────────────────────────────────────────────────────────────

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

  // ── Error UI ───────────────────────────────────────────────────────────────

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

  // ── Player UI ──────────────────────────────────────────────────────────────

  Widget _buildPlayerView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            WebViewWidget(controller: _webViewController),
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

  // ── Build ──────────────────────────────────────────────────────────────────

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
