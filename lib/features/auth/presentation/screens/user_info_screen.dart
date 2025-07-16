import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/storage/hive_manager.dart';
import '../viewmodels/user_viewmodel.dart';


class UserInfoScreen extends ConsumerStatefulWidget {
  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  @override
  void initState() {
    super.initState();

    final userId = HiveManager.box.get("user_id");
    if (userId != null) {

      print("user id found"+userId);
      Future.microtask(() {
        ref.read(userViewModelProvider.notifier).fetchUserProfile(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: const Text("User Info"),
      foregroundColor: Colors.white,
      leading: const BackButton(),
    ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (_) {
            if (state.isLoading) {
              return _shimmerList();
            }

            if (state.isSuccess) {
              // Display from Hive
              final userId = HiveManager.box.get("user_id") ?? "N/A";
              final firstName = HiveManager.box.get("first_name") ?? "N/A";
              final lastName = HiveManager.box.get("last_name") ?? "N/A";
              final phone = HiveManager.box.get("phone") ?? "N/A";
              final wallet = HiveManager.box.get("wallet") ?? "N/A";
              final createdAt = HiveManager.box.get("created_at") ?? "N/A";

              return ListView(
                children: [
                  _infoCard("User ID", userId),
                  _infoCard("First Name", firstName),
                  _infoCard("Last Name", lastName),
                  _infoCard("Phone", phone),
                  _infoCard("Wallet Address", wallet),
                  _infoCard("Created At", createdAt),
                ],
              );
            }

// Always show error if not loading and not success
            return Center(
              child: Text(
                state.message ?? "Failed to load user info",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );


            return Center(
              child: Text(
                state.message ?? "Failed to load user info",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _shimmerList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[600]!,
        child: Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
