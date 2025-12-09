abstract class MasterUserEvent {}

class LoadMasterUsers extends MasterUserEvent {}

class DeleteUserEvent extends MasterUserEvent {
  final String idUser;
  DeleteUserEvent(this.idUser);
}