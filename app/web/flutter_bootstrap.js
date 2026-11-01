{{flutter_js}}
{{flutter_build_config}}

// Keep renderer resources and optional glyph fallback requests on this host.
// App glyphs are bundled through pubspec.yaml; the local-resource build adds Roboto.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: new URL('canvaskit/', document.baseURI).toString(),
    fontFallbackBaseUrl: new URL('assets/fonts/', document.baseURI).toString(),
  },
});
