part of super_pop;

class SuperPop {
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  SuperPop(this.canvas);
  
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
  
  int mouseX = 0;
  int mouseY = 0;
  int downIndex = -1;
  bool swapping = false;
  // TODO: Invalid gem type
  
  var rand = new Random();
  
  ImageElement spriteSheet = new ImageElement(src: 'img/spritesheet.png', 
                                              width: SPRITESHEET_WIDTH, 
                                              height: SPRITESHEET_HEIGHT);
  
  List<Gem> gems = new List<Gem>();
  List<Gem> swappedGems = new List<Gem>();
  
  void start() {
    for (int index = 0; index < BOARD_SIZE; index++) {
      final int x = index % BOARD_WIDTH;
      final int y = index ~/ BOARD_HEIGHT;
      gems.add(new Gem(x, y, rand.nextInt(7)));
    }
    context = canvas.context2D;
  }
  
  void update(double dt) {
    // TODO: Accumulate.
    // TODO: Animate.
    // TODO: Fill cleared from above
    //removeRows(dt);
    //drop(dt);
    updateSwap(dt);
    draw(dt);
    for (int i = 0; i < gems.length; i++) {
      if (gems[i] != null)
        gems[i].update(dt);
    }
  }
  
  void updateSwap(double dt) {
    // TODO: Move timers for gems to here? (updateGems)
    // TODO: More stable solution (this only works for 2, is quite ugly)
    if (swappedGems.length == 2) {
      // TODO: Check if swapped gems are matchable, confirm if so or swap back
      int i0 = gems.indexOf(swappedGems[0]);
      int i1 = gems.indexOf(swappedGems[1]);
      Gem g0 = gems[i0];
      gems[i0] = gems[i1];
      gems[i1] = g0;
      swappedGems.clear();
      swapping = false;
    }
  }
  
  void swapDone(Gem cbGem) {
    swappedGems.add(cbGem);
  }
  
  void drop(double dt) {
    // Go through entire board
    // For each that is invalid, do this:
    //  Swap with the one above you until you are at the top, or
    //  The one above you is invalid as well
    for (int index = 0; index < BOARD_SIZE; index++) {
      int x = index % BOARD_WIDTH;
      int y = index ~/ BOARD_HEIGHT;
      
      if (isValid(x, y) && getGemAt(x, y).type == -1) {
        int nX = x;
        int nY = y - 1;
        while (isValid(nX, nY) && getGemAt(nX, nY).type != -1) {
          int nIndex = nY * BOARD_WIDTH + nX;
          gems[index].type = getGemAt(nX, nY).type;
          gems[nIndex].type = -1;
          // TODO: Instead of flipping, tell all above not -1 to move down.
          // TODO: TargetType as well, set when animation is done?
          //gems[index].moveTo(nX, nY);
          //gems[nIndex].moveTo(x, y);
          nY--;
          index -= BOARD_WIDTH;
          break;
        }
      }
    }
    
    for (int index = 0; index < BOARD_SIZE; index++) {
      final int x = index % BOARD_WIDTH;
      final int y = index ~/ BOARD_HEIGHT;
      if (isValid(x, y) && getGemAt(x, y).type == -1) {
        gems[index] = new Gem(x, y, rand.nextInt(7));
      }
    }
  }
  
  void removeRows(double dt) {
    List<int> toRemove = new List<int>();
    for (int index = 0; index < BOARD_SIZE; index++) {
      final int x = index % BOARD_WIDTH;
      final int y = index ~/ BOARD_HEIGHT;
      Gem currentGem = gems[index];
      // Check right and down. Okay since we start at top left.
      // Right
      int offset = 1;
      int nX = x + offset;
      int nY = y;
      List<int> matches = new List<int>();
      matches.add(index);
      while(isValid(nX, nY) && getGemAt(nX, nY).type == currentGem.type) {
        matches.add(nY * BOARD_WIDTH + nX);
        nX++;
      }
      if (matches.length > 2) {
        toRemove.addAll(matches);
      }
      matches.clear();
      
      // Down
      offset = 1;
      nX = x;
      nY = y + offset;
      matches.add(index);
      while (isValid(nX, nY) && getGemAt(nX, nY).type == currentGem.type) {
        matches.add(nY * BOARD_WIDTH + nX);
        nY++;
      }
      if (matches.length > 2) {
        toRemove.addAll(matches);
      }
      matches.clear();
    }
    
    for (int i = 0; i < toRemove.length; i++) {
      // TODO: -1 renders to 3, make Gem.type class w/ relevant info (or just add to gem)?
      gems[toRemove[i]] = new Gem(toRemove[i] % BOARD_WIDTH, toRemove[i] ~/ BOARD_HEIGHT, -1);
    }
  }
  
  Gem getGemAt(int x, int y) {
    final int index = y * BOARD_WIDTH + x;
    if (isValidIndex(index)) {
      return gems[index];
    }
    return null;
  }
  
  bool isValid(int x, int y) => x < BOARD_WIDTH && y < BOARD_WIDTH && x >= 0 && y >= 0;
  bool isValidIndex(int index) => index < BOARD_SIZE && index >= 0;
  
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
      final double x = gems[i].renderX;
      final double y = gems[i].renderY;
      final int sx = (gems[i].type % SPRITES_COUNT) * TILE_WIDTH;
      final int sy = (gems[i].type ~/ SPRITES_COUNT) * TILE_HEIGHT;
      final double dx = x * TILE_WIDTH;
      final double dy = y * TILE_WIDTH;
      context.drawImageScaledFromSource(spriteSheet, 
          sx, sy, TILE_WIDTH, TILE_HEIGHT, dx, dy, TILE_WIDTH, TILE_HEIGHT);
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
    position = canvasToGridPosition(position);
    setMousePosition(position);
    final int index = mouseY * BOARD_WIDTH + mouseX;
    
    // Second click, check for neighbor
    if (downIndex != -1) {
      if (isNeighbor(index, downIndex)) {
        // TODO: Factor out to swap function
        gems[index].moveToIndex(downIndex, swapDone);
        gems[downIndex].moveToIndex(index, swapDone);
        swapping = true;
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
      // TODO: Factor out to swap function
      gems[index].moveToIndex(downIndex, swapDone);
      gems[downIndex].moveToIndex(index, swapDone);
      swapping = true;
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
