import 'package:flutter/material.dart';
import 'mentor_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/mentorship_bloc.dart';
import '../../services/firestore_service.dart';

class MentorshipHubScreen extends StatelessWidget {
  const MentorshipHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MentorshipBloc(FirestoreService())..add(LoadMentors()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mentorship Hub"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Available Mentors",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: BlocBuilder<MentorshipBloc, MentorshipState>(
                  builder: (context, state) {
                    if (state is MentorshipLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is MentorshipLoaded) {
                      return ListView.builder(
                        itemCount: state.mentors.length,
                        itemBuilder: (context, index) {
                          final mentor = state.mentors[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(mentor.name),
                              subtitle: Text(mentor.role),
                              trailing: Text("⭐ ${mentor.rating}"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MentorProfileScreen(mentor: mentor),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }

                    if (state is MentorshipError) {
                      return const Center(
                        child: Text("Failed to load mentors"),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}