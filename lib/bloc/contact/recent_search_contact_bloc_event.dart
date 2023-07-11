part of 'recent_search_contact_bloc.dart';

abstract class RecentSearchContactBlocEvent {}

class LoadEvent extends RecentSearchContactBlocEvent {}

class RemoveEvent extends RecentSearchContactBlocEvent {
  String playerId;

  RemoveEvent(this.playerId);
}

class RemoveAllEvent extends RecentSearchContactBlocEvent {}

class AddEvent extends RecentSearchContactBlocEvent {
  ContactModel contact;

  AddEvent(this.contact);
}

class LoadingEvent extends RecentSearchContactBlocEvent {}

class InitEvent extends RecentSearchContactBlocEvent {}

class ReloadEvent extends RecentSearchContactBlocEvent {}