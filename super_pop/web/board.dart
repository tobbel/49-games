part of super_pop;

class Board {
  static final Vector2 INVALID_POSITION = new Vector2(-1.0, -1.0);
  List<Gem> gems = new List<Gem>();
  List<Gem> swappedGems = new List<Gem>();
  int bouncedGemCount = 0;
  
  final int width;
  final int height;
  final int size;
  
  var rand = new Random();
  
  var swapDoneGameCallback;
  
  Board(int in_width, int in_height, var swapDone)
      : width = in_width
      , height = in_height
      , size = in_width * in_height
      , swapDoneGameCallback = swapDone {
    for (int index = 0; index < size; index++) {
      final int x = index % width;
      final int y = index ~/ height;
      gems.add(new Gem(new Vector2(x.toDouble(), y.toDouble()), rand.nextInt(7)));
    }
  }
  
  // TODO: Solve this with one callback method, argument(s)?
  void swapDoneCallback(Gem gem) {
    swappedGems.add(gem);
  }
  
  void bounceDoneCallback(Gem gem) {
    bouncedGemCount++;
  }
  
  void drop(double dt) {
    // Go through entire board
    // For each that is invalid, do this:
    //  Swap with the one above you until you are at the top, or
    //  The one above you is invalid as well
    for (int index = 0; index < size; index++) {
      int x = index % width;
      int y = index ~/ height;
      
      if (isValid(x : x, y : y) && getGemAt(x : x, y : y).type == -1) {
        int nX = x;
        int nY = y - 1;
        while (isValid(x : nX, y : nY) && getGemAt(x : nX, y : nY).type != -1) {
          int nIndex = nY * width + nX;
          gems[index].type = getGemAt(x : nX, y : nY).type;
          gems[nIndex].type = -1;
          // TODO: Instead of flipping, tell all above not -1 to move down.
          // TODO: TargetType as well, set when animation is done?
          //gems[index].moveTo(nX, nY);
          //gems[nIndex].moveTo(x, y);
          nY--;
          index -= width;
          break;
        }
      }
    }
    
    for (int index = 0; index < size; index++) {
      final int x = index % width;
      final int y = index ~/ height;
      if (isValid(x : x, y : y) && getGemAt(x : x, y : y).type == -1) {
        gems[index] = new Gem(new Vector2(x.toDouble(), y.toDouble()), rand.nextInt(7));
      }
    }
  }
  
  void removeRows(double dt) {
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
    
    for (int i = 0; i < toRemove.length; i++) {
      // TODO: -1 renders to 3, make Gem.type class w/ relevant info (or just add to gem)?
      gems[toRemove[i]] = new Gem(new Vector2((toRemove[i] % width).toDouble(), (toRemove[i] ~/ height).toDouble()), -1);
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

    // If a swap will cause a match
    if (match) {
      // Start anim and when anim is done, swap positions for realsies
      gems[indexTo].moveTo(index : indexFrom, callback : swapDoneCallback);
      gems[indexFrom].moveTo(index : indexTo, callback : swapDoneCallback);
    } else {
      // If not
      // Stat bounce anim
      gems[indexTo].moveTo(index: indexFrom, returnOnSwap : true, callback : bounceDoneCallback);
      gems[indexFrom].moveTo(index: indexTo, returnOnSwap : true, callback : bounceDoneCallback);
    }
    
    return match;    
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
    removeRows(dt);
    drop(dt);

    for (int i = 0; i < gems.length; i++) {
      if (gems[i] == null) continue;
      Gem gem = gems[i];
      
      if (gem.moveTimer > 0.0) {
        gem.moveTimer -= dt;
        
        // TODO: Interpolate, linear looks boring
        final double moveFraction = gem.moveTimer / gem.moveTime;
        gem.renderPosition = (gem.position * moveFraction) + (gem.targetPosition * (1 - moveFraction));
        
        // MoveFraction goes from 1 to 0
        // we want scaleFraction to go from 0 to 1 to 0
        double scaleFraction = 0.0;
        if (moveFraction > 0.5) {
          scaleFraction = 1 - ((moveFraction - 0.5) * 2.0);
        } else {
          scaleFraction = moveFraction * 2.0;
        }
        
        gem.scale = 1.0 + scaleFraction;
        
        if (gem.moveTimer <= 0.0) {
          if (gem.returnOnSwap) {
            gem.position = gem.targetPosition;
            gem.moveTo(position : gem.fromPosition);
          } else {
            // This is either second since return from swap, or first from regular.
            gem.moveTimer = 0.0;
            gem.position = gem.targetPosition;
            gem.targetPosition = INVALID_POSITION;
            gem.fromPosition = INVALID_POSITION;
            if (gem.swapDoneCallback != null) gem.swapDoneCallback(gem);
            gem.scale = 1.0;
          }
        }
      }
    }
    
    updateSwap(dt);
  }
  
  void updateSwap(double dt) {
    // TODO: More stable solution (this only works for 2, is quite ugly)
    if (swappedGems.length == 2) {
      int i0 = gems.indexOf(swappedGems[0]);
      int i1 = gems.indexOf(swappedGems[1]);
      Gem g0 = gems[i0];
      gems[i0] = gems[i1];
      gems[i1] = g0;
      swappedGems.clear();
      swapDoneGameCallback();
    }
    if (bouncedGemCount == 2) {
      bouncedGemCount = 0;
      swapDoneGameCallback();
    }
  }
}
