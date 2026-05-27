import 'dart:typed_data';

List<int> _littleEndian32(int x) {
  return [
    x & 0xff,
    (x >> 8) & 0xff,
    (x >> 16) & 0xff,
    (x >> 24) & 0xff,
  ];
}

List<int> _ascii(String s) {
  List<int> b = [];
  for (var i = 0; i < s.length; i++) {
    b.add(s.codeUnitAt(i));
  }
  return b;
}

// Converts unsigned 8-bit PCM (center 128) samples to 16-bit signed
// little-endian PCM and wraps in a WAV container. AVPlayer on iOS does not
// reliably play 8-bit WAV; 16-bit signed is the lowest-common-denominator.
Uint8List pcmToWav(List<int> frames, int sampleRate) {
  const bitsPerSample = 16;
  const channels = 1;
  final blockAlign = channels * (bitsPerSample ~/ 8);
  final byteRate = sampleRate * blockAlign;
  final dataLen = frames.length * 2;
  final bSize = dataLen + 36;

  final samples = Uint8List(dataLen);
  final view = ByteData.view(samples.buffer);
  for (int i = 0; i < frames.length; i++) {
    final s16 = (frames[i] - 128) * 256;
    view.setInt16(i * 2, s16, Endian.little);
  }

  return Uint8List.fromList([
    ..._ascii('RIFF'),
    ..._littleEndian32(bSize),
    ..._ascii('WAVE'),
    ..._ascii('fmt '),
    16, 0, 0, 0, // format chunk size of 16
    1, 0, // PCM integer
    channels, 0,
    ..._littleEndian32(sampleRate),
    ..._littleEndian32(byteRate),
    blockAlign, 0,
    bitsPerSample, 0,
    ..._ascii('data'),
    ..._littleEndian32(dataLen),
    ...samples,
  ]);
}
