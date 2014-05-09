part of super_pop;

class SuperPop {
  CanvasElement canvas;
  CanvasRenderingContext context;
  SuperPop(this.canvas);
  
  static const int BOARD_WIDTH = 8;
  static const int BOARD_HEIGHT = 8;
  static const int NUM_PIECES = 8;//?
  static const int PIECE_WIDTH = 32;
  static const int PIECE_HEIGHT = 32;
  
  List<int> board = [0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0];
  
  void start() {
    var rand = new Random();
    for (int i = 0; i < board.length; i++) {
      board[i] = rand.nextInt(7);
    }
    context = canvas.context2D;
  }
  
  void update(double dt) {
    // TODO: Accumulate, etc.
    draw(dt);
  }
  
  void draw(double dt) {
    for (int index = 0; index < board.length; index++) {
      int x = index % BOARD_WIDTH;
      int y = index ~/ BOARD_HEIGHT;
      
      switch (board[index]) {
        case 0:
          context.fillStyle = 'black';
          break;
        case 1:
          context.fillStyle = 'red';
          break;
        case 2:
          context.fillStyle = 'blue';
          break;
        case 3:
          context.fillStyle = 'green';
          break;
        case 4:
          context.fillStyle = 'yellow';
          break;
        case 5:
          context.fillStyle = 'grey';
          break;
        case 6:
          context.fillStyle = 'orange';
          break;
        case 7:
          context.fillStyle = 'rgb(100, 149, 237)';
          break;
      }
      
      context.fillRect(x * PIECE_WIDTH, y * PIECE_HEIGHT, PIECE_WIDTH, PIECE_HEIGHT);
    }
  }
}
