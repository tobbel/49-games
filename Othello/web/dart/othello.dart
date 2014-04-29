import 'dart:async';
import 'dart:html';
import 'dart:math';

List<int> board = [0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0,
                   0,0,0,1,2,0,0,0,
                   0,0,0,2,1,0,0,0,
                   0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0];
void main()
{
  CanvasElement canvas = querySelector('#game');
  
  // Create game async as microtask 
  scheduleMicrotask(new Othello(canvas).start);
}

class Othello
{
  CanvasElement canvas;
  
  final int size = 8;
  int canvasWidth;
  int canvasHeight;
  int player = 1;
  
  final String backgroundColor = 'green'; 

  List<int> validIndices = [];
  List<String> colors = ['none', 'white', 'black'];
  
  // Automatically sets this.canvas to parameter
  Othello(this.canvas);
  
  void start()
  {
    canvasWidth = canvas.width;
    canvasHeight = canvas.height;
    canvas.onMouseDown.listen(mouseDown);
    
    calculateValidIndices();

    window.animationFrame.then(update);
  }
  
  void calculateValidIndices()
  {
    validIndices.clear();
    // Calculate valid places to put a brick, based the board and player turn.
    for (int i = 0; i < board.length; i++)
    {
      int x = i % 8;
      int y = i ~/ 8;
      int index = y * 8 + x;
      
      if (board[index] != 0)
        continue;

      for (int row = -1; row < 2; row++)
      {
        for (int col = -1; col < 2; col++)
        {
          int neighborX = x + col;
          int neighborY = y + row;
          if (isValidPoint(neighborX, neighborY))
          {
            int neighborIndex = neighborY * 8 + neighborX;
            if (board[neighborIndex] != 0)
            {
              if (board[neighborIndex] == player)
                continue;
              else
              {
                // Keep going in the same direction until we find a friend or reach the edge
                bool foundEnd = false;
                int nextNeighborX = neighborX;
                int nextNeighborY = neighborY;
                while (!foundEnd)
                {
                  // Next in neighbor direction
                  nextNeighborX += col;
                  nextNeighborY += row;
                  if (isValidPoint(nextNeighborX, nextNeighborY))
                  {
                    int nextNeighborIndex = nextNeighborY * 8 + nextNeighborX;
                    if (board[nextNeighborIndex] == player) foundEnd = true;
                  }
                  else break;
                }
                if (foundEnd)
                {
                  validIndices.add(index);
                }
              }
            }
          }
        }
      }
    }
    
    for (int i = 0; i < validIndices.length; i++)
    {
      print('${validIndices[i]}');
    }
  }
  
  bool isValidPoint(int x, int y)
  {
    return x >= 0 && y >= 0 && x < 8 && y < 8;
  }
  
  bool isValidIndex(int index)
  {
    return index >= 0 && index < board.length;
  }
  
  void mouseDown(MouseEvent e)
  {
    if (e.client == null) print('client is null');
    Rectangle rect = canvas.getBoundingClientRect();

    int x = (e.client.x - rect.left).toInt();
    int y = (e.client.y - rect.top).toInt();
    
    print('click at $x, $y');
    
    // Board coords
    int boardX = (x - 16) ~/ 64;
    int boardY = (y - 16) ~/ 64;
    
    print('boardcoords: $boardX, $boardY');

    Random random = new Random();
    int index = boardY * 8 + boardX;
    
    // Some playing around fun stuff
//    if (isValidIndex(index))
//    {
//      if (board[index] == 1)
//        board[index] = 2;
//      else if (board[index] == 2)
//        board[index] = 1;
//      else if (random.nextBool())
//      {
//        board[index] = 1;
//      }
//      else
//      {
//        board[index] = 2;
//      }
//      calculateValidIndices();
//    }
    
    if (validIndices.contains(index))
    {
      print('yay!');
      board[index] = player;
      if (player == 1) player = 2;
      else player = 1;
      // TODO: FLIP IT
      calculateValidIndices();
    }
  }
  
  void update(double dt)
  {
    // TODO: Update stuffz
    // TODO: Update rate
    draw(dt);

    window.animationFrame.then(update);
  }
  
  void draw(double dt)
  {
    CanvasRenderingContext2D context = canvas.context2D;
    context.clearRect(0, 0, canvasWidth, canvasHeight);
    
    // Green background
    context.fillStyle = backgroundColor;
    context.fillRect(0, 0, canvasWidth, canvasHeight);
    
    // Board
    int boardWidth = 512;
    int boardHeight = 512;
    int offset = 16;
    for (int x = 0; x <= boardWidth; x += 64)
    {
        context.moveTo(0.5 + x + offset, offset);
        context.lineTo(0.5 + x + offset, boardHeight + offset);
    }
    for (int y = 0; y <= boardHeight; y += 64) 
    {
      context.moveTo(offset, 0.5 + y + offset);
      context.lineTo(boardWidth + offset, 0.5 + y + offset);
    }

    context.strokeStyle = "black";
    context.stroke();
    
    // Pieces
    offset += 32;
    for (int i = 0; i < 64; i++)
    {
      int x = offset + (64 * (i % 8));
      int y = offset + (64 * (i ~/ 8));
      if (board[i] == 1)
        drawCircle(x, y, color:colors[1]);
      else if (board[i] == 2)
        drawCircle(x, y, color:colors[2]);
    }
    
    // Valid indices
    for (int i = 0; i < validIndices.length; i++)
    {
      int x = offset + (validIndices[i] % 8) * 64;
      int y = offset + (validIndices[i] ~/ 8) * 64;
      drawCircle(x, y, radius:10, color:colors[player]);
    }
  }
  
  void drawCircle(int x, int y, {int radius:30, String color:'white'})
  {
    CanvasRenderingContext2D context = canvas.context2D;
    context.beginPath();
    context.arc(x, y, radius, 0, 2 * PI, false);
    context.fillStyle = color;
    context.fill();
    context.lineWidth = 1;
    context.strokeStyle = '#003300';
    context.stroke();
  }
}