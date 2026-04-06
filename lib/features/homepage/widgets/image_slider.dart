import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sugar_production/core/services/announcements_service.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class ImageSlider extends StatefulWidget {
  final double height;
  final Duration autoPlayInterval;
  final BorderRadius? borderRadius;

  const ImageSlider({
    super.key,
    this.height = 180,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.borderRadius,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

const _kAssetImages = [
  'assets/images/1.png',
  'assets/images/2.png',
  'assets/images/3.JPG',
  'assets/images/4.png',
];

class _ImageSliderState extends State<ImageSlider> {
  late final PageController _pageController;
  Timer? _timer;
  StreamSubscription? _bgSub;
  int _currentIndex = 0;
  List<String> _images = [];
  bool _loading = true;
  bool _useAssets = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadAnnouncements();
    _bgSub = FlutterBackgroundService()
        .on('newAnnouncement')
        .listen((_) => _loadAnnouncements());
  }

  Future<void> _loadAnnouncements() async {
    try {
      final rows = await AnnouncementsService.getAllAnnouncements();
      final images = rows
          .map((r) => r['image']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (mounted) {
        setState(() {
          if (images.isNotEmpty) {
            _images = images;
            _useAssets = false;
          } else {
            _images = _kAssetImages;
            _useAssets = true;
          }
          _loading = false;
        });
        _startAutoPlay();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _images = _kAssetImages;
          _useAssets = true;
          _loading = false;
        });
        _startAutoPlay();
      }
    }
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || _images.isEmpty) return;
      final nextIndex = (_currentIndex + 1) % _images.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bgSub?.cancel();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusLG);

    if (_loading) {
      return ClipRRect(
        borderRadius: radius,
        child: Container(
          height: widget.height,
          color: context.appColors.surface,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_images.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // ── Page View ──────────────────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                if (_useAssets) {
                  return Image.asset(
                    _images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _errorPlaceholder(context),
                  );
                }
                try {
                  final raw = _images[index];
                  final b64 = raw.contains(',') ? raw.split(',').last : raw;
                  final bytes = base64Decode(b64);
                  return Image.memory(
                    bytes,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _errorPlaceholder(context),
                  );
                } catch (_) {
                  return _errorPlaceholder(context);
                }
              },
            ),

            // ── Dot Indicators ─────────────────────────────────
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_images.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorPlaceholder(BuildContext context) => Container(
    color: context.appColors.surface,
    child: Center(
      child: Icon(
        Icons.broken_image_rounded,
        color: context.appColors.textHint,
        size: 36,
      ),
    ),
  );
}
