library noise;

import "dart:math" as Math;
import "dart:typed_data";

List<num> createRandomNoise(int length, int wavelength, num func(int index)) {
  int sample_length = length ~/ wavelength + 5;

  if (length % wavelength != 0) {
    sample_length++;
  }

  List<num> samples = new List<num>.generate(sample_length, (int index){
    return func(index - 2);
  }, growable: false);

  samples = new List<num>.generate(sample_length - 2, (int index){
    var v0 = samples[index];
    var v1 = samples[index + 1];
    var v2 = samples[index + 2];

    return v0 * 0.25 + v1 * 0.5 + v2 * 0.25;
  }, growable: false);

  return new List<num>.generate(length, (int index){
    int sample_index = index ~/ wavelength;
    num v0 = samples[sample_index];
    num v1 = samples[sample_index + 1];
    num v2 = samples[sample_index + 2];
    num v3 = samples[sample_index + 3];
    double x = (index % wavelength) / wavelength;

    num p = (v3 - v2) - (v0 - v1);
    num q = (v0 - v1) - p;
    num r = v2 - v0;
    num s = v1;

    return p * x * x * x + q * x * x + r * x + s;
  });
}

List<num> createPerlinNoise(int length, int wavelength, num persistence, num func(int index, num amplitude)) {
  List<num> buffer = new List<num>.generate(length, (int index) =>  0, growable: false);
  int count = 0;
  while(wavelength > 0) {
    num amplitude = Math.pow(persistence, count);

    List<num> noise = createRandomNoise(length, wavelength, (int index){
      return amplitude * func(index, amplitude);
    });

    for(int i = 0; i < length; i++) {
      buffer[i] = buffer[i] + noise[i];
    }

    wavelength = wavelength ~/ 2;
    count = count + 1;
  }

  return buffer;
}
