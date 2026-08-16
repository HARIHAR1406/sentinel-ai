import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/sentinel_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Forgot your password?',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email address and we will send you a link to reset your password.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 32),
                    SentinelButton(
                      label: 'Send Reset Link',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reset link sent to email')),
                        );
                        context.pop();
                      },
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
