import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Everything About Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section ---
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 90,
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Smart Expense Tracker',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Version 1.0.0 Stable Build',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '“Empowering your wallet, one tap at a time.”',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- Our Story Section ---
            _buildSectionTitle('The Story Behind the App'),
            const Text(
              'In today\'s fast-paced world, money flows in and out of our digital wallets faster than we can track. We noticed that most people struggle with the same question at the end of every month: "Where did all my money go?"\n\nSmart Expense Tracker was built to solve this exact problem. We wanted to create an app that wasn\'t just a list of numbers, but a visual companion that helps you understand your spending patterns and encourages you to save for what truly matters.',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 32),

            // --- Why We Are Different Section ---
            _buildSectionTitle('Why Choose Smart Expense Tracker?'),
            const Text(
              'Unlike heavy accounting software, we focus on the "User First" approach. We believe tracking shouldn\'t be a chore.',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 16),
            const _BulletItem(title: 'Speed:', text: 'Log a transaction in less than 5 seconds. No complex menus.'),
            const _BulletItem(title: 'Context:', text: 'Categorize by Food, Shopping, Transport, etc., to see the full picture.'),
            const _BulletItem(title: 'Flexibility:', text: 'Track JazzCash, Easypaisa, Card, and Cash in one unified view.'),
            const _BulletItem(title: 'Privacy:', text: 'Your data is locked to your account. We don\'t sell your data.'),
            const SizedBox(height: 32),

            // --- Deep Dive into Features ---
            _buildSectionTitle('Comprehensive Features'),
            const _FeatureCard(
              icon: Icons.track_changes_rounded,
              title: 'Real-Time Transaction Logging',
              description: 'Record your income and expenses as they happen. Add titles, amounts, and specific payment methods to keep your records accurate.',
            ),
            const _FeatureCard(
              icon: Icons.auto_graph_rounded,
              title: 'Visual Analytics',
              description: 'Our dynamic pie charts and breakdown lists show you the percentage of your income spent on different lifestyle categories.',
            ),
            const _FeatureCard(
              icon: Icons.notifications_active_outlined,
              title: 'Intelligent Budgeting',
              description: 'Set monthly limits for specific categories. Our system monitors your spending and warns you as you approach your self-defined limits.',
            ),
            const _FeatureCard(
              icon: Icons.cloud_done_outlined,
              title: 'Cloud Sync & Local Backup',
              description: 'Using Firebase for secure cloud storage and Hive for lightning-fast local access, your data is always safe even if you lose your phone.',
            ),
            const _FeatureCard(
              icon: Icons.palette_outlined,
              title: 'Personalized Experience',
              description: 'Toggle between our professional Light Mode and our premium high-contrast Black & Green Dark Mode for better night-time tracking.',
            ),
            const SizedBox(height: 32),

            // --- Financial Health Tips ---
            _buildSectionTitle('Tips for Financial Freedom'),
            const _TipBox(
              text: 'The 50/30/20 Rule: Try to spend 50% on needs, 30% on wants, and save 20% of your income.',
            ),
            const _TipBox(
              text: 'Track Everything: Even small "Chaye" or "Snack" expenses add up to thousands at the end of the month.',
            ),
            const _TipBox(
              text: 'Set Realistic Budgets: Don\'t be too strict initially. Start with what you actually spend, then gradually reduce it.',
            ),
            const SizedBox(height: 32),

            // --- Privacy & Security ---
            _buildSectionTitle('Security & Privacy Policy'),
            const Text(
              'Your trust is our most valuable asset. We use Firebase Authentication to ensure that only you can access your data. Your data is stored in isolated Hive boxes on your device, unique to your UID. We do not track your location, access your contacts, or read your messages. Your financial life is private, and we keep it that way.',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 32),

            // --- Technical Stack ---
            _buildSectionTitle('Technical Specifications'),
            const Text(
              'This application is built using the latest industry-standard technologies:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Framework: Flutter (by Google)'),
            const Text('• Backend: Firebase Realtime Database'),
            const Text('• Local Storage: Hive (NoSQL)'),
            const Text('• State Management: Provider Pattern'),
            const Text('• Charts: FL Chart Library'),
            const SizedBox(height: 32),

            // --- The Future Roadmap ---
            _buildSectionTitle('Future Roadmap'),
            const Text(
              'We are constantly working to improve. In future updates, expect:',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Text('1. Recurring expenses (Monthly Bills automation)'),
            const Text('2. PDF Statement Export for tax filing'),
            const Text('3. Multiple user collaboration (Shared family budgets)'),
            const Text('4. AI-based spending predictions'),
            const SizedBox(height: 32),

            // --- Footer ---
            const Divider(),
            const SizedBox(height: 24),
            const Center(
              child: Column(
                children: [
                  Text(
                    'Smart Expense Tracker Team',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Designed and developed with extreme care and thousands of lines of code to ensure you have the best experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.terminal, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Built for the community.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String title;
  final String text;
  const _BulletItem({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 20, color: Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipBox extends StatelessWidget {
  final String text;
  const _TipBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
