import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../product_scan/ui/scan_page.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authViewModelProvider);
    final emailCtrl = TextEditingController(text: 'demo@example.com');
    final passCtrl = TextEditingController(text: 'password');
    ref.listen(authViewModelProvider, (prev, next) {
      next.maybeWhen(
        authenticated: (_) => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ScanPage()),
        ),
        orElse: () {},
      );
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            state.maybeWhen(
              authenticating: () => const CircularProgressIndicator(),
              orElse: () => ElevatedButton(














}  }    );      ),        ),          ],            state.maybeWhen(failure: (m) => Text(m, style: const TextStyle(color: Colors.red)), orElse: () => const SizedBox()),            ),              ),                child: const Text('Login'),                    ),                      passCtrl.text.trim(),                      emailCtrl.text.trim(),                onPressed: () => ref.read(authViewModelProvider.notifier).login(