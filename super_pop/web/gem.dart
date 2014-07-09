part of super_pop;

class Gem {
  // TODO: Consider skipping position altogether, just using offset from grid position
  Vector2 position;
  //Vector2 fromPosition = Board.INVALID_POSITION;
  //Vector2 targetPosition = Board.INVALID_POSITION;
  //Vector2 renderPosition = Board.INVALID_POSITION;
  double moveTimer = 0.0;
  double moveTime = 0.5;
  
  // TODO: "Enum", see GameState
  int type = -1;
  int fallDistance = 0;
  double scale = 1.0;
  bool returnOnSwap = false;
  var swapDoneCallback;
  Sprite sprite;
  Gem(this.position, this.type) {
    //renderPosition = this.position;
    sprite = new Sprite(SuperPop.spriteSheet, 64, 64);
  }
  
//  void moveTo({ Vector2 position : null, int x : -1, int y : -1, int index : -1, bool returnOnSwap : false, var callback : null}) {
//    if (callback != null) swapDoneCallback = callback;
//    //fromPosition = this.position;
//    if (position != null) {
//      //targetPosition = position;
//    } else if (index != -1) {
//      // TODO: Check style guide
//      //targetPosition = new Vector2(
//          (index % SuperPop.BOARD_WIDTH).toDouble(), 
//          (index ~/ SuperPop.BOARD_HEIGHT).toDouble());
//    } else if (x != -1 && y != -1) {
//      //targetPosition = new Vector2(x.toDouble(), y.toDouble());
//    } else {
//      return;
//    }
//    this.returnOnSwap = returnOnSwap;
//    moveTimer = moveTime;
//  }
}
