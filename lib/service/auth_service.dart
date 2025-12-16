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

    // ✅ Verification Log
    ever(user, (u) {
      if (u != null) {
        debugPrint('[Auth] User Logged In: ${u.uid}');
      } else {
        debugPrint('[Auth] User Logged Out');
      }
    });

    return this;
  }

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      Get.snackbar(
        '오류',
        '익명 로그인 실패: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
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
    // Basic friendly message mapping
    String friendlyMessage = '알 수 없는 오류가 발생했습니다.';
    switch (e.code) {
      case 'user-not-found':
        friendlyMessage = '사용자를 찾을 수 없습니다.';
        break;
      case 'wrong-password':
        friendlyMessage = '잘못된 비밀번호입니다.';
        break;
      case 'email-already-in-use':
        friendlyMessage = '이미 사용 중인 이메일입니다.';
        break;
      case 'invalid-email':
        friendlyMessage = '유효하지 않은 이메일 형식입니다.';
        break;
      case 'weak-password':
        friendlyMessage = '비밀번호가 너무 약합니다.';
        break;
      case 'operation-not-allowed':
        friendlyMessage = '이 로그인 방식이 비활성화되어 있습니다.';
        break;
      case 'network-request-failed':
        friendlyMessage = '네트워크 연결을 확인해주세요.';
        break;
    }

    // Show BOTH friendly message AND raw technical details for debugging
    Get.snackbar(
      '오류 (${e.code})',
      '$friendlyMessage\n[상세: ${e.message}]',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }
}
