part of super_pop;

class Gem {
  Vector2 position;
  Vector2 fromPosition = Board.INVALID_POSITION;
  Vector2 targetPosition = Board.INVALID_POSITION;
  Vector2 renderPosition = Board.INVALID_POSITION;
  //int x, y;
  //int tX = -1;
  //int tY = -1;
  double moveTimer = 0.0;
  double moveTime = 0.15;
  //double renderX = 0.0;
  //double renderY = 0.0;
  int type = -1;
  bool returnOnSwap = false;
  var swapDoneCallback;
  Gem(this.position, this.type) {
    renderPosition = this.position;
    //renderX = this.position.x;
    //renderY = this.position.y;
  }
  
  void moveTo(var cb, { Vector2 position, int x : -1, int y : -1, int index : -1, bool returnOnSwap : false}) {
    swapDoneCallback = cb;
    fromPosition = this.position;
    if (position != null) {
      targetPosition = position;      
    } else if (index != -1) {
      // TODO: Check style guide
      targetPosition = new Vector2(
          (index % SuperPop.BOARD_WIDTH).toDouble(), 
          (index ~/ SuperPop.BOARD_HEIGHT).toDouble());
    } else if (x != -1 && y != -1) {
      targetPosition = new Vector2(x.toDouble(), y.toDouble());
    } else {
      return;
    }
    this.returnOnSwap = returnOnSwap;
    moveTimer = moveTime;
  }
  
//  void moveTo(int x, int y, var cb) {
//    tX = x; 
//    tY = y;
//    moveTimer = moveTime;
//    swapDoneCallback = cb;
//  }
//  
//  void moveToIndex(int index, var cb) {
//    tX = index % SuperPop.BOARD_WIDTH;
//    tY = index ~/ SuperPop.BOARD_HEIGHT;
//    moveTimer = moveTime;
//    swapDoneCallback = cb;
//  }
//  
//  void moveToIndexAndBack(int index, var cb) {
//    tX = index % SuperPop.BOARD_WIDTH;
//    tY = index ~/ SuperPop.BOARD_HEIGHT;
//    moveTimer = moveTime;
//    swapDoneCallback = cb;
//    returnOnSwap = true;
//  }
}
