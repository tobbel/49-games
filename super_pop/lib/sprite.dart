part of super_pop;

class Sprite {
  ImageElement img;
  int width;
  int height;
  int spritesPerImgWidth;
  int spritesPerImgHeight;

  static CanvasRenderingContext2D context;
  
  Sprite(this.img, this.width, this.height) {
    spritesPerImgWidth = img.width ~/ width;
    spritesPerImgHeight = img.height ~/ height;
  }
  
  void draw(Vector2 position, {int index: 0}) {
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
