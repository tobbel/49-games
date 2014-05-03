import 'dart:html';
import 'dart:async';

void main()
{
  CanvasElement canvas = querySelector('#game');

  // Create game async as microtask 
  scheduleMicrotask(new GameOfLife(canvas).start);
}

class GameOfLife
{
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  
  final int gridSize = 10;
  final int gridWidth = 50;
  final int gridHeight = 50;
  bool drawType = true;
  
  StreamSubscription mouseMoveStream;
  StreamSubscription mouseUpStream;
  
  GameOfLife(this.canvas);
  
  List<bool> life = new List<bool>.filled(2500, false); 
  
  void start()
  {
    context = canvas.context2D;
    
    // Lines
    context.fillStyle = 'black';
    for (int x = 1; x < canvas.width; x++)
    {
      context.fillRect(x * gridSize - 1, 0, 1, canvas.height);
      for (int y = 1; y < canvas.height; y++)
      {
        context.fillRect(0, y * gridSize - 1, canvas.width, 1);
      }
    }
    
    // Listener
    canvas.onMouseDown.listen(mouseDown);
    
    // Loop
    window.animationFrame.then(update);
  }
  num lastFrameTime = 0;
  void update(double frameTime)
  {
    num dt = frameTime - lastFrameTime;
//    print('$dt');
//    lastFrameTime = frameTime;
//    for (int index = 0; index < life.length; index++)
//    {
//      int x = index % 50;
//      int y = index ~/ 50;
//
//      String color = life[index] ? 'green' : 'red';
//      context.fillStyle = color;
//
//      context.fillRect(x * gridSize + 1, y * gridSize + 1, gridSize, gridSize);
//    }
    
    // TODO: Accumulate time and update simulation

    window.animationFrame.then(update);
  }
  
  void mouseDown(MouseEvent e)
  {
    // Handle tile under mouse, bind move for other pieces
    Rectangle rect = canvas.getBoundingClientRect();
    int x = (e.client.x - rect.left).toInt();
    int y = (e.client.y - rect.top).toInt();
    int index = getTileUnderMouse(x, y);
    
    if (index >= life.length)
      return;
    
    drawType = !life[index];
    life[index] = drawType;
    drawTile(index);
    
    mouseMoveStream = canvas.onMouseMove.listen(mouseMove);
    mouseUpStream = canvas.onMouseUp.listen(mouseUp);
  }
  
  void mouseUp(MouseEvent e)
  {
    mouseMoveStream.cancel();
    mouseUpStream.cancel();
  }
  
  void mouseMove(MouseEvent e)
  {
    Rectangle rect = canvas.getBoundingClientRect();
    int x = (e.client.x - rect.left).toInt();
    int y = (e.client.y - rect.top).toInt();
    
    int index = getTileUnderMouse(x, y);
    if (index >= life.length)
      return;

    life[index] = drawType;
    drawTile(index);
  }
  
  int getTileUnderMouse(int x, int y)
  {
    final int gameX = x ~/ gridSize;
    final int gameY = y ~/ gridSize;
    return gameY * gridWidth + gameX;
  }
  
  void drawTile(int index)
  {
    final int x = index % gridWidth;
    final int y = index ~/ gridHeight;
    final String color = drawType ? 'black' : 'white';
    
    context.fillStyle = color;
    context.fillRect(gridSize * x, gridSize * y, gridSize - 1, gridSize - 1);
  }
}