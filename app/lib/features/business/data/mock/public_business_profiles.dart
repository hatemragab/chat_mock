import '../../models/public_business_profile.dart';

/// Fictional public profiles. No personal contact details are included.
const publicBusinessProfiles = <String, PublicBusinessProfile>{
  'Maison Studio': PublicBusinessProfile(
    name: 'Maison Studio',
    category: 'Design',
    description: 'Thoughtful interiors, objects and everyday spaces. Explore our latest work and talk to the studio about the Story that inspired you.',
    location: 'Douala, Cameroon',
    coverAssetPath: 'assets/story/maison_studio.png',
    logoAssetPath: 'assets/story/maison_studio.png',
  ),
  'Daily Brew': PublicBusinessProfile(
    name: 'Daily Brew',
    category: 'Food & drink',
    description: 'Fresh coffee and small moments worth sharing. Discover seasonal drinks, local treats and news from our café.',
    location: 'Yaoundé, Cameroon',
    coverAssetPath: 'assets/story/daily_brew.png',
    logoAssetPath: 'assets/story/daily_brew.png',
  ),
  'Made Local': PublicBusinessProfile(
    name: 'Made Local',
    category: 'Shopping',
    description: 'Objects made with care by independent local makers. Browse the latest collection and ask about the pieces featured in our Stories.',
  ),
  'Green Corner': PublicBusinessProfile(
    name: 'Green Corner',
    category: 'Lifestyle',
    description: 'Plants and practical inspiration for greener spaces. Explore easy ways to bring a little nature into your day.',
    coverAssetPath: 'assets/story/green_corner.png',
    logoAssetPath: 'assets/story/green_corner.png',
  ),
};
