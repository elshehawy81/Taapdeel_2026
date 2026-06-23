import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// تطبيع رقم الموبايل لصيغة E.164 (مثال: مصر +20)
  String normalizePhone(String raw) {
    String phone = raw.trim();

    // لو دخل 0020...
    if (phone.startsWith('00')) {
      phone = phone.substring(2); // تشيل 00
      if (!phone.startsWith('+')) {
        phone = '+$phone';
      }
      return phone;
    }

    // لو دخل +2010...
    if (phone.startsWith('+')) {
      return phone;
    }

    // لو دخل 010xxxxxxx (موبايل مصر)
    if (phone.startsWith('0')) {
      // مثال: 01012345678 -> +201012345678
      return '+20${phone.substring(1)}';
    }

    // fallback: لو كتب الرقم بدون كود دولة
    if (phone.length >= 10 && phone.length <= 12) {
      return '+20$phone';
    }

    return phone;
  }

  /// إرسال كود الـ OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(PhoneAuthCredential credential)
    onVerificationCompleted,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    required void Function(String verificationId)
    onCodeAutoRetrievalTimeout,
  }) async {
    final String normalized = normalizePhone(phoneNumber);

    await _auth.verifyPhoneNumber(
      phoneNumber: normalized,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        onCodeAutoRetrievalTimeout(verificationId);
      },
    );
  }

  /// تسجيل الدخول بكود SMS (verificationId + smsCode)
  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  /// تسجيل الدخول مباشرة بالـ credential (لما يتم auto-verification)
  Future<UserCredential> signInWithCredential(
      PhoneAuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;
}
