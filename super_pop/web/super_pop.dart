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
  
  int mouseX = 0;
  int mouseY = 0;
  int downIndex = -1;
  
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
    // TODO: Also only check up and down
    for (int row = -1; row < 2; row++) {
      for (int col = -1; col < 2; col++) {
        if (row == 0 && col == 0) continue;
        
        final int nextX = endX + col;
        final int nextY = endY + row;
        
        if (nextX == startX && nextY == startY) return true;
      }
    }
    return false;
  }
  
  void draw(double dt) {
    // Grid
    for (int i = 0; i < gems.length; i++) {
      final int x = gems[i].x;
      final int y = gems[i].y;
      
      switch (gems[i].type) {
        case 0:
          context.fillStyle = 'red';
          break;
        case 1:
          context.fillStyle = 'green';
          break;
        case 2:
          context.fillStyle = 'blue';
          break;
        case 3:
          context.fillStyle = 'black';
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
      }
      context.fillRect(x * TILE_WIDTH, y * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT);
    }
    
    // Marker
    drawMarker(mouseX, mouseY);
  }
  
  void drawMarker(int x, int y)
  {
    x *= TILE_WIDTH;
    y *= TILE_HEIGHT;
    context.fillStyle = 'rgba(255,0,0,0.5)';
    context.fillRect(x, y, TILE_WIDTH, MARKER_LINE_WIDTH);
    context.fillRect(x, y, MARKER_LINE_WIDTH, TILE_HEIGHT);
    context.fillRect(x + TILE_WIDTH - MARKER_LINE_WIDTH, y, MARKER_LINE_WIDTH, TILE_HEIGHT);
    context.fillRect(x, y + TILE_HEIGHT - MARKER_LINE_WIDTH, TILE_WIDTH, MARKER_LINE_WIDTH);
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
