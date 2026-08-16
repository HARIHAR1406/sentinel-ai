import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/sentinel_button.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.shield, size: 64, color: AppColors.sentinelBlue),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access safety intelligence.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot_password'),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SentinelButton(
                      label: 'Sign In',
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(height: 16),
                    SentinelButton(
                      label: 'Create Account',
                      isGhost: true,
                      onPressed: () => context.push('/register'),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
