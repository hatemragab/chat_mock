enum GroupRole { owner, admin, member }

enum GroupDeparture { left, removed }

class GroupMember {
  GroupMember({
    required this.id,
    required this.name,
    this.role = GroupRole.member,
    this.active = true,
  });
  final String id;
  String name;
  GroupRole role;
  bool active;
  GroupDeparture? departure;
}
