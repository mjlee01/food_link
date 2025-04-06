import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool rememberMe = false;
  bool agreeToTerms = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
      // Navigate to the main screen after successful sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle error (e.g., show a snackbar or dialog)
      print(e.message);
    }
  }

  Future<void> _registerWithEmailAndPassword() async {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required.")));
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    try {
      // Create a new user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      await userCredential.user?.updateDisplayName(
        fullNameController.text.trim(),
      );

      // Navigate to the main screen after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle error (e.g., show a snackbar or dialog)
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }

      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Centers the entire content both horizontally and vertically
        child: SingleChildScrollView(
          // Ensures the content is scrollable if it overflows
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Centers content horizontally
            children: [
              // Logo and Tagline
              Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the row horizontally
                    children: [
                      // Icon
                      FaIcon(
                        FontAwesomeIcons
                            .seedling, // Replace with your desired icon
                        color: Colors.green, // Icon color
                        size: 32, // Icon size
                      ),
                      SizedBox(
                        width: 8,
                      ), // Add spacing between the icon and the text
                      // Text
                      Text(
                        "FoodLink",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Add spacing below the row
                  Text(
                    "Reduce waste. Share food. Build community.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // TabBar for Sign In and Sign Up
              TabBar(
                controller: _tabController,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4.0, color: Colors.green),
                  insets: EdgeInsets.symmetric(horizontal: 115.0),
                ),
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
                tabs: [Tab(text: "Sign In"), Tab(text: "Sign Up")],
              ),
              SizedBox(height: 16),

              // TabBarView for Sign In and Sign Up
              SizedBox(
                height: 500, // Adjust height to fit the forms
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildSignInForm(), _buildSignUpForm()],
                ),
              ),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("or continue with"),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 16),

              // Social Media Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.g_mobiledata, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.facebook, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.apple, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Field
        Text(
          "Email",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),

        // Password Field
        Text(
          "Password",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        SizedBox(height: 16),

        // Remember Me Checkbox
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value!;
                    });
                  },
                ),
                Text("Remember Me"),
              ],
            ),
            TextButton(
              onPressed: () {
                // Handle forgot password
              },
              child: Text("Forgot Password?"),
            ),
          ],
        ),

        // Sign In Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _signInWithEmailAndPassword();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.green,
            ),
            child: Text("Sign In", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Full Name",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        // Full Name Field
        TextField(
          controller: fullNameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),

        // Email Field
        Text(
          "Email",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),

        // Password Field
        Text(
          "Password",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Create a password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        SizedBox(height: 16),

        // Confirm Password Field
        Text(
          "Confirm Password",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        TextField(
          controller: confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        SizedBox(height: 8),

        // Agree to Terms Checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: agreeToTerms,
              onChanged: (value) {
                setState(() {
                  agreeToTerms = value!;
                });
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "I agree to the Terms of Service and Privacy Policy",
                  softWrap: true,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Sign Up Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _registerWithEmailAndPassword();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.green,
            ),
            child: Text("Create Account", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
