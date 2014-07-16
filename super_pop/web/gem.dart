part of super_pop;

class Gem {
  Vector2 position;
  double moveTimer = 0.0;
  double moveTime = 0.5;
  
  // TODO: "Enum", see GameState
  int type = -1;
  // TODO: Use invalid as bool instead, since invalids should render their correct state and fade out
  // bool invalid = false;
  int fallDistance = 0;
  double scale = 1.0;
  bool returnOnSwap = false;
  var swapDoneCallback;
  Sprite sprite;
  Gem(this.position, this.type) {
    sprite = new Sprite(SuperPop.spriteSheet, 64, 64);
  }
}
