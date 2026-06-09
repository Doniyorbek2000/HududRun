import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _activePage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Yugurib hudud egallang',
      description:
          'Dinamik geo hududlar orqali raqiblarga qarshi strategiyalarni amalga oshiring.',
      icon: Icons.shield,
    ),
    _OnboardingSlide(
      title: 'Reytingda ko‘tariling',
      description:
          'Hududlar va asosiy natijalaringiz asosida global reytingga chiqish.',
      icon: Icons.emoji_events,
    ),
    _OnboardingSlide(
      title: 'Challenge va badge oling',
      description:
          'Har bir yugurish bilan yangi badge va bonus XP yutib oling.',
      icon: Icons.star,
    ),
    _OnboardingSlide(
      title: 'Start your battle',
      description:
          'Xaritani oching, o‘zingizning hududingizni kengaytiring va g‘olib chiqing.',
      icon: Icons.run_circle,
    ),
  ];

  void _onNext() {
    if (_activePage == _slides.length - 1) {
      widget.onFinish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF041122), Color(0xFF111E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HududRun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onFinish,
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _activePage = index),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3544B1), Color(0xFF1B2A5C)],
                              ),
                              boxShadow: [
                                const BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.3),
                                  blurRadius: 30,
                                  offset: Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                slide.icon,
                                size: 96,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFB0BEE5),
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        _slides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _activePage == index ? 24 : 10,
                          decoration: BoxDecoration(
                            color: _activePage == index
                                ? Colors.white
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C7BFF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        _activePage == _slides.length - 1 ? 'Start' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}
