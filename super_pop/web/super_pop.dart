part of super_pop;

class GameState {
  final _value;
  const GameState._internal(this._value);
  toString() => 'Enum.$_value';

  static const IDLE = const GameState._internal('IDLE');
  static const SWAP = const GameState._internal('SWAP');
  static const CLEAR = const GameState._internal('CLEAR');
  static const FALL = const GameState._internal('FALL');
}

class SuperPop {
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  SuperPop(this.canvas);
  GameState currentState = GameState.IDLE;
  
  static const int BOARD_WIDTH = 8;
  static const int BOARD_HEIGHT = 8;
  static const int BOARD_SIZE = BOARD_WIDTH * BOARD_HEIGHT;
  static const int NUM_PIECES = 7;
  static const int TILE_WIDTH = 64;
  static const int TILE_HEIGHT = 64;
  static const int MARKER_LINE_WIDTH = 16;
  static const int SPRITESHEET_WIDTH = 256;
  static const int SPRITESHEET_HEIGHT = 256;
  static const int SPRITES_COUNT = SPRITESHEET_WIDTH ~/ TILE_WIDTH;
  static const int INVALID_TILE = 9;
  
  int mouseX = 0;
  int mouseY = 0;
  int downIndex = -1;
  bool swapping = false;
  double animationTimer = 0.0;
  
  var rand = new Random();
  Board board;
  static ImageElement spriteSheet = new ImageElement(src: 'img/spritesheet.png', 
                                              width: SPRITESHEET_WIDTH, 
                                              height: SPRITESHEET_HEIGHT);
  
  void start() {
    context = canvas.context2D;
    board = new Board(BOARD_WIDTH, BOARD_HEIGHT, swapDone);
    Sprite.context = context;
  }
  
  void swapDone() {
    swapping = false;
  }
  
  void update(double dt) {
    if (animationTimer > 0.0) {
      animationTimer -= dt;
    }
    
    // TODO: Mirror this in render
    switch (currentState) {
      case GameState.IDLE: {
        break;
      }
      case GameState.SWAP: {
        // Swap is done
        if (animationTimer <= 0) {
          currentState = GameState.CLEAR;
        }
        break;
      }
      case GameState.CLEAR: {
        // Fade out of swapped gems is done
        if (animationTimer <= 0) {
          currentState = GameState.FALL;
        }
        break;
      }
      case GameState.FALL: {
        // Fall animation is done, go back to idle 
        if (animationTimer <= 0) {
          currentState = GameState.IDLE;
        }
        break;
      }
    }
    
    board.update(dt);
    draw(dt);
  }
  
  bool isNeighbor(int indexA, int indexB) {
    // TODO: Abs function
    int diff = indexA - indexB;
    if (diff < 0) diff *= -1;
    
    if (diff == 1 || diff == 8)
      return true;
    
    return false;
  }
  
  void draw(double dt) {
    // Clear
    context.clearRect(0, 0, canvas.width, canvas.height);
    
    // Grid
    for (int i = 0; i < BOARD_SIZE; i++) {
      final Gem gem = board.getGemAt(index : i);
      final double x = gem.renderPosition.x;
      final double y = gem.renderPosition.y;
      gem.sprite.draw(new Vector2(x * TILE_WIDTH, y * TILE_HEIGHT), index: gem.type);
      final int sx = (gem.type % SPRITES_COUNT) * TILE_WIDTH;
      final int sy = (gem.type ~/ SPRITES_COUNT) * TILE_HEIGHT;
      final double dx = x * TILE_WIDTH;
      final double dy = y * TILE_WIDTH;
      final double scalePositionOffset = (gem.scale - 1.0) / 2.0;
      // TODO: Check style guide
      //context.drawImageScaledFromSource(spriteSheet, 
      //    sx, sy, TILE_WIDTH, TILE_HEIGHT, 
      //    dx - TILE_WIDTH * scalePositionOffset, 
      //    dy - TILE_HEIGHT * scalePositionOffset, 
      //    TILE_WIDTH * gem.scale, 
      //    TILE_HEIGHT * gem.scale);
    }
    
    // Marker
    if (downIndex != -1) {
      final int x = downIndex % BOARD_WIDTH;
      final int y = downIndex ~/ BOARD_HEIGHT;
      drawMarker(x, y);
    } else {
      drawMarker(mouseX, mouseY);
    }    
  }
  
  void drawMarker(int x, int y)
  {
    if (swapping) return;
    
    final int sx = (8 % SPRITES_COUNT) * TILE_WIDTH;
    final int sy = (8 ~/ SPRITES_COUNT) * TILE_HEIGHT;
    final int dx = x * TILE_WIDTH;
    final int dy = y * TILE_WIDTH;
    context.drawImageScaledFromSource(spriteSheet, 
        sx, sy, TILE_WIDTH, TILE_HEIGHT, dx, dy, TILE_WIDTH, TILE_HEIGHT);
  }
  
  void mouseMove(Vector2 position) {
    position = canvasToGridPosition(position);
    setMousePosition(position);
  }
  
  void mouseDown(Vector2 position) {
    if (swapping) return;
    
    position = canvasToGridPosition(position);
    setMousePosition(position);
    final int index = mouseY * BOARD_WIDTH + mouseX;
    
    // Second click, check for neighbor
    if (downIndex != -1) {
      if (isNeighbor(index, downIndex)) {
        trySwap(index, downIndex);
      }
      downIndex = -1;
    } else {
      // Save index, on release see if release index is neighbor
      downIndex = index;
    }
  }
  
  void mouseUp(Vector2 position) {
    if (downIndex == -1) return;
    position = canvasToGridPosition(position);
    setMousePosition(position);
    final int index = mouseY * BOARD_WIDTH + mouseX;
    if (index == downIndex) { 
      // Just a click; save downIndex
      return;
    } else if (isNeighbor(index, downIndex)) {
      trySwap(index, downIndex);
    }
    downIndex = -1;
  }
  
  void trySwap(int indexFrom, int indexTo) {
    board.trySwap(indexFrom, indexTo);
    swapping = true;
  }
  
  Vector2 canvasToGridPosition(Vector2 canvasPosition) {
    return new Vector2(min(canvasPosition.x ~/ TILE_WIDTH, BOARD_WIDTH - 1).toDouble(), min(canvasPosition.y ~/ TILE_HEIGHT, BOARD_HEIGHT - 1).toDouble());
  }
  
  void setMousePosition(Vector2 gridPosition) {
    mouseX = gridPosition.x.toInt();
    mouseY = gridPosition.y.toInt();
  }
}
