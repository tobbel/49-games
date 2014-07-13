part of super_pop;

class Board {
  static final Vector2 INVALID_POSITION = new Vector2(-1.0, -1.0);
  List<Gem> gems = new List<Gem>();
  //List<Gem> swappedGems = new List<Gem>();
  int bouncedGemCount = 0;
  
  final int width;
  final int height;
  int size;
  
  var rand = new Random();
  
  //var swapDoneGameCallback;
  
  Board(this.width, this.height) {//, this.swapDoneGameCallback) {
    this.size = width * height;
    for (int index = 0; index < size; index++) {
      final int x = index % width;
      final int y = index ~/ height;
      gems.add(new Gem(new Vector2(x.toDouble(), y.toDouble()), rand.nextInt(7)));
    }
  }
  
  // TODO: Fix. Fall distance is iffy, some will fall when they should not.
  void calculateFallDistance() {
    //for (int x = 0; x < SuperPop.BOARD_WIDTH; x++) {
    int x = 0;
      for (int y = SuperPop.BOARD_HEIGHT - 1; y >= 0; y--) {
        // Check gem; if ths is invalid, above should fall.
        Gem gem = getGemAt(x: x, y: y);
        if (gem.type == SuperPop.INVALID_TILE) {          
          for (int aboveY = (y - 1); aboveY >= 0; aboveY--) {
            Gem above = getGemAt(x: x, y: aboveY);
            if (above != null) {
              above.fallDistance++;
            }
          }
        }
      //}
    }
    
    // Print all w/ fallDistance
    String out = '';
    for (int y = 0; y < SuperPop.BOARD_HEIGHT; y++) {
      out += '[';
      for (int x = 0; x < SuperPop.BOARD_WIDTH; x++) {
        Gem gem = getGemAt(x: x, y: y);
        out += '${gem.fallDistance}, ';
      }
      out += ']\n';
    }
    print(out);
  }
  
  void bounceDoneCallback(Gem gem) {
    bouncedGemCount++;
  }
  bool printed = false;
  void drop(double dt) {
    // TODO: Refactor
    // New
    // Desired effect:
    // i)   All invalid tiles pop, leaving a blank space.
    // ii)  When blank anim is done, all tiles above blank space move down at once.
    // iii) At the top of each dropped row, new tiles fall in above the others.
    // Two alternatives:
    // i)  Pre-calculate everything, fill board and just animate.
    // ii) Calculate one step at a time, fill board as things go.
    // Alt. i) Is probably best here, but we'll need to change animation a bit and
    // Ignore everything else while these animations go.
    // TODO: bool ignoreStuff = true;
    Map<int, List<int>> invalidPerCol = new Map<int, List<int>>();
    for (int index = size; index >= 0; index--) {
      int x = index % width;
      int y = index ~/ height;
      // For the first index of each column, initialize list for that column.
      if (y == (height - 1)) {
        invalidPerCol[x] = new List<int>();
      }
      
      // Count invalid indices per row, and starting (bottom).
      if (isValid(x : x, y : y) && getGemAt(x : x, y : y).type == SuperPop.INVALID_TILE) {
        invalidPerCol[x].add(y);
      }
    }
    
    // TODO: Look at k and v.length, move all above down n steps.
    if (!printed) {
      //printed = true;
      invalidPerCol.forEach((k, v) {
        //print('Row $k');
        //print(v);
        // Top item is last in list
        if (v.length != 0) {
          final int top = v[v.length - 1];
          if (top > 0) {
            final int steps = v.length;
            // Move all above top item v.length down
            for (int i = (top - 1); i >= 0; i--) {
              final int oldIndex = i * width + k;
              final int newIndex = (i + steps) * width + k;
              print('swapping old:$oldIndex with new:$newIndex');
              // Just swap for now
              Gem temp = gems[newIndex];
              gems[newIndex] = gems[oldIndex];
              gems[oldIndex] = temp;
              // TODO: Super temp
              gems[newIndex].position = new Vector2((oldIndex % width).toDouble(),(oldIndex ~/ height).toDouble());
              gems[oldIndex].position = new Vector2((newIndex % width).toDouble(),(newIndex ~/ height).toDouble());
            }
            
          } else {
            // Just generate as many as we need and put in v slots
          }
        }
      });
    }
    
    // Old
    // Go through entire board
    // For each that is invalid, do this:
    //  Swap with the one above you until you are at the top, or
    //  The one above you is invalid as well
//    for (int index = 0; index < size; index++) {
//      int x = index % width;
//      int y = index ~/ height;
//      
//      if (isValid(x : x, y : y) && getGemAt(x : x, y : y).type == -1) {
//        int nX = x;
//        int nY = y - 1;
//        while (isValid(x : nX, y : nY) && getGemAt(x : nX, y : nY).type != -1) {
//          int nIndex = nY * width + nX;
//          gems[index].type = getGemAt(x : nX, y : nY).type;
//          gems[nIndex].type = -1;
//          // TODO: Instead of flipping, tell all above not -1 to move down.
//          // TODO: TargetType as well, set when animation is done?
//          //gems[index].moveTo(nX, nY);
//          //gems[nIndex].moveTo(x, y);
//          nY--;
//          index -= width;
//          break;
//        }
//      }
//    }
//    
//    for (int index = 0; index < size; index++) {
//      final int x = index % width;
//      final int y = index ~/ height;
//      if (isValid(x : x, y : y) && getGemAt(x : x, y : y).type == -1) {
//        gems[index] = new Gem(new Vector2(x.toDouble(), y.toDouble()), rand.nextInt(7));
//      }
//    }
  }
  
