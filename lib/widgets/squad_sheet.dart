import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.shield_outlined,
      'title': '2D Vector Crest Builder',
      'desc':
          'Combine 44 heraldic shields, 34 classic divisions, and over 300 flat 2D vector emblems, crowns, laurels, and banners.',
    },
    {
      'icon': Icons.checkroom_outlined,
      'title': 'Jersey & Full Kit Studio',
      'desc':
          'Customize Front, Back, Sleeve, Shorts, and Socks across 35 templates with tappable color zones and 60+ sublimation patterns.',
    },
    {
      'icon': Icons.gesture_outlined,
      'title': 'Precision Bézier & Node Canvas',
      'desc':
          'Draw with Pen, Polygon, Star, and Brush tools. Edit anchor & control handles, mirror in real-time with Symmetry mode, and enjoy unlimited Undo/Redo.',
    },
    {
      'icon': Icons.ios_share_outlined,
      'title': 'Pro Export (PNG, SVG & PDF)',
      'desc':
          'Export transparent PNGs up to 4096px, pure vector SVG files, and full multi-kit PDF spec sheets ready to share.',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: widget.onComplete,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final s = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5A3).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            s['icon'] as IconData,
                            size: 56,
                            color: const Color(0xFF00E5A3),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          s['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          s['desc'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i
                          ? const Color(0xFF00E5A3)
                          : Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_page < _slides.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      widget.onComplete();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      _page < _slides.length - 1 ? 'Next' : 'Launch Studio',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
