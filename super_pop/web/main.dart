library super_pop;

import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'package:vector_math/vector_math.dart';

part 'super_pop.dart';
part 'gem.dart';
part 'board.dart';

SuperPop game;
CanvasElement canvas;

double lastFrameTime = 0.0;

void main() {
  init();
}

void init() {
  canvas = querySelector('#game');
  game = new SuperPop(canvas);
  
  // mouseClick is handled in mouseDown->mouseUp
  canvas.onMouseDown.listen(mouseDown);
  canvas.onMouseMove.listen(mouseMove);
  canvas.onMouseUp.listen(mouseUp);
  
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
  game.mouseDown(getMouseCanvasPosition(e));
}

void mouseMove(MouseEvent e) {
  game.mouseMove(getMouseCanvasPosition(e));
}

void mouseUp(MouseEvent e) {
  game.mouseUp(getMouseCanvasPosition(e));
}

Vector2 getMouseCanvasPosition(MouseEvent e) {
  Rectangle rect = canvas.getBoundingClientRect();

  var x = e.client.x - rect.left;
  var y = e.client.y - rect.top;
  return new Vector2(x, y);
}
