import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_event.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_screen.dart';
import '../../../task/presentation/screens/task_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(
            AuthLoginRequestedEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          CustomSnackBar.showError(context, message: state.message);
        } else if (state is AuthenticatedState) {
          // Sync user's remote theme preference
          context.read<ThemeBloc>().add(
                SyncThemeFromRemoteEvent(themeModeString: state.user.themeMode),
              );

          CustomSnackBar.showSuccess(
            context,
            message: 'Welcome back, ${state.user.name}!',
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => TaskDashboardScreen(currentUser: state.user),
            ),
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is AuthLoadingState;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Icon & Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primaryContainerDark
                                : AppColors.primaryContainerLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.lock_person_rounded,
                            size: 32,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome Back 👋',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to manage your tasks and stay productive.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hintText: 'name@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.validateEmail,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.validatePassword,
                        onFieldSubmitted: (_) => _onLoginPressed(),
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 28),

                      // Login Button
                      CustomButton(
                        text: 'Sign In',
                        isLoading: isLoading,
                        onPressed: _onLoginPressed,
                      ),
                      const SizedBox(height: 24),

                      // Register Navigation Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
