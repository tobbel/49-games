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
  final double animationTime = 0.5;
  
  int swapFrom = -1;
  int swapTo = -1;
  
  var rand = new Random();
  Board board;
  static ImageElement spriteSheet = new ImageElement(src: 'img/spritesheet.png', 
                                              width: SPRITESHEET_WIDTH, 
                                              height: SPRITESHEET_HEIGHT);
  
  void start() {
    context = canvas.context2D;
    board = new Board(BOARD_WIDTH, BOARD_HEIGHT);//, swapDone);
    Sprite.context = context;
  }
  
//  void swapDone() {
//    swapping = false;
//  }
  
  void update(double dt) {
    if (animationTimer > 0.0) {
      animationTimer -= dt;
    }
    
    swapping = swapFrom != -1 && swapTo != -1;
    
    switch (currentState) {
      case GameState.IDLE: 
        break;    
      case GameState.SWAP:
        // Swapping, just update animation
        
        // Swap is done
        if (animationTimer <= 0) {
          animationTimer = 0.0;
          currentState = GameState.CLEAR;
          // Actually swap gems:
          board.swap(swapFrom, swapTo);
          // Reset anim timer
          animationTimer = animationTime;
          swapFrom = -1;
          swapTo = -1;
          
          // Mark matched squares for deletion
          board.removeRows();
        }
        break;
      case GameState.CLEAR:
        // Fade out of swapped gems is done
        print('clear');
        if (animationTimer <= 0) {
          currentState = GameState.FALL;
          
          // Calculate who should fall how
          board.calculateFallDistance();
          
          // Apply fall
          
          // Mark top spaces as empty
          // Reset anim timer
          animationTimer = animationTime;
        }
        break;
      case GameState.FALL:
        

        // Fall animation is done
        if (animationTimer <= 0) {
          print('fall done');
          // If any on board are still falling,
          // Check board if any new matches have been made
          // If so, switch to CLEAR
          currentState = GameState.IDLE;
          // Reset fall distance for all
          // actually swap all tiles
          // Randomize new on top
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
    final double timerFraction = animationTimer / animationTime;
    // Grid
    for (int i = 0; i < BOARD_SIZE; i++) {
      final Gem gem = board.getGemAt(index: i);
      //final double x = gem.renderPosition.x;
      //final double y = gem.renderPosition.y;
      double x = gem.position.x;
      double y = gem.position.y;
      if (currentState == GameState.SWAP) {
        // Check if this gem is swapping, render offset if it is
        if (i == swapFrom || i == swapTo) {
          // Offset by timer
          Gem other;
          if (i == swapFrom) {
            other = board.getGemAt(index: swapTo);
          } else {
            other = board.getGemAt(index: swapFrom);
          }
          if (other != null) {          
            x = (gem.position.x * timerFraction) + (other.position.x * (1 - timerFraction));
            y = (gem.position.y * timerFraction) + (other.position.y * (1 - timerFraction));
          }
        }
      } else if (currentState == GameState.CLEAR && gem.type == INVALID_TILE) {
        // Alpha out for invalid tiles
        gem.sprite.setAlpha(timerFraction);
      } else if (currentState == GameState.FALL && gem.fallDistance > 0) {
        // Fall all the way
        y = (gem.position.y * timerFraction) + ((gem.position.y + gem.fallDistance) * (1 - timerFraction));
      }
      
      gem.sprite.draw(new Vector2(x * TILE_WIDTH, y * TILE_HEIGHT), index: gem.type);
//      final int sx = (gem.type % SPRITES_COUNT) * TILE_WIDTH;
//      final int sy = (gem.type ~/ SPRITES_COUNT) * TILE_HEIGHT;
//      final double dx = x * TILE_WIDTH;
//      final double dy = y * TILE_WIDTH;
//      final double scalePositionOffset = (gem.scale - 1.0) / 2.0;
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
    //if (swapping) return;
    
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
    if (board.trySwap(indexFrom, indexTo)) {
      swapFrom = indexFrom;
      swapTo = indexTo;
      currentState = GameState.SWAP;
      animationTimer = animationTime;
    }
    //swapping = true;
  }
  
  Vector2 canvasToGridPosition(Vector2 canvasPosition) {
    return new Vector2(min(canvasPosition.x ~/ TILE_WIDTH, BOARD_WIDTH - 1).toDouble(), min(canvasPosition.y ~/ TILE_HEIGHT, BOARD_HEIGHT - 1).toDouble());
  }
  
  void setMousePosition(Vector2 gridPosition) {
    mouseX = gridPosition.x.toInt();
    mouseY = gridPosition.y.toInt();
  }
}
