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
  bool drawing = false;
  int mouseX = 0;
  int mouseY = 0;
  
  GameOfLife(this.canvas);
  
  List<bool> life = new List<bool>.filled(2500, false);
  
  void start()
  {
    context = canvas.context2D;
    
    // Lines
    context.fillStyle = 'black';
    for (int x = 1; x < canvas.width; x++)
    {
      context.fillRect(x * gridSize, 0, 1, canvas.height);
      for (int y = 1; y < canvas.height; y++)
      {
        context.fillRect(0, y * gridSize, canvas.width, 1);
      }
    }
    
    // Listener
    canvas.onMouseDown.listen(mouseDown);
    
    // Loop
    window.animationFrame.then(update);
  }
  
  void update(double dt)
  {
    for (int index = 0; index < life.length; index++)
    {
      int x = index % 50;
      int y = index ~/ 50;

      String color = life[index] ? 'red' : 'green';
      context.fillStyle = color;

      if (life[index])print('drawing $index');
      context.fillRect(x * gridSize + 1, y * gridSize + 1, gridSize, gridSize);        
    }
    context.fillRect(11, 11, gridSize, gridSize);
  }
  
  Set<int> handledIndices = new Set<int>();
  StreamSubscription mouseMoveStream;
  StreamSubscription mouseUpStream;
  
  void mouseDown(MouseEvent e)
  {
    handledIndices.clear();
    drawing = true;
    mouseX = e.client.x;
    mouseY = e.client.y;
    // Handle tile under mouse, bind move for other pieces
    Rectangle rect = canvas.getBoundingClientRect();

    int x = (e.client.x - rect.left).toInt();
    int y = (e.client.y - rect.top).toInt();
    int index = getTileUnderMouse(x, y);
    
    if (!handledIndices.contains(index))
    {
      x = index % 50;
      y = index ~/ 50;

      context.fillRect(gridSize * x, gridSize * y, gridSize, gridSize);
      handledIndices.add(index);
    }
    
    mouseMoveStream = canvas.onMouseMove.listen(mouseMove);
    mouseUpStream = canvas.onMouseUp.listen(mouseUp);
  }
  
  int getTileUnderMouse(int x, int y)
  {
    final int gameX = x ~/ gridSize;
    final int gameY = y ~/ gridSize;
    return gameY * gridWidth + gameX;
  }
  
  void mouseUp(MouseEvent e)
  {
    drawing = false;
    handledIndices.clear();
    mouseMoveStream.cancel();
    mouseUpStream.cancel();
  }
  
  void mouseMove(MouseEvent e)
  {
    Rectangle rect = canvas.getBoundingClientRect();
    int x = (e.client.x - rect.left).toInt();
    int y = (e.client.y - rect.top).toInt();
    int index = getTileUnderMouse(x, y);
    if (!handledIndices.contains(index))
    {
      life[index] = true;
      handledIndices.add(index);
      print('$index is true');
    }    
  }
}