  bool removeRows() {
    List<int> toRemove = new List<int>();
    for (int index = 0; index < size; index++) {
      final int x = index % width;
      final int y = index ~/ height;
      Gem currentGem = gems[index];
      // Check right and down. Okay since we start at top left.
      // Right
      int offset = 1;
      int nX = x + offset;
      int nY = y;
      List<int> matches = new List<int>();
      matches.add(index);
      while(isValid(x : nX, y : nY) && getGemAt(x : nX, y : nY).type == currentGem.type) {
        matches.add(nY * width + nX);
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
      while(isValid(x : nX, y : nY) && getGemAt(x : nX, y : nY).type == currentGem.type) {
        matches.add(nY * width + nX);
        nY++;
      }
      if (matches.length > 2) {
        toRemove.addAll(matches);
      }
      matches.clear();
    }
    
    bool removed = false;
    for (int i = 0; i < toRemove.length; i++) {
      removed = true;
      gems[toRemove[i]] = new Gem(new Vector2((toRemove[i] % width).toDouble(), (toRemove[i] ~/ height).toDouble()), SuperPop.INVALID_TILE);
    }
    return removed;
  }
  
  void swapFallenTiles() {
    // TODO: Tiles are swapped incorrectly, fix.
    for (int index = 0; index < size; index++) {
      Gem gem = gems[index];
      
      if (gem.fallDistance == 0) continue;
      
      // Swap with falldistance above
      final int indexTo = index + (gem.fallDistance * width);
      
      gem.fallDistance = 0;
      swap(index, indexTo);
    }
  }
  
  void refresh() {
    for (int index = 0; index < size; index++) {
      Gem gem = gems[index];
      
      if (gem.type == SuperPop.INVALID_TILE) {
        final int x = index % width;
        final int y = index ~/ height;
        gems[index] = new Gem(new Vector2(x.toDouble(), y.toDouble()), rand.nextInt(7));
      }
    }
  }
  
  bool trySwap(int indexFrom, int indexTo) {
    Gem temp = gems[indexTo];
    gems[indexTo] = gems[indexFrom];
    gems[indexFrom] = temp;
    
    // Does any of these two cause a match?
    final bool match = checkForMatch(indexFrom) || checkForMatch(indexTo);
    
    // Swap back in any case
    temp = gems[indexTo];
    gems[indexTo] = gems[indexFrom];
    gems[indexFrom] = temp;
    
    return match;    
  }
  
  void swap(int indexFrom, int indexTo) {
    Gem temp = gems[indexTo];
    gems[indexTo] = gems[indexFrom];
    gems[indexFrom] = temp;

    gems[indexTo].position = new Vector2((indexTo % SuperPop.BOARD_WIDTH).toDouble(), (indexTo ~/ SuperPop.BOARD_HEIGHT).toDouble());
    gems[indexFrom].position = new Vector2((indexFrom % SuperPop.BOARD_WIDTH).toDouble(), (indexFrom ~/ SuperPop.BOARD_HEIGHT).toDouble());
  }

  Gem getGemAt({int index : -1, int x : -1, int y : -1}) {
    if (index == -1 && x != -1 && y != -1) {
      index = y * width + x;
    }
    
    if (isValid(index : index))
    {
      return gems[index];
    }
    
    return null;
  }

  bool checkForMatch(int index) {
    // Check two steps up, down, left, right from this index.
    // If type of checked pieces if not same as that of index, abort.
    // If position is invalid, abort.
    // If one of the loops reaches max, return true!
    // In end, return false.
    final int startType = gems[index].type;
    
    // Up
    for (int up = 1; up < 3; up++) {
      final int upIndex = index - (up * width);
      if (!isValid(index : upIndex) || gems[upIndex].type != startType) break;
      if (up == 2) return true;
    }
    
    // Right
    for (int right = 1; right < 3; right++) {
      final int rightIndex = index + right;
      if (!isValid(index : rightIndex) || gems[rightIndex].type != startType) break;
      if (right == 2) return true;
    }
    
    // Down
    for (int down = 1; down < 3; down++) {
      final int downIndex = index + (down * width);
      if (!isValid(index : downIndex) || gems[downIndex].type != startType) break;
      if (down == 2) return true;
    }
    
    // Left
    for (int left = 1; left < 3; left++) {
      final int leftIndex = index - left;
      if (!isValid(index : leftIndex) || gems[leftIndex].type != startType) break;
      if (left == 2) return true;
    }
    
    // Middle row
    for (int mid = -1; mid < 2; mid++) {
      if (mid == 0) continue;
      final int row = index + mid;
      if (!isValid(index : row) || gems[row].type != startType) break;
      if (mid == 1) return true;
    }
    
    // Middle col
    for (int mid = -1; mid < 2; mid++) {
      if (mid == 0) continue;
      final int col = index + (mid * width);
      if (!isValid(index : col) || gems[col].type != startType) break;
      if (mid == 1) return true;
    }
    
    return false;
  }
  
  bool isValid({int index : -1, int x : -1, int y : -1}) {
    if (index != -1) {
      return index < size && index >= 0;
    } else if (x != -1 && y != -1) {
      return isValid(index : y * width + x);
    }
    
    // TODO: Warning/exception if all are -1 or none are set?
    return false;
  }
  
  void update(double dt) {
    //removeRows(dt);
    //drop(dt);

//    for (int i = 0; i < gems.length; i++) {
//      if (gems[i] == null) continue;
//      Gem gem = gems[i];
//      
//      if (gem.moveTimer > 0.0) {
//        gem.moveTimer -= dt;
//        
//        // TODO: Interpolate, linear looks boring
//        final double moveFraction = gem.moveTimer / gem.moveTime;
//        //gem.renderPosition = (gem.position * moveFraction) + (gem.targetPosition * (1 - moveFraction));
//        
//        // MoveFraction goes from 1 to 0
//        // we want scaleFraction to go from 0 to 1 to 0
//        double scaleFraction = 0.0;
//        if (moveFraction > 0.5) {
//          scaleFraction = 1 - ((moveFraction - 0.5) * 2.0);
//        } else {
//          scaleFraction = moveFraction * 2.0;
//        }
//        
//        gem.scale = 1.0 + scaleFraction;
//        
//        if (gem.moveTimer <= 0.0) {
//          if (gem.returnOnSwap) {
//            gem.position = gem.targetPosition;
//            gem.moveTo(position : gem.fromPosition);
//          } else {
//            // This is either second since return from swap, or first from regular.
//            gem.moveTimer = 0.0;
//            gem.position = gem.targetPosition;
//            gem.targetPosition = INVALID_POSITION;
//            gem.fromPosition = INVALID_POSITION;
//            if (gem.swapDoneCallback != null) gem.swapDoneCallback(gem);
//            gem.scale = 1.0;
//          }
//        }
//      }
//    }
    
    //updateSwap(dt);
  }
  
  void updateSwap(double dt) {
    // TODO: More stable solution (this only works for 2, is quite ugly)
//    if (swappedGems.length == 2) {
//      int i0 = gems.indexOf(swappedGems[0]);
//      int i1 = gems.indexOf(swappedGems[1]);
//      Gem g0 = gems[i0];
//      gems[i0] = gems[i1];
//      gems[i1] = g0;
//      swappedGems.clear();
//      swapDoneGameCallback();
//    }
//    if (bouncedGemCount == 2) {
//      bouncedGemCount = 0;
//      swapDoneGameCallback();
//    }
  }
}
