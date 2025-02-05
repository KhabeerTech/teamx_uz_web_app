import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamx_uz_web_app/pages/signIn_username.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// import 'package:latlong2/spline.dart';

class OnboardPages extends StatefulWidget {
  const OnboardPages({super.key});

  @override
  State<OnboardPages> createState() => _OnboardPagesState();
}

class _OnboardPagesState extends State<OnboardPages>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    animation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Onboard(),
    );
  }
}

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final heroKey = GlobalKey();
  final aboutKey = GlobalKey();
  final coursesKey = GlobalKey();
  final locationKey = GlobalKey();

  void scrollToWidget(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size, height, width;
    bool screen(BuildContext context) {
      return MediaQuery.of(context).size.width >= 1000;
    }

    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    bool isSmallScreen = MediaQuery.of(context).size.width <= 980;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: isSmallScreen
          ? Drawer(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    // Drawer Header (optional, you can add a logo or title)
                    DrawerHeader(
                      child: Image.asset(
                        'assets/images/logo xmind purple vert@3x.png',
                        width: 100,
                      ),
                    ),
                    // Navigation Items
                    ListTile(
                      onTap: () {
                        scrollToWidget(heroKey);
                        Navigator.pop(context);
                      },
                      title: const Text(
                        'Bosh menu',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        scrollToWidget(aboutKey);
                        Navigator.pop(context);
                      },
                      title: const Text(
                        'TeamX nima',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        scrollToWidget(coursesKey);
                        Navigator.pop(context);
                      },
                      title: const Text(
                        'Yo\'nalishlar',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        scrollToWidget(locationKey);
                        Navigator.pop(context);
                      },
                      title: const Text(
                        'Manzil',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Spacer
                    const Spacer(),
                    // Student Login Button
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignIn_username(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF512D84),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Text(
                          'Tizimga kirish',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        label: const Icon(Icons.arrow_forward,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Drawer(),
      appBar: isSmallScreen
          ? AppBar(
              title: Text(
                "TeamX",
                style: TextStyle(fontSize: 24),
              ),
              centerTitle: true,
            )
          : null,
      key: scaffoldKey,
      floatingActionButton: FloatingActionButton(
        onPressed: () => scrollToWidget(heroKey),
        backgroundColor: const Color(0xFF512D84),
        shape: const CircleBorder(),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF8F5F1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar
            isSmallScreen
                ? Container()
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/logo xmind purple vert@3x.png',
                          width: 100,
                        ),
                        // Navigation Items
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => scrollToWidget(heroKey),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                'Bosh menu',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            TextButton(
                              onPressed: () => scrollToWidget(aboutKey),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                'TeamX nima',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            TextButton(
                              onPressed: () => scrollToWidget(coursesKey),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                'Yo\'nalishlar',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            TextButton(
                              onPressed: () => scrollToWidget(locationKey),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                'Manzil',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Student Login Button
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignIn_username(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF512D84),
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Text(
                            'Tizimga kirish',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          label: const Icon(Icons.arrow_forward,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),

            // Hero Section
            Container(
              key: heroKey,
              padding: EdgeInsets.symmetric(vertical: width * 0.02),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F5F1),
              ),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: width * 0.7),
                  padding: EdgeInsets.symmetric(horizontal: height * 0.0001),
                  child: width > 800
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left side content
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: const TextSpan(
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        height: 1.2,
                                      ),
                                      children: [
                                        TextSpan(text: 'GAP EMAS, ENDI\n'),
                                        TextSpan(
                                          text: 'RAQAM',
                                          style: TextStyle(
                                            color: Color(0xFF512D84),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: width * 0.014),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'O\'zbekistonda ',
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: height * 0.001,
                                          vertical: width * 0.001,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFEB3B),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: const Text(
                                          'birinchi',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        ' bor!',
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.025),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF512D84),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          scrollToWidget(coursesKey),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: height * 0.02,
                                          vertical: width * 0.01,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      icon: const Text(
                                        'Yo\'nalishlar bilan tanishish',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      label: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: width * 0.03),
                            // Right side X logo
                            Image.asset(
                              'assets/images/logo xmind purple vert@3x.png',
                              width: width * 0.27,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left side content (Column variant)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      height: 1.1,
                                    ),
                                    children: [
                                      TextSpan(text: 'GAP EMAS, ENDI\n'),
                                      TextSpan(
                                        text: 'RAQAM',
                                        style: TextStyle(
                                          color: Color(0xFF512D84),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: width * 0.011),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'O\'zbekistonda ',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: height * 0.01,
                                        vertical: width * 0.01,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEB3B),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Text(
                                        'birinchi',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      ' bor!',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height * 0.025),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF512D84),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () => scrollToWidget(coursesKey),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: height * 0.01,
                                        vertical: width * 0.01,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: const Text(
                                      'Yo\'nalishlar bilan tanishish',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    label: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: width * 0.03),
                            // Right side X logo
                            Image.asset(
                              'assets/images/logo xmind purple vert@3x.png',
                              width: width * 0.27,
                            ),
                          ],
                        ),
                ),
              ),
            ),
// Container(
            //   key: heroKey,
            //   padding: EdgeInsets.symmetric(vertical: width * 0.02),
            //   decoration: const BoxDecoration(
            //     color: Color(0xFFF8F5F1),
            //   ),
            //   child: Center(
            //     child: Container(
            //       constraints: BoxConstraints(maxWidth: width * 0.7),
            //       padding: EdgeInsets.symmetric(horizontal: height * 0.0001),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //           // Left side content
            //           Expanded(
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: [
            //                 RichText(
            //                   textAlign: TextAlign.center,
            //                   text: const TextSpan(
            //                     style: TextStyle(
            //                       fontSize: 48,
            //                       fontWeight: FontWeight.bold,
            //                       color: Colors.black,
            //                       height: 1.2,
            //                     ),
            //                     children: [
            //                       TextSpan(text: 'GAP EMAS, ENDI\n'),
            //                       TextSpan(
            //                         text: 'RAQAM',
            //                         style: TextStyle(
            //                           color: Color(0xFF512D84),
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //                 SizedBox(height: width * 0.014),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.center,
            //                   children: [
            //                     const Text(
            //                       'O\'zbekistonda ',
            //                       style: TextStyle(
            //                         fontSize: 24,
            //                         color: Colors.black,
            //                       ),
            //                     ),
            //                     Container(
            //                       padding: EdgeInsets.symmetric(
            //                         horizontal: height * 0.001,
            //                         vertical: width * 0.001,
            //                       ),
            //                       decoration: BoxDecoration(
            //                         color: const Color(0xFFFFEB3B),
            //                         borderRadius: BorderRadius.circular(5),
            //                       ),
            //                       child: const Text(
            //                         'birinchi',
            //                         style: TextStyle(
            //                           fontSize: 24,
            //                           fontWeight: FontWeight.bold,
            //                         ),
            //                       ),
            //                     ),
            //                     const Text(
            //                       ' bor!',
            //                       style: TextStyle(
            //                         fontSize: 24,
            //                         color: Colors.black,
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //                 SizedBox(height: height * 0.025),
            //                 Container(
            //                   decoration: BoxDecoration(
            //                     color: const Color(0xFF512D84),
            //                     borderRadius: BorderRadius.circular(14),
            //                   ),
            //                   child: ElevatedButton.icon(
            //                     onPressed: () => scrollToWidget(coursesKey),
            //                     style: ElevatedButton.styleFrom(
            //                       backgroundColor: Colors.transparent,
            //                       elevation: 0,
            //                       padding: EdgeInsets.symmetric(
            //                         horizontal: height * 0.02,
            //                         vertical: width * 0.01,
            //                       ),
            //                       shape: RoundedRectangleBorder(
            //                         borderRadius: BorderRadius.circular(14),
            //                       ),
            //                     ),
            //                     icon: const Text(
            //                       'Yo\'nalishlar bilan tanishish',
            //                       style: TextStyle(
            //                         color: Colors.white,
            //                         fontSize: 20,
            //                         fontWeight: FontWeight.w500,
            //                       ),
            //                     ),
            //                     label: const Icon(Icons.arrow_forward,
            //                         color: Colors.white, size: 24),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //           SizedBox(width: width * 0.03),
            //           // Right side X logo
            //           Image.asset(
            //             'assets/images/logo xmind purple vert@3x.png',
            //             width: width * 0.27,
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // About Section
            Container(
              key: aboutKey,
              margin: const EdgeInsets.symmetric(vertical: 50),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: screen(context)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left side image
                        Stack(
                          children: [
                            Container(
                              width: 520,
                              height: 370,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/assets/photo_2024-03-06_09-33-23 (2).jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 270,
                              bottom: -60,
                              child: AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0.2, _animation.value),
                                    child: SvgPicture.asset(
                                      'assets/assets/about-shape-2.svg',
                                      width: 220,
                                      height: 170,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 50),
                        // Right side content
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Biz haqimizda',
                              style: TextStyle(
                                fontSize: 48,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            const Text(
                              'Ilmiy qaramliksiz,\nCheklanishlarsiz\nMustaqil ta\'lim',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            const Text(
                              'Har bir inson o\'zi mustaqil xohlagan yo\'nalishi yoki\nxohlagan tilini o\'rganishi mumkin va buning isboti ham bor.\nInsonga faqatgina o\'ziga ishonch va qat\'iyat kerak!',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            _buildFeatureItem('600 qadamlik metod'),
                            _buildFeatureItem('Natijaga kafolat'),
                            _buildFeatureItem('Ish bilan ta\'minlash'),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left side image
                        Stack(
                          children: [
                            Container(
                              width: 520,
                              height: 370,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/assets/photo_2024-03-06_09-33-23 (2).jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                                right: 270, bottom: -60, child: Container()),
                          ],
                        ),
                        const SizedBox(width: 50),
                        // Right side content
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Biz haqimizda',
                                style: TextStyle(
                                  fontSize: 48,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              const Text(
                                'Ilmiy qaramliksiz,\nCheklanishlarsiz\nMustaqil ta\'lim',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              const Text(
                                'Har bir inson o\'zi mustaqil xohlagan yo\'nalishi yoki\nxohlagan tilini o\'rganishi mumkin va buning isboti ham bor.\nInsonga faqatgina o\'ziga ishonch va qat\'iyat kerak!',
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              _buildFeatureItem('20 oylik metod'),
                              _buildFeatureItem('Natijaga kafolat'),
                              _buildFeatureItem('Ish bilan ta\'minlash'),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            // Courses Section
            Container(
              key: coursesKey,
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(
                children: [
                  const Text(
                    'YO\'NALISHLAR',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: height * 0.003),
                  const Text(
                    'Tanlang va boshlang',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildCourseCard(
                        'Full stack dasturlash',
                        'assets/assets/2.jpg',
                        '100 000 so\'m',
                      ),
                      _buildCourseCard(
                        'Mobil dasturlash',
                        'assets/assets/1.jpg',
                        '100 000 so\'m',
                      ),
                      // _buildCourseCard(
                      //   'Grafik dizayn',
                      //   'assets/assets/5.jpg',
                      //   '100 000 so\'m',
                      // ),
                      _buildCourseCard(
                        'Crypto trading',
                        'assets/assets/3.jpg',
                        '100 000 so\'m',
                      ),
                      _buildCourseCard(
                        'Stock trading',
                        'assets/assets/4.jpg',
                        '100 000 so\'m',
                      ),
                    ].map((card) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width >= 600
                            ? MediaQuery.of(context).size.width / 5 -
                                30 // 2 ustunli
                            : MediaQuery.of(context).size.width -
                                40, // Butun ekran
                        child: card,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: height * 0.03),
                  ElevatedButton.icon(
                    onPressed: () => scrollToWidget(heroKey),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF512D84),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Text(
                      'Jamoaga qo\'shilish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    label: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Video Section
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/assets/video-bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: width * 0.6,
                    height: height * 0.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage('assets/assets/video-banner.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.play_circle_fill,
                          size: screen(context) ? 80 : 40,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/purple_horz.png',
                        height: 150,
                      ),
                      const Text(
                        ' - haqida to\'liq bilib olishingiz mumkin',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Map Section
            Container(
              key: locationKey,
              width: width * 0.97,
              height: height * 0.3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: EdgeInsets.all(5),
              child: Center(
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter:
                        LatLng(40.089902, 64.7095483), // teamX koordinatalari
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    const MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(40.089902, 64.7095483),
                          width: 80,
                          height: 80,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: height * 0.05),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 17, 18, 18),
              ),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 800) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFirstColumn(),
                                SizedBox(height: 20),
                                _buildSecondColumn(),
                              ],
                            );
                          } else {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _buildFirstColumn()),
                                Expanded(child: _buildSecondColumn()),
                              ],
                            );
                          }
                        },
                      ),

                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,;
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Expanded(
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text(
                      //             "O‘zbekistonda birinchi bor Mustaqil ta‘lim akademiyasi",
                      //             style: TextStyle(
                      //               color: Colors.white60,
                      //               fontWeight: FontWeight.bold,
                      //               fontSize: 16,
                      //             ),
                      //           ),
                      //           SizedBox(height: 10),
                      //           Text(
                      //             "Manzil: Mavlaviyon 3-uy\nMo‘ljal: Ippadrom buyum bozori",
                      //             style: TextStyle(
                      //                 color: Colors.white60, fontSize: 14),
                      //           ),
                      //           SizedBox(height: 10),
                      //           Text(
                      //             "Telefon: +998 88 081 18 88,\n+998 88 081 81 88,\n+998 88 081 88 18",
                      //             style: TextStyle(
                      //                 color: Colors.white60, fontSize: 14),
                      //           ),
                      //           SizedBox(height: 20),
                      //           // const Text(
                      //           //   "Ijtimoiy tarmoqlarda kuzatib boring",
                      //           //   style: TextStyle(
                      //           //       color: Colors.white, fontSize: 14),
                      //           // ),
                      //           // Row(
                      //           //   children: [
                      //           //     IconButton(
                      //           //       onPressed: () {},
                      //           //       icon: const Icon(Icons.facebook,
                      //           //           color: Colors.white),
                      //           //     ),
                      //           //     IconButton(
                      //           //       onPressed: () {},
                      //           //       icon: const Icon(Icons.telegram,
                      //           //           color: Colors.white),
                      //           //     ),
                      //           //     IconButton(
                      //           //       onPressed: () {},
                      //           //       icon: const Icon(
                      //           //           Icons.youtube_searched_for,
                      //           //           color: Colors.white),
                      //           //     ),
                      //           //   ],
                      //           // ),
                      //         ],
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text(
                      //             "teamX - zamonaviy kasblar akademiyasi",
                      //             style: TextStyle(
                      //               color: Colors.white,
                      //               fontWeight: FontWeight.bold,
                      //               fontSize: 16,
                      //             ),
                      //           ),
                      //           SizedBox(height: 10),
                      //           Text("Akademiya haqida",
                      //               style: TextStyle(
                      //                   color: Colors.white60, fontSize: 14)),
                      //           SizedBox(height: 5),
                      //           Text("Yo‘nalishlar",
                      //               style: TextStyle(
                      //                   color: Colors.white60, fontSize: 14)),
                      //           SizedBox(height: 5),
                      //           Text("Ko‘rsatma",
                      //               style: TextStyle(
                      //                   color: Colors.white60, fontSize: 14)),
                      //           SizedBox(height: 5),
                      //           Text("E‘lonlar",
                      //               style: TextStyle(
                      //                   color: Colors.white60, fontSize: 14)),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Uzbekiston 2024",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Text(
                              "KhabeerTech",
                              style:
                                  TextStyle(color: Colors.purple, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )

            // Footer Section
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.symmetric(vertical: 50),
            //   decoration: const BoxDecoration(
            //     color: Color.fromARGB(255, 17, 18, 18),
            //   ),
            //   child: Center(
            //     child: Container(
            //       constraints: const BoxConstraints(maxWidth: 1200),
            //       padding: const EdgeInsets.symmetric(horizontal: 20),
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Image.asset(
            //             'assets/images/purple_horz.png',
            //             height: 150,
            //           ),
            //           const SizedBox(height: 30),
            //           const Text(
            //             'Biz bilan bog\'lanish',
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 24,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //           const SizedBox(height: 20),
            //           const Text(
            //             'Manzil: Toshkent shahri, Chilonzor tumani,\nQatortol ko\'chasi, 7-uy',
            //             textAlign: TextAlign.center,
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 16,
            //             ),
            //           ),
            //           const SizedBox(height: 10),
            //           const Text(
            //             'Tel: +998 99 999 99 99',
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 16,
            //             ),
            //           ),
            //           const SizedBox(height: 10),
            //           const Text(
            //             'Email: info@teamx.uz',
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 16,
            //             ),
            //           ),
            //           const SizedBox(height: 30),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               IconButton(
            //                 onPressed: () {},
            //                 icon:
            //                     const Icon(Icons.facebook, color: Colors.white),
            //               ),
            //               const SizedBox(width: 20),
            //               IconButton(
            //                 onPressed: () {},
            //                 icon:
            //                     const Icon(Icons.telegram, color: Colors.white),
            //               ),
            //               const SizedBox(width: 20),
            //               // IconButton(
            //               // onPressed: () {},
            //               // icon: const Icon(Icons., color: Colors.white),
            //               // ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Widget _buildNavItem(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 15),
  //     child: TextButton(
  //       onPressed: () {},
  //       child: Text(
  //         title,
  //         style: const TextStyle(
  //           color: Colors.black87,
  //           fontSize: 16,
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildFirstColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "O‘zbekistonda birinchi bor Mustaqil ta‘lim akademiyasi",
          style: TextStyle(
            color: Colors.white60,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Manzil: Mavlaviyon 3-uy\nMo‘ljal: Ippadrom buyum bozori",
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        SizedBox(height: 10),
        Text(
          "Telefon: +998 88 081 18 88,\n+998 88 081 81 88,\n+998 88 081 88 18",
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(String title, String imagePath, String price) {
    return Container(
      width: 370,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                //   decoration: BoxDecoration(
                //     color: Colors.grey[200],
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   // child: const Row(
                //   //   mainAxisSize: MainAxisSize.min,
                //   //   children: [
                //   //     Icon(Icons.access_time, size: 16),
                //   //     SizedBox(width: 5),
                //   //      Text('20 OY'),
                //   //   ],
                //   // ),
                // ),
                const SizedBox(height: 10),
                const Text(
                  'Zero To Hero',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.library_books, size: 16),
                    SizedBox(width: 5),
                    Text('600 ta qadam'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildContactInfo(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 5),
  //     child: Row(
  //       children: [
  //         Text(
  //           label,
  //           style: const TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(width: 10),
  //         Text(
  //           value,
  //           style: const TextStyle(fontSize: 16),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildSocialIcon(IconData icon) {
  //   return Padding(
  //     padding: const EdgeInsets.only(right: 10),
  //     child: IconButton(
  //       onPressed: () {},
  //       icon: Icon(icon),
  //       color: const Color(0xFF512D84),
  //     ),
  //   );
  // }

  // Widget _buildFooterLink(String text) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 5),
  //     child: TextButton(
  //       onPressed: () {},
  //       child: Text(
  //         text,
  //         style: const TextStyle(
  //           color: Colors.black87,
  //           fontSize: 16,
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildSecondColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "teamX - zamonaviy kasblar akademiyasi",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        Text("Akademiya haqida",
            style: TextStyle(color: Colors.white60, fontSize: 14)),
        SizedBox(height: 5),
        Text("Yo‘nalishlar",
            style: TextStyle(color: Colors.white60, fontSize: 14)),
        SizedBox(height: 5),
        Text("Ko‘rsatma",
            style: TextStyle(color: Colors.white60, fontSize: 14)),
        SizedBox(height: 5),
        Text("E‘lonlar", style: TextStyle(color: Colors.white60, fontSize: 14)),
      ],
    );
  }
}
