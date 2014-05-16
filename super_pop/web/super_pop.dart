part of super_pop;

class SuperPop {
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  SuperPop(this.canvas);
  
  static const int BOARD_WIDTH = 8;
  static const int BOARD_HEIGHT = 8;
  static const int NUM_PIECES = 7;
  static const int TILE_WIDTH = 64;
  static const int TILE_HEIGHT = 64;
  static const int MARKER_LINE_WIDTH = 16;
  static const int SPRITESHEET_WIDTH = 256;
  static const int SPRITESHEET_HEIGHT = 256;
  static const int SPRITES_COUNT = SPRITESHEET_WIDTH ~/ TILE_WIDTH;
  
  int mouseX = 0;
  int mouseY = 0;
  int downIndex = -1;
  
  ImageElement spriteSheet = new ImageElement(src: 'img/spritesheet.png', 
                                              width: SPRITESHEET_WIDTH, 
                                              height: SPRITESHEET_HEIGHT);
  
  List<Gem> gems = new List<Gem>();
  void start() {
    var rand = new Random();
    for (int index = 0; index < BOARD_WIDTH * BOARD_HEIGHT; index++) {
      final int x = index % BOARD_WIDTH;
      final int y = index ~/ BOARD_HEIGHT;
      gems.add(new Gem(x, y, rand.nextInt(7)));
    }
    context = canvas.context2D;
  }
  
  void update(double dt) {
    // TODO: Accumulate, etc.
    draw(dt);
  }
  
  bool isNeighbor(int indexA, int indexB) {
    final int startX = indexA % BOARD_WIDTH;
    final int startY = indexA ~/ BOARD_HEIGHT;
    final int endX = indexB % BOARD_WIDTH;
    final int endY = indexB ~/ BOARD_HEIGHT; 
    
    // TODO: Better way of doing this by comparing indices 
    //       and not hacky
    for (int row = -1; row < 2; row++) {
      for (int col = -1; col < 2; col++) {
        if (row == 0 && col == 0) continue;
        if (row == -1 && col == -1) continue;
        if (row == -1 && col == 1) continue;
        if (row == 1 && col == -1) continue;
        if (row == 1 && col == 1) continue;
        
        final int nextX = endX + col;
        final int nextY = endY + row;
        
        if (nextX == startX && nextY == startY) return true;
      }
    }
    return false;
  }
  
  void draw(double dt) {
    // Clear
    context.clearRect(0, 0, canvas.width, canvas.height);
    
    // Grid
    for (int i = 0; i < gems.length; i++) {
      final int x = gems[i].x;
      final int y = gems[i].y;
      final int sx = (gems[i].type % SPRITES_COUNT) * TILE_WIDTH;
      final int sy = (gems[i].type ~/ SPRITES_COUNT) * TILE_HEIGHT;
      final int dx = x * TILE_WIDTH;
      final int dy = y * TILE_WIDTH;
      context.drawImageScaledFromSource(spriteSheet, 
          sx, sy, TILE_WIDTH, TILE_HEIGHT, dx, dy, TILE_WIDTH, TILE_HEIGHT);
    }
    
    // Marker
    if (downIndex != -1) {
      final int x = downIndex % BOARD_WIDTH;
      final int y = downIndex ~/ BOARD_HEIGHT;
      drawMarker(x, y);
    }
    else {
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
    position = canvasToGridPosition(position);
    setMousePosition(position);
    final int index = mouseY * BOARD_WIDTH + mouseX;
    
    // Second click, check for neighbor
    if (downIndex != -1) {
      if (isNeighbor(index, downIndex)) {
        final int type = gems[index].type;
        gems[index].type = gems[downIndex].type;
        gems[downIndex].type = type;
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
      final int type = gems[index].type;
      gems[index].type = gems[downIndex].type;
      gems[downIndex].type = type;
      // TODO: Animation -> clearing
    }
    downIndex = -1;
  }
  
  Vector2 canvasToGridPosition(Vector2 canvasPosition) {
    return new Vector2(min(canvasPosition.x ~/ TILE_WIDTH, BOARD_WIDTH - 1).toDouble(), min(canvasPosition.y ~/ TILE_HEIGHT, BOARD_HEIGHT - 1).toDouble());
  }
  
  void setMousePosition(Vector2 gridPosition) {
    mouseX = gridPosition.x.toInt();
    mouseY = gridPosition.y.toInt();
  }
}
