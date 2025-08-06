import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Terms and Condition',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Last Updated: 06.06.2025',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to Remove Object — an app designed to help you remove unwanted objects from your photos easily. Please read these terms before using the app.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 24),
              _sectionTitle('1. Acceptance of Terms'),
              _sectionBody(
                  'By using this app, you agree to follow these terms. If you don\'t agree, please don\'t use the app.'),
              const SizedBox(height: 20),
              _sectionTitle('2. App Usage'),
              _sectionBody(
                  'You may use the app for personal, non-commercial photo editing. You must not:'),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _bulletText('Use the app to create harmful or illegal content'),
                    _bulletText('Try to copy, sell, or reverse-engineer the app'),
                    _bulletText('Upload offensive, violent, or copyrighted images you don\'t own'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle('3. Your Content'),
              _sectionBody(
                  'You keep full ownership of the photos you upload. We don\'t store or share them. We only use them to process the edits you request.'),
              const SizedBox(height: 20),
              _sectionTitle('4. No Guarantees'),
              _sectionBody(
                  'We do our best to keep the app working well, but we can\'t guarantee it will always be perfect or available.'),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _sectionTitle(String text) {
  return Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  );
}

Widget _sectionBody(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 15),
    ),
  );
}

class _bulletText extends StatelessWidget {
  final String text;
  const _bulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white70, fontSize: 15)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}