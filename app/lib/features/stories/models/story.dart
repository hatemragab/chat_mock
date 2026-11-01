import 'package:flutter/material.dart';

enum StoryKind { business, contact, own }

enum StoryMedia { photo, video, audio }

enum StoryAvailability { active, expired, removed }

class Story {
  const Story({
    required this.id,
    required this.author,
    required this.title,
    required this.category,
    required this.kind,
    required this.media,
    required this.colors,
    this.sponsored = false,
    this.popular = false,
    this.boosted = false,
    this.assetPath,
    this.sampleLabel,
    this.rotation = 0,
    this.cropScale = 1,
    this.trimStart = 0,
    this.trimEnd = 1,
    this.coverLabel,
  });

  final String id;
  final String author;
  final String title;
  final String category;
  final StoryKind kind;
  final StoryMedia media;
  final List<Color> colors;
  final bool sponsored;
  final bool popular;
  final bool boosted;
  final String? assetPath;
  final String? sampleLabel;
  final int rotation;
  final double cropScale;
  final double trimStart;
  final double trimEnd;
  final String? coverLabel;

  /// Keeps Story content and its stable ID while presenting a contact's
  /// current session name.
  Story withAuthor(String name) => Story(
    id: id,
    author: name,
    title: title,
    category: category,
    kind: kind,
    media: media,
    colors: colors,
    sponsored: sponsored,
    popular: popular,
    boosted: boosted,
    assetPath: assetPath,
    sampleLabel: sampleLabel,
    rotation: rotation,
    cropScale: cropScale,
    trimStart: trimStart,
    trimEnd: trimEnd,
    coverLabel: coverLabel,
  );
}
