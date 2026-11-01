/// English copy for the profile feature.
abstract final class ProfileCopy {
  static const outdoorPortrait = 'Outdoor portrait';
  static const art = 'Art';
  static const design = 'Design';
  static const food = 'Food';
  static const music = 'Music';
  static const travel = 'Travel';
  static const sports = 'Sports';
  static const technology = 'Technology';
  static const fashion = 'Fashion';
  static const cameroon = 'Cameroon';
  static const profilePhoto = 'profile photo';
  static const discardChangesTitle = 'Discard changes?';
  static const unsavedProfileDescription =
      'Your profile changes have not been saved.';
  static const keepEditing = 'Keep editing';
  static const discard = 'Discard';
  static const profilePhotoLabel = 'Profile photo';
  static const editProfile = 'Edit profile';
  static const changeProfilePhoto = 'Change profile photo';
  static const name = 'Name';
  static const enterYourName = 'Enter your name.';
  static const about = 'About';
  static const gender = 'Gender';
  static const preferNotToSay = 'Prefer not to say';
  static const woman = 'Woman';
  static const man = 'Man';
  static const anotherIdentity = 'Another identity';
  static const interests = 'Interests';
  static const helloThereIAmUsingWhizpee = 'Hello there! I am using Whizpee.';
  static const profile = 'Profile';
  static const myWallet = 'My wallet';
  static const creditsDiamondsAndCash = 'Credits, Diamonds and Cash';
  static const publishing = 'Publishing';
  static const createAndManageYourPublications =
      'Create and manage your publications';
  static const businessTools = 'Business tools';
  static const myPublications = 'My Publications';
  static const earnings = 'Earnings';
  static const viewDiamondActivity = 'View Diamond activity';
  static const helpSupport = 'Help & support';
  static const preferences = 'Preferences';
  static const prototypeTools = 'Prototype tools';
  static const settings = 'Settings';
  static const appearance = 'Appearance';
  static const signOut = 'Sign out';

  static String avatarSemantics(String name) => '$name profile avatar';
  static String photoSemantics(String name, String label) =>
      '$name profile photo: $label';
  static String walletSummary(int credits, int diamonds, int cash) =>
      '$credits Credits · $diamonds Diamonds · $cash XAF';
}
