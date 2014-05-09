library super_pop;

import 'dart:html';
import 'dart:math';
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
  
  canvas.onMouseDown.listen(mouseDown);
  canvas.onClick.listen(mouseDown);
  canvas.onMouseMove.listen(mouseMove);
  
  scheduleMicrotask(game.start);
  window.animationFrame.then(update);
}

void update(double frameTime) {
  double dt = (frameTime - lastFrameTime).toDouble() / 1000.0;
  game.update(dt);
  
  lastFrameTime = frameTime;
  window.animationFrame.then(update);
}

void mouseDown(MouseEvent e) {
  Rectangle rect = canvas.getBoundingClientRect();
  
  int x = (e.client.x - rect.left).toInt();
  int y = (e.client.y - rect.top).toInt();
      
  game.mouseDown(x, y);
}

void mouseMove(MouseEvent e) {
  Rectangle rect = canvas.getBoundingClientRect();

  int x = (e.client.x - rect.left).toInt();
  int y = (e.client.y - rect.top).toInt();
  game.mouseMove(x, y);
}
