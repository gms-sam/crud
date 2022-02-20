// ignore_for_file: constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home.dart';

enum MobileVerificstionState { SHOW_MOBILE_FORM_STATE, SHOW_OTP_FORM_STATE }

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  MobileVerificstionState currentState =
      MobileVerificstionState.SHOW_MOBILE_FORM_STATE;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String verificationId;

  bool showLoading = false;

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });

    try {
      // ignore: unused_local_variable
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        showLoading = false;
      });

      if (authCredential.user != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Home()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });
      // ignore: deprecated_member_use
      _scaffoldKey.currentState
          // ignore: deprecated_member_use
          ?.showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  getMobileFormWidget(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(
            flex: 2,
          ),
          const Text(
            "Continue with Phone",
            style: TextStyle(
              fontSize: 28,
            ),
          ),
          //Spacer(),
          const SizedBox(
            height: 60,
          ),
          TextField(
            // maxLength: 10,
            keyboardType: TextInputType.number,
            controller: phoneController,
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone),
                labelText: "Mobile Number",
                border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(4))),
          ),
          const SizedBox(
            height: 60,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(100, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () async {
                setState(() {
                  showLoading = true;
                });

                await _auth.verifyPhoneNumber(
                    phoneNumber: "+91" + phoneController.text,
                    verificationCompleted: (phoneAuthCredential) async {
                      setState(() {
                        showLoading = false;
                      });
                      //signInWithPhoneAuthCredential(phoneAuthCredential);
                    },
                    verificationFailed: (verificationFailed) async {
                      setState(() {
                        showLoading = false;
                      });

                      // ignore: deprecated_member_use
                      _scaffoldKey.currentState?.showSnackBar(SnackBar(
                          content:
                              Text(verificationFailed.message.toString())));
                    },
                    codeSent: (verificationId, resendingToken) async {
                      setState(() {
                        showLoading = false;
                        currentState =
                            MobileVerificstionState.SHOW_OTP_FORM_STATE;
                        this.verificationId = verificationId;
                      });
                    },
                    codeAutoRetrievalTimeout: (verificationId) async {});
              },
              child: const Text("CONTINUE"),
            ),
          ),
          const Spacer(
            flex: 3,
          )
        ],
      ),
    );
  }

  getOtpFormWidget(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 200, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spacer(),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Verify your phone",
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 25,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 40,
          ),
          TextField(
            maxLength: 6,
            keyboardType: TextInputType.number,
            controller: otpController,
            decoration: InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(4))),
          ),
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 40,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(100, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () async {
                PhoneAuthCredential phoneAuthCredential =
                    PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: otpController.text);
                signInWithPhoneAuthCredential(phoneAuthCredential);
              },
              child: const Text("VERIFY"),
            ),
          ),
          const Spacer()
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: showLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                child: currentState ==
                        MobileVerificstionState.SHOW_MOBILE_FORM_STATE
                    ? getMobileFormWidget(context)
                    : getOtpFormWidget(context)));
  }
}
