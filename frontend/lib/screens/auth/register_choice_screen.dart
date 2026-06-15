import 'package:flutter/material.dart';
import '../../config/constants.dart';

class RegisterChoiceScreen extends StatelessWidget {
  const RegisterChoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Account')),
      body: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register-consumer'),
              child: const Text('Register - Konsumen'),
            ),
            const SizedBox(height: AppNumbers.paddingSmall),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/register-umkm-step1'),
              child: const Text('Register - UMKM'),
            ),
          ],
        ),
      ),
    );
  }
}
