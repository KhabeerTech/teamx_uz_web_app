import 'package:flutter/material.dart';

final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

InputDecoration inputDecoration(String labelText) {
  return InputDecoration(
    labelText: labelText,
    labelStyle:
        const TextStyle(color: Color(0xFF512D84)), // Label rangini sozlash
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF512D84), width: 2.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF512D84), width: 2.5),
    ),
  );
}

class SignIn extends StatelessWidget {
  const SignIn({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double screenWidth = constraints.maxWidth;
      double screenHeight = constraints.maxHeight;
      return Scaffold(
        appBar: AppBar(
          title: Image.asset(
            "assets/logo.png",
            height: 100,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: inputDecoration("Username"),
                style: const TextStyle(color: Color(0xFF512D84)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: inputDecoration("Parol "),
                style: const TextStyle(color: Color(0xFF512D84)),
              ),
              const SizedBox(
                height: 20,
              ),

              // SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromRGBO(255, 235, 59, 1),
                  backgroundColor: const Color(0xFF512D84),
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.15,
                      vertical: screenHeight * 0.018),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Tizimga kirish"),
              ),
              // SizedBox(height: 280),
              // SizedBox(height: 25),
              const Spacer(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'akauntingiz bolmasa :',
                      style: TextStyle(
                        color: Colors.black54,
                        //fontSize: 13
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignIn(),
                            ));
                      },
                      // style: ElevatedButton.styleFrom(
                      //   foregroundColor: const Color.fromRGBO(255, 235, 59, 1),
                      //   backgroundColor: const Color(0xFF512D84),
                      //   padding: EdgeInsets.symmetric(
                      //       horizontal: screenWidth * 0.13,
                      //       vertical: screenHeight * 0.018),
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(180),
                      //   ),
                      // ),
                      child: const Text("Ro'yxatdan o'tish"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }
}
