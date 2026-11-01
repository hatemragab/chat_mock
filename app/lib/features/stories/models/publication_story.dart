import 'package:flutter/material.dart';

import '../../publishing/models/publication.dart';
import 'story.dart';

/// Resolves the local sample used consistently by the editor and published Story.
String? publicationAssetFor(String sample, {String cover = 'Default'}) {
  if (sample.trim().isEmpty) return null;
  final value = sample.toLowerCase();
  final base = value.contains('city')
      ? 'assets/story/daily_brew.png'
      : value.contains('creative') || value.contains('camera')
      ? 'assets/story/maison_studio.png'
      : 'assets/story/green_corner.png';
  if (cover != 'Artwork') return base;
  return base == 'assets/story/maison_studio.png'
      ? 'assets/story/green_corner.png'
      : 'assets/story/maison_studio.png';
}

Story _project({
  required String id,
  required String author,
  required PublicationType type,
  required String category,
  required PublicationMedia media,
  required String sample,
  required String caption,
  required bool boosted,
  required bool popular,
  required int rotation,
  required double cropScale,
  required double trimStart,
  required double trimEnd,
  required String cover,
}) => Story(
  id: id,
  author: author,
  title: caption.isEmpty ? sample : caption,
  category: category,
  kind: StoryKind.own,
  media: switch (media) {
    PublicationMedia.photo => StoryMedia.photo,
    PublicationMedia.video => StoryMedia.video,
    PublicationMedia.audio => StoryMedia.audio,
  },
  colors: const [Color(0xFF86B6AA), Color(0xFF416C66)],
  boosted: boosted,
  popular: popular,
  sponsored: type == PublicationType.advertisement,
  assetPath: publicationAssetFor(sample, cover: cover),
  sampleLabel: sample,
  rotation: rotation,
  cropScale: cropScale,
  trimStart: trimStart,
  trimEnd: trimEnd,
  coverLabel: cover,
);

Story storyForPublication(
  Publication publication, {
  required String author,
  bool popular = false,
}) => _project(
  id: publication.id,
  author: author,
  type: publication.type,
  category: publication.category,
  media: publication.media,
  sample: publication.sample,
  caption: publication.caption,
  boosted: publication.boosted,
  popular: popular,
  rotation: publication.rotation,
  cropScale: publication.cropScale,
  trimStart: publication.trimStart,
  trimEnd: publication.trimEnd,
  cover: publication.cover,
);

Story storyForDraft(PublicationDraft draft, {String author = 'Preview'}) =>
    _project(
      id: draft.id,
      author: author,
      type: draft.type,
      category: draft.category,
      media: draft.media,
      sample: draft.sample,
      caption: draft.caption,
      boosted: draft.effectiveBoost,
      popular: false,
      rotation: draft.rotation,
      cropScale: draft.cropScale,
      trimStart: draft.trimStart,
      trimEnd: draft.trimEnd,
      cover: draft.cover,
    );
