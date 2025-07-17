import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
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
    Future.microtask(() {
      ref.read(userViewModelProvider.notifier).fetchUserProfile();
    });
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

            if (state.isSuccess && state.userList.isNotEmpty) {
              return ListView.separated(
                itemCount: state.userList.length,
                separatorBuilder: (_, __) =>
                const Divider(color: Colors.white24, height: 32),
                itemBuilder: (_, index) {
                  final user = state.userList[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoCard("User ID", user["user_id"] ?? "N/A"),
                      _infoCard("First Name", user["first_name"] ?? "N/A"),
                      _infoCard("Last Name", user["last_name"] ?? "N/A"),
                      _infoCard("Phone", user["phone"] ?? "N/A"),
                      _infoCard("Wallet Address", user["wallet"] ?? "N/A"),
                      _infoCard("Created At", user["created_at"] ?? "N/A"),
                    ],
                  );
                },
              );
            }

            return Center(
              child: Text(
                state.message ?? "Failed to load user info",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(userViewModelProvider.notifier).fetchUserProfile();
        },
        child: const Icon(Icons.refresh),
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
