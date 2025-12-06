import 'package:benevolent_crm_app/app/modules/auth/modals/change_password_response.dart';
import 'package:benevolent_crm_app/app/modules/auth/modals/login_response_modal.dart';
import 'package:benevolent_crm_app/app/modules/auth/modals/otp_verify_response.dart';
import 'package:benevolent_crm_app/app/modules/auth/modals/reset_password_response.dart';
import 'package:benevolent_crm_app/app/modules/auth/modals/signup_response_modal.dart';
import 'package:benevolent_crm_app/app/modules/auth/views/login_screen.dart';
import 'package:benevolent_crm_app/app/services/auth_services.dart';
import 'package:benevolent_crm_app/app/utils/api_exceptions.dart';
import 'package:benevolent_crm_app/app/utils/token_storage.dart';
import 'package:benevolent_crm_app/app/widgets/custom_snackbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService authService = AuthService();

  var isLoading = false.obs;
  var loginResponse = Rxn<LoginResponseModel>();
  var signupResponse = Rxn<SignupResponse>();

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      final response = await authService.signup(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      signupResponse.value = response;

      if (response.success) {
        CustomSnackbar.show(
          title: 'Signup Successful',
          message: response.message,
          type: ToastType.success,
        );
        Get.to(() => LoginScreen());
      } else {
        CustomSnackbar.show(
          title: 'Signup Failed',
          message: response.message,
          type: ToastType.error,
        );
      }
    } catch (e) {
      print('Signup Error: $e');
      CustomSnackbar.show(
        title: 'Signup Error',
        message: e.toString(),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("User granted permission: ${settings.authorizationStatus}");
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      await requestNotificationPermission();
      await FirebaseMessaging.instance.deleteToken();

      String? deviceToken;

      if (GetPlatform.isIOS) {
        deviceToken = await FirebaseMessaging.instance.getAPNSToken();
        print('iOS FCM Device Token: $deviceToken');
      } else {
        deviceToken = await FirebaseMessaging.instance.getToken();
        print('Android Device Token: $deviceToken');
      }

      if (deviceToken!.isEmpty) {
        throw Exception("Failed to get device token from Firebase.");
      }

      final data = await authService.login(email, password, deviceToken);

      loginResponse.value = data;

      // Save role to SharedPreferences
      if (data.results?.role != null) {
        final tokenStorage = TokenStorage();
        await tokenStorage.saveRole(data.results!.role);
        print("Role saved: ${data.results!.role}");
        final savedRole = await tokenStorage.getRole();
        print("Role retrieved: $savedRole");
        // print("Is Admin check: $isAdminCheck");
      }

      CustomSnackbar.show(
        title: 'Login Successful',
        message: 'Welcome ${data.results!.data?.firstName ?? ''}',
        type: ToastType.success,
      );

      Get.offAllNamed('/bottombar');
    } catch (e) {
      print('Login Failed Exception: $e');
      CustomSnackbar.show(
        title: 'Login Failed',
        message: e is ApiException ? e.message : e.toString(),
        type: ToastType.error,
      );
      loginResponse.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Rxn<ResetPasswordResponse> resetResponse = Rxn<ResetPasswordResponse>();

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      final response = await authService.resetPassword(email);
      resetResponse.value = response;
      CustomSnackbar.show(
        title: response.success ? 'Reset Link Sent' : 'Reset Failed',
        message: response.message,
        type: ToastType.success,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'Reset Failed',
        message: e is ApiException ? e.message : e.toString(),
        type: ToastType.error,
      );
      resetResponse.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  var otpResponse = Rxn<OTPVerifyResponse>();
  var pwdResponse = Rxn<ChangePasswordResponse>();

  Future<void> verifyOTP(String email, String otp) async {
    try {
      isLoading.value = true;
      otpResponse.value = await authService.verifyOTP(email, otp);
      CustomSnackbar.show(
        title: 'Verify OTP',
        message: otpResponse.value!.message,
        type: ToastType.success,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: e.toString(),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String email, String pass, String confirm) async {
    print('change password');
    try {
      isLoading.value = true;
      pwdResponse.value = await authService.changePassword(
        email,
        pass,
        confirm,
      );
      print('change password1');
      print(pwdResponse.value);
      CustomSnackbar.show(
        title: 'Change Password',
        message: pwdResponse.value!.message,
        type: ToastType.success,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: e.toString(),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
