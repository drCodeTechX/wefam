import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wefam/core/theme/colors.dart';
import 'package:wefam/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => ref.read(authStateProvider.notifier).logout(),
            )
        ],
      ),
      body: familyAsync.when(
        data: (family) {
          if (family == null) return const Center(child: Text('Not logged in'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard('Family Info', [
                    _buildInfoRow('Family Name', family.familyName),
                    _buildInfoRow('Username', family.username),
                    _buildInfoRow('Course', family.course),
                    _buildInfoRow('Level', family.level),
                ]),
                const SizedBox(height: 16),
                _buildInfoCard('Parents', family.parents.map((p) => '${p.name} (${p.phone})').toList()),
                const SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () {
                            // TODO: Implement Change Password
                        },
                        child: const Text('Change Password'),
                    ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> info) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const Divider(),
                    ...info.map((i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(i, style: const TextStyle(fontSize: 16)),
                    )),
                ],
            ),
        ),
    );
  }

  String _buildInfoRow(String label, String value) {
      return '$label: $value';
  }
}