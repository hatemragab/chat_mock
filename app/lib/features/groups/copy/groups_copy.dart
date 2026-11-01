import '../models/group_member.dart';
import '../models/group_photo.dart';

/// English UI copy for the groups feature.
abstract final class GroupCopy {
  static String photoLabel(GroupPhoto photo) => switch (photo) {
    GroupPhoto.none => groupPhoto,
    GroupPhoto.garden => 'Green garden',
    GroupPhoto.studio => 'Creative studio',
    GroupPhoto.cafe => 'Morning coffee',
  };
  static const groupPhoto = 'group photo';
  static const addGroupPhoto = 'Add group photo';
  static const changeGroupPhoto = 'Change group photo';
  static const chooseGroupPhoto = 'Choose a group photo';
  static const creatingGroup = 'Creating group…';
  static const cancelCreation = 'Cancel creation';
  static const groupCreationFailed =
      'Could not create this group. Your details are still here; try again.';
  static String roleLabel(GroupRole role) => switch (role) {
    GroupRole.owner => 'owner',
    GroupRole.admin => 'admin',
    GroupRole.member => 'member',
  };
  static String removeMemberTitle(String name) => 'Remove $name?';
  static String promoteMemberTitle(String name) => 'Promote $name?';
  static String demoteMemberTitle(String name) => 'Demote $name?';
  static String transferOwnershipTitle(String name) =>
      'Transfer ownership to $name?';
  static String leaveGroupTitle(String name) => 'Leave $name?';
  static String memberCount(int count) => '$count members';
  static String selectedCount(int count) => '$count selected';
  static String addMemberCount(int count) =>
      'Add $count ${count == 1 ? 'member' : 'members'}';
  static const addMembers = 'Add members';
  static const alreadyAMember = 'Already a member';
  static const cancelUpdate = 'Cancel update';
  static const cannotManageMember =
      'You do not have permission to manage this member.';
  static const chooseAtLeastOneContact = 'Choose at least one contact';
  static const chooseAtLeastOneContactError = 'Choose at least one contact.';
  static const chooseNewOwner = 'Choose new owner';
  static const chooseOwner = 'Choose owner';
  static const createGroup = 'Create group';
  static const demote = 'Demote';
  static const demoteAdmin = 'Demote admin';
  static const demoteMemberDescription =
      'They will remain in the group as a member.';
  static const description = 'Description';
  static const descriptionOptional = 'Description (optional)';
  static const discard = 'Discard';
  static const discardChanges = 'Discard changes?';
  static const editGroup = 'Edit group';
  static const enterAGroupName = 'Enter a group name';
  static const groupDetails = 'Group details';
  static const groupInfo = 'Group info';
  static const groupMembers = 'Group members';
  static const groupName = 'Group name';
  static const groupPermissions = 'Group permissions';
  static const groupUpdateFailed =
      'Could not update this group. Your changes are still here; try again.';
  static const keepEditing = 'Keep editing';
  static const leave = 'Leave';
  static const leaveGroup = 'Leave group';
  static const leaveGroupDescription =
      'You will no longer receive messages, but you can still read this history.';
  static const leftGroupReadOnly = 'You left this group. History is read-only.';
  static const mediaFilesAndLinks = 'Media, files and links';
  static const message = 'Message';
  static const muteNotifications = 'Mute notifications';
  static const newGroup = 'New group';
  static const noMatchingContacts = 'No matching contacts.';
  static const noMembersMatchYourSearch = 'No members match your search.';
  static const onlyAdminsCanEditGroupDetails =
      'Only admins can edit group details';
  static const onlyAdminsCanManageMembers = 'Only admins can manage members';
  static const onlyAdminsCanSend = 'Only admins can send messages';
  static const onlyAdminsCanSendDescription = 'Only admins can send messages.';
  static const ownerMustTransferDescription =
      'Choose another member as owner before leaving this group.';
  static const permissionsDescription =
      'Choose which actions only admins can perform.';
  static const permissionsReadOnly =
      'Only group admins can change these settings.';
  static const promote = 'Promote';
  static const promoteMemberDescription =
      'They will be able to manage this group as an admin.';
  static const promoteToAdmin = 'Promote to admin';
  static const removeMember = 'Remove member';
  static const removeMemberDescription =
      'They will no longer receive new group messages.';
  static const removedGroupReadOnly =
      'You are no longer a member. History is read-only.';
  static const saveChanges = 'Save changes';
  static const searchContacts = 'Search contacts';
  static const searchConversation = 'Search conversation';
  static const searchMembers = 'Search members';
  static const selectAtLeastOneContact = 'Select at least one contact';
  static const selectMembers = 'Select members';
  static const starredMessages = 'Starred messages';
  static const transfer = 'Transfer';
  static const transferOwnership = 'Transfer ownership';
  static const transferOwnershipDescription =
      'They become the owner and you become an admin.';
  static const transferOwnershipFirst = 'Transfer ownership first';
  static const unsavedGroupDescription =
      'Your group changes have not been saved.';
  static const unsavedNewGroupDescription =
      'Your new group has not been created.';
  static const updatingGroup = 'Updating group…';
  static const viewProfile = 'View profile';
  static const you = 'You';
}
