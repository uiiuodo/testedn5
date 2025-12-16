import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final Rx<User?> user;

  bool get isGuest => user.value?.isAnonymous ?? false;
  bool get isLoggedIn => user.value != null;

  String? get uid => user.value?.uid;

  Future<AuthService> init() async {
    user = Rx<User?>(_auth.currentUser);
    user.bindStream(_auth.authStateChanges());
    return this;
  }

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      Get.snackbar(
        '오류',
        '익명 로그인 실패: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      Get.snackbar(
        '오류',
        '로그인 실패: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      Get.snackbar(
        '오류',
        '회원가입 실패: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _handleAuthException(FirebaseAuthException e) {
    String message = '알 수 없는 오류가 발생했습니다.';
    switch (e.code) {
      case 'user-not-found':
        message = '사용자를 찾을 수 없습니다.';
        break;
      case 'wrong-password':
        message = '잘못된 비밀번호입니다.';
        break;
      case 'email-already-in-use':
        message = '이미 사용 중인 이메일입니다.';
        break;
      case 'invalid-email':
        message = '유효하지 않은 이메일 형식입니다.';
        break;
      case 'weak-password':
        message = '비밀번호가 너무 약합니다.';
        break;
    }
    Get.snackbar(
      '오류',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}
