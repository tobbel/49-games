library super_pop;

import 'dart:html';
import 'dart:async';

part 'super_pop.dart';

SuperPop game;
CanvasElement canvas;

double lastFrameTime = 0.0;

void main() {
  init();
}

void init() {
  canvas = querySelector('#game');
  game = new SuperPop(canvas);

  scheduleMicrotask(game.start);

  window.animationFrame.then(update);
}

void update(double frameTime) {
  double dt = (frameTime - lastFrameTime).toDouble() / 1000.0;
  game.update(dt);
  
  lastFrameTime = frameTime;
  window.animationFrame.then(update);
}
