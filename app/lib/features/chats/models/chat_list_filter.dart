import '../../../shared/copy/common_copy.dart';
import '../copy/chats_copy.dart';

enum ChatListFilter {
  all,
  unread,
  contacts,
  groups,
  business;

  String get label => switch (this) {
    all => CommonCopy.all,
    unread => ChatCopy.unread,
    contacts => ChatCopy.contacts,
    groups => ChatCopy.groups,
    business => ChatCopy.business,
  };
}
