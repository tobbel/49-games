part of super_pop;

class SuperPop {
  CanvasElement canvas;
  CanvasRenderingContext context;
  SuperPop(this.canvas);
  
  static const int GAME_WIDTH = 8;
  static const int GAME_HEIGHT = 8;
  static const int NUM_PIECES = 8;//?
  
  List<int> board = [0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0];
  
  void start() {
    // TODO: Initialize board.
    // For entire board, randomize 0 to num pieces.
    context = canvas.context2D;
  }
  
  void update(double dt) {
    // TODO: Accumulate.
  }
}
