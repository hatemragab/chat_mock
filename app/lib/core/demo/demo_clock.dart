/// A session clock that can be advanced without changing the host clock.
class DemoClock {
  Duration _offset = Duration.zero;

  DateTime now() => DateTime.now().add(_offset);

  void advance(Duration duration) {
    if (duration.isNegative) throw ArgumentError.value(duration, 'duration');
    _offset += duration;
  }

  void reset() => _offset = Duration.zero;
}
