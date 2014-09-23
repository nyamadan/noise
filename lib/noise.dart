library noise;

import "dart:math" as Math;
import "dart:typed_data";

num _cubicInterpolate(num x, num v0, num v1, num v2, num v3) {
  num p = (v3 - v2) - (v0 - v1);
  num q = (v0 - v1) - p;
  num r = v2 - v0;
  num s = v1;

  return p * x * x * x + q * x * x + r * x + s;
}

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

    return _cubicInterpolate(x, v0, v1, v2, v3);
  });
}

List<List<num>> createRandomNoise2D(int length, int wavelength, num func(int w, int h)) {
  int sample_length = length ~/ wavelength + 5;

  if (length % wavelength != 0) {
    sample_length++;
  }

  List <List<num>> samples = new List<List<num>>.generate(sample_length, (int h){
    return new List<num>.generate(sample_length, (int w){
      return func(w - 2, h - 2);
    }, growable: false);
  }, growable: false);

  samples = new List<List<num>>.generate(sample_length - 2, (int h){
    return new List<num>.generate(sample_length - 2, (int w){
      return (samples[h][w] + samples[h][w+2] + samples[h+2][w] + samples[h+2][w+2]) * 0.0625
        + (samples[h+1][w] + samples[h+1][w+2] + samples[h+2][w+1] + samples[h][w+1]) * 0.125
        + samples[h+1][w+1] * 0.25;
    }, growable: false);
  }, growable: false);

  return new List<List<num>>.generate(length, (int h){
    return new List<num>.generate(length, (int w){
      int i_w = w ~/ wavelength;
      int i_h = h ~/ wavelength;
      double x = (w % wavelength) / wavelength;
      double y = (h % wavelength) / wavelength;

      List<num> v = new List<num>.generate(4, (int i){
        num v0_x = samples[i_h+i][i_w+0];
        num v1_x = samples[i_h+i][i_w+1];
        num v2_x = samples[i_h+i][i_w+2];
        num v3_x = samples[i_h+i][i_w+3];
        return _cubicInterpolate(x, v0_x, v1_x, v2_x, v3_x);
      });

      return _cubicInterpolate(y, v[0], v[1], v[2], v[3]);
    });
  });
}

List<num> createPerlinNoise(int length, int wavelength, num persistence, num func(int index, num amplitude)) {
  List<num> buffer = new List<num>.generate(length, (int index) =>  0, growable: false);

  int count = 0;
  num total_amplitude = 0.0;
  while(wavelength > 0) {
    num amplitude = Math.pow(persistence, count);

    List<num> noise = createRandomNoise(length, wavelength, (int index){
      return func(index, amplitude);
    });

    for(int i = 0; i < length; i++) {
      buffer[i] = buffer[i] + noise[i];
    }

    total_amplitude += amplitude;
    wavelength = wavelength ~/ 2;
    count = count + 1;
  }

  for(int i = 0; i < length; i++){
    buffer[i] /= total_amplitude;
  }

  return buffer;
}

List<List<num>> createPerlinNoise2D(int length, int wavelength, num persistence, num func(int w, int h, num amplitude)) {
  List<List<num>> buffer = new List<List<num>>.generate(length, (int h){
    return new List<num>.generate(length, (int w){
      return 0;
    }, growable: false);
  }, growable: false);

  int count = 0;
  num total_amplitude = 0.0;
  while(wavelength > 0) {
    num amplitude = Math.pow(persistence, count);

    List<List<num>> noise = createRandomNoise2D(length, wavelength, (int w, int h){
      return func(w, h, amplitude);
    });

    for(int h = 0; h < length; h++) {
      for(int w = 0; w < length; w++) {
        buffer[h][w] += noise[h][w];
      }
    }

    total_amplitude += amplitude;
    wavelength = wavelength ~/ 2;
    count = count + 1;
  }

  for(int h = 0; h < length; h++){
    for(int w = 0; w < length; w++){
      buffer[h][w] /= total_amplitude;
    }
  }

  return buffer;
}

