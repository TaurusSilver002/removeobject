import 'package:flutter/material.dart';
import 'package:objectremove/config.dart';
import 'package:objectremove/services/app_translations.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  Widget _settingItem(
    IconData icon,
    Color color,
    String title,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
      title: TranslatableText(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10111A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10111A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TranslatableText('Settings', style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
                onTap: () {
                  // Navigate to paywall screen
                  Navigator.pushNamed(context, '/paywall');
                },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                 image: DecorationImage(
                    image: AssetImage(AppImages.proback),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.yellow, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TranslatableText(
                                'Premium',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TranslatableText(
                                  'Pro',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TranslatableText(
                            'Upgrade now for unlimited High Quality Image',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TranslatableText(
                'Other Setting',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF181A23),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView(
                  children: [
                    _settingItem(Icons.language, Colors.blue, 'Language', () {Navigator.pushNamed(context, '/language');}),
                    _settingItem(Icons.restore, Colors.pink, 'Restore', () {}),
                    _settingItem(Icons.star, Colors.amber, 'Rating', () {}),
                    _settingItem(Icons.share, Colors.cyan, 'Share App', () {}),
                    _settingItem(Icons.email, Colors.purpleAccent, 'Contact us', () {}),
                    _settingItem(Icons.privacy_tip, Colors.purple, 'Privacy Policy', () {Navigator.pushNamed(context, '/privacy');}),
                    _settingItem(Icons.article, Colors.green, 'Terms and condition', () {Navigator.pushNamed(context, '/terms');}),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, color: Colors.white),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.linked_camera, color: Colors.white),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.link, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}