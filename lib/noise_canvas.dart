library noise_canvas;

import "package:polymer/polymer.dart";
import "package:simplot/simplot.dart" as simplot;

import "package:noise/noise.dart";

import "dart:math" show Random;
import "dart:html";

@CustomTag("x-noise-canvas")
class NoiseCanvas extends PolymerElement {
  Element _graphContainer;

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
        return random.nextInt(0xff);
      })
      ,
      shadow: this._graphContainer
    );
  }
}
