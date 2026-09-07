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
import '../../../task/presentation/screens/task_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(
            AuthRegisterRequestedEvent(
              name: _nameController.text.trim(),
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
          // Sync default theme
          context.read<ThemeBloc>().add(
                SyncThemeFromRemoteEvent(themeModeString: state.user.themeMode),
              );

          CustomSnackBar.showSuccess(
            context,
            message: 'Account created successfully! Welcome, ${state.user.name}',
          );

          // Clear backstack to Dashboard
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => TaskDashboardScreen(currentUser: state.user),
            ),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is AuthLoadingState;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Icon & Title
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primaryContainerDark
                                : AppColors.primaryContainerLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 28,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create Account 🚀',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Join today to organize, track, and sync your tasks seamlessly.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Full Name Field
                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hintText: 'John Doe',
                        prefixIcon: Icons.badge_outlined,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: Validators.validateName,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 16),

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'At least 6 characters',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        validator: Validators.validatePassword,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icons.lock_reset_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (val) =>
                            Validators.validateConfirmPassword(val, _passwordController.text),
                        onFieldSubmitted: (_) => _onRegisterPressed(),
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 28),

                      // Register Button
                      CustomButton(
                        text: 'Create Account',
                        isLoading: isLoading,
                        onPressed: _onRegisterPressed,
                      ),
                      const SizedBox(height: 20),

                      // Back to Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: isLoading ? null : () => Navigator.of(context).pop(),
                            child: Text(
                              'Sign In',
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
