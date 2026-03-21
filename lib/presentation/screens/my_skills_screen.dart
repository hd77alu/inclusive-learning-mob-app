import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/skills_bloc.dart';
import '../../data/services/firestore_service.dart';
import '../../data/models/skill_model.dart';

class MySkillsScreen extends StatelessWidget {
  const MySkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SkillsBloc(FirestoreService())..add(LoadSkills()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Skills"),
        ),
        body: BlocConsumer<SkillsBloc, SkillsState>(
          listener: (context, state) {
            if (state is SkillsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is SkillsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SkillsLoaded) {
              return ListView.builder(
                itemCount: state.skills.length,
                itemBuilder: (context, index) {
                  final skill = state.skills[index];
                  return ListTile(
                    leading: const Icon(Icons.code),
                    title: Text(skill.name),
                    subtitle: Text(skill.level),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showSkillDialog(context, skill: skill),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<SkillsBloc>().add(DeleteSkill(skill.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Skill deleted')),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return const Center(child: Text('No skills yet'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showSkillDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showSkillDialog(BuildContext context, {Skill? skill}) {
    final nameController = TextEditingController(text: skill?.name ?? '');
    final levelController = TextEditingController(text: skill?.level ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(skill == null ? 'Add Skill' : 'Update Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Skill Name'),
            ),
            TextField(
              controller: levelController,
              decoration: const InputDecoration(labelText: 'Level'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newSkill = Skill(
                id: skill?.id ?? '',
                name: nameController.text,
                level: levelController.text,
              );

              if (skill == null) {
                context.read<SkillsBloc>().add(AddSkill(newSkill));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Skill added successfully')),
                );
              } else {
                context.read<SkillsBloc>().add(UpdateSkill(newSkill));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Skill updated successfully')),
                );
              }

              Navigator.pop(dialogContext);
            },
            child: Text(skill == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}