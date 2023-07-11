part of 'search_contacts_bloc.dart';

abstract class SearchContactsBlocEvent {}

class SearchEvent extends SearchContactsBlocEvent {
  String keyword;

  SearchEvent(this.keyword);
}

class InitSearchContactsEvent extends SearchContactsBlocEvent {}

class ReloadSearchContactsEvent extends SearchContactsBlocEvent {
  final String? removeContactPlayerId;
  final ContactModel? addContact;

  ReloadSearchContactsEvent({this.removeContactPlayerId, this.addContact});
}
