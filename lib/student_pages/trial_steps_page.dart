import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TrialStepsPage extends StatelessWidget {
  const TrialStepsPage({super.key});

  void _launchTelegramChannel() async {
    const telegramUrl = 'https://t.me/teamX_3kun';
    try {
      if (await canLaunch(telegramUrl)) {
        await launch(telegramUrl);
      } else {
        throw 'Could not launch $telegramUrl';
      }
    } catch (e) {
      debugPrint('Error launching Telegram URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    bool isPhone = screenWidth < 600;

    // Responsive o'lchamlar
    double containerWidth = isPhone ? screenWidth * 0.9 : 800;
    double numberSize = isPhone ? 80 : 180;
    double spacing = isPhone ? 8 : 24;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF512D84),
        title: const Text(
          '3 kunlik sinov',     
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: screenWidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 249, 248, 198),
              Color.fromARGB(255, 218, 200, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: containerWidth,
                padding: EdgeInsets.all(spacing * 1.5),
                margin: EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 240, 255),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF8C52FF),
                    width: isPhone ? 2 : 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: isPhone ? 8 : 12,
                      offset: Offset(0, isPhone ? 4 : 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStepNumber('1', const Color(0xFF00BF63), numberSize),
                    _buildStepNumber('2', const Color(0xFFFFA726), numberSize),
                    _buildStepNumber('3', Colors.white, numberSize),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: containerWidth,
                height: isPhone ? 50 : 60,
                margin: EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  color: const Color(0xFF512D84),
                  borderRadius: BorderRadius.circular(isPhone ? 15 : 20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _launchTelegramChannel,
                    borderRadius: BorderRadius.circular(isPhone ? 15 : 20),
                    child: Center(
                      child: Text(
                        'Telegram kanalga o\'tish',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isPhone ? 16 : 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepNumber(String number, Color color, double size) {
    final isPhone = size < 100;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(isPhone ? 15 : 25),
        border: Border.all(
          color: color == Colors.white ? Colors.grey : color,
          width: isPhone ? 2 : 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isPhone ? 4 : 8,
            offset: Offset(0, isPhone ? 2 : 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: color == Colors.white ? Colors.grey : Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
