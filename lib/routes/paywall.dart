import 'package:flutter/material.dart';
import 'package:objectremove/config.dart';

class UnlockProScreen extends StatefulWidget {
  const UnlockProScreen({super.key});

  @override
  State<UnlockProScreen> createState() => _UnlockProScreenState();
}

class _UnlockProScreenState extends State<UnlockProScreen> {
  int selectedPlan = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section with image and buttons in Stack
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                // Background Image (not full screen)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.girls),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Gradient overlay on image
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),

                // Close Button
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close, 
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Restore Button
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.red.shade400,
                    ),
                    child: const Text(
                      "Restore",
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom section with content
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: const BoxDecoration(
                color: Colors.black,
                //borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Unlock Pro ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: "Tools",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Edit smarter, faster, better",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),

                  // Features
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 12,
                    children: const [
                      FeatureTile(title: 'AI Magic Eraser'),
                      FeatureTile(title: 'Unlimited Usage', ),
                      FeatureTile(title: 'AI Image expander'),
                      FeatureTile(title: 'High Quality Result', ),
                      FeatureTile(title: 'AI Object Replacer'),
                      FeatureTile(title: '100% Ads free'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Plans
                  // ...existing code...
                  // Plans
                  Column(
                    children: [
                      buildPlanTile(
                        index: 0,
                        label: "7-Day Full Access 🌟",
                        subLabel: "then ₹199.00 per week",
                        price: "₹49",
                        highlight: "Most Popular",
                        isSelected: selectedPlan == 0,
                        onTap: () => setState(() => selectedPlan = 0),
                      ),
                      const SizedBox(height: 12),
                      buildPlanTile(
                        index: 1,
                        label: "1 Year Full Access 🔝",
                        subLabel: "then ₹3999.00 per year",
                        price: "₹3999",
                        // Remove highlight parameter - it defaults to null
                        isSelected: selectedPlan == 1,
                        onTap: () => setState(() => selectedPlan = 1),
                      ),
                    ],
                  ),
// ...existing code...

                  const Spacer(),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Handle purchase logic here
                        // For now, navigate to gallery
                        Navigator.pushReplacementNamed(context, '/gallery');
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Cancel Anytime  |  Terms & Conditions",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ...existing buildPlanTile method...
Widget buildPlanTile({
  required int index,
  required String label,
  required String subLabel,
  required String price,
  String? highlight,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.redAccent : Colors.grey.shade800,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(14),
            color: isSelected ? Colors.grey.shade900 : Colors.black,
          ),
          child: Row(
            children: [
              Radio<int>(
                value: index,
                groupValue: selectedPlan,
                onChanged: (_) => onTap(),
                activeColor: Colors.redAccent,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subLabel,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Most Popular badge positioned along the border
        if (highlight != null)
          Positioned(
            top: -1,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Text(
                highlight,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}}
// ...existing FeatureTile class...
class FeatureTile extends StatelessWidget {
  final String title;
  final bool checked;

  const FeatureTile({
    super.key,
    required this.title,
    this.checked = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          checked ? Icons.check_circle : Icons.cancel,
          color: checked ? Colors.white : Colors.redAccent,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: checked ? Colors.white : Colors.white60,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}