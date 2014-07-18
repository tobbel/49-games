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
  
  // TODO: Separate timers
  double animationTimer = 0.0;
  double swapTimer = 0.0;
  static const double SWAP_TIME = 0.5;
  // swaptimer
  // cleartimer
  // falltimer
  // etc.
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
    // TODO: Handle matches in starting board
    board = new Board(BOARD_WIDTH, BOARD_HEIGHT);
    Sprite.context = context;
    
    if (board.removeRows()) currentState = GameState.CLEAR;
  }
  
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
        if (swapTimer > 0.0) {
          swapTimer -= dt;
          if (swapTimer <= 0.0) {
            swapTimer = 0.0;
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
        }
        // Swap is done
//        if (animationTimer <= 0) {
//          animationTimer = 0.0;
//          currentState = GameState.CLEAR;
//          // Actually swap gems:
//          board.swap(swapFrom, swapTo);
//          // Reset anim timer
//          animationTimer = animationTime;
//          swapFrom = -1;
//          swapTo = -1;
//          
//          // Mark matched squares for deletion
//          board.removeRows();
//        }
        break;
      case GameState.CLEAR:
        // Fade out of swapped gems is done
        if (animationTimer <= 0) {
          currentState = GameState.FALL;
          // Delete all matched squares (list filled from (temp, after moved) board when trying to swap)
          board.removeRows();
          // Calculate who should fall how
          board.calculateFallDistance();
          
          //TODO: Generate new tiles here
          // Reset anim timer
          animationTimer = animationTime;
        }
        break;
      case GameState.FALL:
        // Fall animation is done
        if (animationTimer <= 0) {
          // Swap fallen tiles with tiles above them
          board.swapFallenTiles();

          // Randomize new on top
          // TODO: Do this before fall
          // TODO: Sometimes fallen tiles differ from those that fall,
          // does this function overwrite them?
          board.generateNewGems();
          
          // Check board if any new matches have been made
          if (board.removeRows()) {
            animationTimer = animationTime;
            currentState = GameState.CLEAR;
            // TODO: Temp, clear fall distance in board
            board.gems.forEach((g) => g.fallDistance = 0);
          } else {
            board.gems.forEach((g) => g.fallDistance = 0);
            currentState = GameState.IDLE;
          }
          // If so, switch to CLEAR
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
            final double swapTimerFraction = swapTimer / SWAP_TIME;
            x = (gem.position.x * swapTimerFraction) + (other.position.x * (1 - swapTimerFraction));
            y = (gem.position.y * swapTimerFraction) + (other.position.y * (1 - swapTimerFraction));
          }
        }
      } else if (gem.type == INVALID_TILE) {
        if (currentState == GameState.CLEAR) {
          // Alpha out for invalid tiles
          gem.sprite.setAlpha(timerFraction);          
        } else if (currentState == GameState.FALL) {
          gem.sprite.setAlpha(0.0);
        }
      } else if (currentState == GameState.FALL && gem.fallDistance > 0) {
        // Fall all the way
        y = (gem.position.y * timerFraction) + ((gem.position.y + gem.fallDistance) * (1 - timerFraction));
      }
      
      gem.sprite.draw(new Vector2(x * TILE_WIDTH, y * TILE_HEIGHT), index: gem.type);
      context.fillText(gem.fallDistance.toString(), gem.position.x * TILE_WIDTH, (gem.position.y * TILE_HEIGHT) + 32);
      //for (int i = 0; i < gem.fallDistance; i++) {
      //  final int x = gem.position.x.toInt();
      //  final int y = gem.position.y.toInt();
      //  context.fillRect(x, y, 10, 10);
      //}
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
    position = 
        
        canvasToGridPosition(position);
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
      swapTimer = SWAP_TIME;
      
    }
  }
  
  Vector2 canvasToGridPosition(Vector2 canvasPosition) {
    return new Vector2(min(canvasPosition.x ~/ TILE_WIDTH, BOARD_WIDTH - 1).toDouble(), min(canvasPosition.y ~/ TILE_HEIGHT, BOARD_HEIGHT - 1).toDouble());
  }
  
  void setMousePosition(Vector2 gridPosition) {
    mouseX = gridPosition.x.toInt();
    mouseY = gridPosition.y.toInt();
  }
}
