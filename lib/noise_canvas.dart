library noise_canvas;

import "package:polymer/polymer.dart";
import "package:simplot/simplot.dart" as simplot;

import "package:noise/noise.dart";

import "dart:math" show Random;
import "dart:typed_data";
import "dart:html";

@CustomTag("x-noise-canvas")
class NoiseCanvas extends PolymerElement {
  Element _graphContainer;
  CanvasRenderingContext2D _ctx;

  Random _random = new Random();

  @observable String seed;
  @observable String persistence = "0.25";
  @observable String wavelength = "32";
  @observable bool isRandom = true;

  NoiseCanvas.created() : super.created()
  {
    ShadowRoot root =  this.shadowRoot;
    this._graphContainer = root.querySelector("#simPlotQuad");
    this.seed = this._random.nextInt(0xffff).toString();

    CanvasElement canvas = root.querySelector("#canvas");
    this._ctx = canvas.getContext("2d");

    this.plot();
  }

  void onRandomClick(event) {
  }

  void onSubmitGraph(event) {
    event.preventDefault();

    this.plot();
  }

  void plot() {
    num persistence = num.parse(this.persistence);
    int wavelength = num.parse(this.wavelength).toInt();

    if(this.isRandom) {
      this.seed = this._random.nextInt(0xffff).toString();
    }

    Random random = new Random(num.parse(this.seed).toInt());
    _graphContainer.childNodes.toList().forEach((Element element) => element.remove());
    simplot.plot(
      createPerlinNoise(0x100, wavelength, persistence, (int index, num amplitude){
        return amplitude * random.nextInt(0xff);
      })
      ,
      shadow: this._graphContainer
    );

    Random random2d = new Random(num.parse(this.seed).toInt());
    List<List<num>> noise2d = createPerlinNoise2D(0xff, wavelength, persistence, (int w, int h, int amplitude){
      return amplitude * random.nextInt(0xff);
    });

    ImageData image_data = this._ctx.createImageData(0xff, 0xff);
    for(int h = 0; h < 0xff; h++) {
      for(int w = 0; w < 0xff; w++) {
        int i = (0xff * h + w) * 4;
        int color = noise2d[h][w].round();
        Uint8List buffer = new Uint8List.fromList([
          color,
          color,
          color,
          0xff
        ]);
        image_data.data.setRange(i, i + 4, buffer);
      }
    }
    this._ctx.putImageData(image_data, 0, 0);
  }
}
