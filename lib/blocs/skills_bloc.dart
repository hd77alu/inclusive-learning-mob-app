import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/skill_model.dart';
import '../services/firestore_service.dart';

abstract class SkillsEvent {}

class LoadSkills extends SkillsEvent {}

class AddSkill extends SkillsEvent {
  final Skill skill;
  AddSkill(this.skill);
}

class UpdateSkill extends SkillsEvent {
  final Skill skill;
  UpdateSkill(this.skill);
}

class DeleteSkill extends SkillsEvent {
  final String skillId;
  DeleteSkill(this.skillId);
}

abstract class SkillsState {}

class SkillsInitial extends SkillsState {}

class SkillsLoading extends SkillsState {}

class SkillsLoaded extends SkillsState {
  final List<Skill> skills;
  SkillsLoaded(this.skills);
}

class SkillsError extends SkillsState {
  final String message;
  SkillsError(this.message);
}

class SkillsBloc extends Bloc<SkillsEvent, SkillsState> {
  final FirestoreService firestoreService;

  SkillsBloc(this.firestoreService) : super(SkillsInitial()) {
    on<LoadSkills>((event, emit) async {
      emit(SkillsLoading());
      try {
        final skills = await firestoreService.getSkills();
        emit(SkillsLoaded(skills));
      } catch (e) {
        emit(SkillsError('Failed to load skills'));
      }
    });

    on<AddSkill>((event, emit) async {
      try {
        await firestoreService.addSkill(event.skill);
        add(LoadSkills());
      } catch (e) {
        emit(SkillsError('Failed to add skill'));
      }
    });

    on<UpdateSkill>((event, emit) async {
      try {
        await firestoreService.updateSkill(event.skill);
        add(LoadSkills());
      } catch (e) {
        emit(SkillsError('Failed to update skill'));
      }
    });

    on<DeleteSkill>((event, emit) async {
      try {
        await firestoreService.deleteSkill(event.skillId);
        add(LoadSkills());
      } catch (e) {
        emit(SkillsError('Failed to delete skill'));
      }
    });
  }
}
