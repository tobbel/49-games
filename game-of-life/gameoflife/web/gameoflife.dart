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

  num lastFrameTime = 0;
  num gameTimer = 1;
  int generationCount = 0;
  
  bool running = false;
  
  InputElement startStopButton;
  InputElement stepButton;
  InputElement resetButton;
  
  HtmlElement generationCountLabel;
  
  StreamSubscription mouseMoveStream;
  StreamSubscription mouseUpStream;
  
  GameOfLife(this.canvas);
  
  List<bool> life = new List<bool>.filled(2500, false); 
  
  void start()
  {
    startStopButton = querySelector("#startStopButton");
    startStopButton.onClick.listen(startStopClicked);
    
    stepButton = querySelector("#stepButton");
    stepButton.onClick.listen(stepClicked);
    
    resetButton = querySelector("#resetButton");
    resetButton.onClick.listen(resetClicked);
    
    generationCountLabel = querySelector("#generationCountLabel");
    generationCountLabel.text = generationCount.toString();
    
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
  
  void startStopClicked(MouseEvent e)
  {
    running = !running;
    
    if (running)
    {
      startStopButton.value = "Stop";
      stepButton.disabled = true;
    }
    else
    {
      startStopButton.value = "Start";
      stepButton.disabled = false;
    }
  }
  
  void stepClicked(MouseEvent e)
  {
    updateGame();
  }
  
  void resetClicked(MouseEvent e)
  {
    running = false;
    startStopButton.value = "Start";
    stepButton.disabled = false;
    life = new List<bool>.filled(2500, false);
  }
  
  void update(double frameTime)
  {
    num dt = (frameTime - lastFrameTime)/1000;
    
    if (running)
    {
      gameTimer -= dt;      
    }
    
    if (gameTimer <= 0)
    {
      gameTimer = 0.1; 
      updateGame();
    }
    
    lastFrameTime = frameTime;
    window.animationFrame.then(update);
  }

  void updateGame()
  {
    List<int> changed = [];
    // Iterate over all
    for (int index = 0; index < life.length; index++)
    {
      int aliveNeighbors = 0;
      final int x = index % gridWidth;
      final int y = index ~/ gridWidth;
      
      for (int row = -1; row < 2; row++)
      {
        for (int col = -1; col < 2; col++)
        {
          final int nX = (x + col) % gridWidth;
          final int nY = (y + row) % gridHeight;
          final int nIndex = nY * gridWidth + nX;
          if (row == 0 && col == 0)
            continue;
          
          if (life[nIndex]) aliveNeighbors++;
        }
      }
      
      final bool alive = life[index];
      if (aliveNeighbors < 2 && alive)
      {
        // Die from starvation
        changed.add(index);
      }
      else if (aliveNeighbors > 3 && alive)
      {
        // Die from overpopulation
        changed.add(index);
      }
      else if (aliveNeighbors == 3 && !alive)
      {
        // Become alive, reproduction
        changed.add(index);
      }
    }
    
    changed.forEach(changeAndRedraw);
    changed.clear();
    generationCount++;
    generationCountLabel.text = generationCount.toString();
  }
  
  void changeAndRedraw(int index)
  {
    print('changing $index');
    life[index] = !life[index];
    drawType = life[index];
    drawTile(index);
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