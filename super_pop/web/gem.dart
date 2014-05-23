part of super_pop;

class Gem {
  int x, y; // TODO: Vector?
  int tX = -1;
  int tY = -1;
  double moveTimer = 0.0;
  double moveTime = 0.5;
  double renderX = 0.0;
  double renderY = 0.0;
  int type = -1;
  Gem(this.x, this.y, this.type) {
    renderX = this.x.toDouble();
    renderY = this.y.toDouble();
  }
  
  void moveTo(int x, int y) {
    tX = x; 
    tY = y;
    moveTimer = moveTime;
  }
  
  void update(double dt) {
    if (moveTimer > 0.0) {
      moveTimer -= dt;
      
      // 1 -> 0
      final double moveFraction = moveTimer / moveTime;
      renderX = moveFraction * x + (1 - moveFraction) * tX;
      renderY = moveFraction * y + (1 - moveFraction) * tY;
      
      if (moveTimer <= 0.0) {
        moveTimer = 0.0;
        tX = -1;
        tY = -1;
      }
    }
  }
}
