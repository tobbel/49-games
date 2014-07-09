part of super_pop;

class Sprite {
  ImageElement img;
  int width;
  int height;
  int spritesPerImgWidth;
  int spritesPerImgHeight;
  double alpha = 1.0;

  static CanvasRenderingContext2D context;
  
  Sprite(this.img, this.width, this.height) {
    spritesPerImgWidth = img.width ~/ width;
    spritesPerImgHeight = img.height ~/ height;
  }
  
  void setAlpha(double in_alpha) {
    alpha = in_alpha;
  }
  
  void draw(Vector2 position, {int index: 0}) {
    context.globalAlpha = alpha;
    context.drawImageScaledFromSource(
        img, 
        (index % spritesPerImgWidth) * width,
        (index ~/ spritesPerImgHeight) * height,
        width,
        height,
        position.x,
        position.y, 
        width, 
        height);
  }
}
