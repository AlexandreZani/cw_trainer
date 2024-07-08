import 'dart:typed_data';

List<int> _littleEndian32(int x) {
  return [
    x & 0xff,
    (x >> 8) & 0xff,
    (x >> 16) & 0xff,
    (x >> 32) & 0xff,
  ];
}

List<int> _ascii(String s) {
  List<int> b = [];
  for (var i = 0; i < s.length; i++) {
    b.add(s.codeUnitAt(i));
  }
  return b;
}

Uint8List pcmToWav(List<int> frames, int sampleRate) {
  int bSize = frames.length + 36;
  int channels = 1;
  int byteRate = (sampleRate * channels);
  Uint8List wav = Uint8List.fromList([
    ..._ascii('RIFF'),
    ..._littleEndian32(bSize),
    ..._ascii('WAVE'),
    ..._ascii('fmt '),
    16, 0, 0, 0, // format chunk size of 16
    1, 0, // PCM integer
    1, 0, // 1 channel
    ..._littleEndian32(sampleRate),
    ..._littleEndian32(byteRate),
    1, 0, // bytes per block
    8, 0, // bit size
    ..._ascii('data'),
    ..._littleEndian32(frames.length),
    ...frames,
  ]);
  return wav;
}