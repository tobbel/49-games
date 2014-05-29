part of super_pop;

class Gem {
  int x, y; // TODO: Vector?
  int tX = -1;
  int tY = -1;
  double moveTimer = 0.0;
  double moveTime = 0.15;
  double renderX = 0.0;
  double renderY = 0.0;
  int type = -1;
  bool returnOnSwap = false;
  var swapDoneCallback;
  Gem(this.x, this.y, this.type) {
    renderX = this.x.toDouble();
    renderY = this.y.toDouble();
  }
  
  // TODO: Use named optionals for x/y/index 
  // instead of hoping polymorphism will work in dart
  void moveTo(int x, int y, var cb) {
    tX = x; 
    tY = y;
    moveTimer = moveTime;
    swapDoneCallback = cb;
  }
  
  void moveToIndex(int index, var cb) {
    tX = index % SuperPop.BOARD_WIDTH;
    tY = index ~/ SuperPop.BOARD_HEIGHT;
    moveTimer = moveTime;
    swapDoneCallback = cb;
  }
  
  void moveToIndexAndBack(int index, var cb) {
    tX = index % SuperPop.BOARD_WIDTH;
    tY = index ~/ SuperPop.BOARD_HEIGHT;
    moveTimer = moveTime;
    swapDoneCallback = cb;
    returnOnSwap = true;
  }
}
