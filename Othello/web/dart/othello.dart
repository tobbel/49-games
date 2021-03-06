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
  // TODO: Win/lose screen
  // TODO: Controls for resetting game
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
  
  int p1Score = 2;
  int p2Score = 2;
  
  final String backgroundColor = 'green'; 

  List<int> validIndices = [];
  List<String> colors = ['none', 'white', 'black'];
  List<String> alphaColors = ['none', 'rgba(255,255,255,0.2)', 'rgba(0,0,0,0.2)'];
  
  // Automatically sets this.canvas to parameter
  Othello(this.canvas);
  
  void start()
  {
    canvasWidth = canvas.width;
    canvasHeight = canvas.height;
    canvas.onMouseDown.listen(mouseDown);
    
    SpanElement p1ScoreLabel = querySelector("#player1score");
    SpanElement p2ScoreLabel = querySelector("#player2score");
    p1ScoreLabel.innerHtml = p1Score.toString();
    p2ScoreLabel.innerHtml = p2Score.toString();
    
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
      int index = i;
      
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
    Rectangle rect = canvas.getBoundingClientRect();

    int x = (e.client.x - rect.left).toInt();
    int y = (e.client.y - rect.top).toInt();
    
    // Board coords
    int boardX = (x - 16) ~/ 64;
    int boardY = (y - 16) ~/ 64;

    Random random = new Random();
    int index = boardY * 8 + boardX;
    
    if (validIndices.contains(index))
    {
      board[index] = player;
      flipTiles(index);
      if (player == 1) player = 2;
      else player = 1;
      
      calculateValidIndices();
      
      if (validIndices.length <= 0)
      {
        if (player == 1) player = 2;
        else player = 1;
        
        calculateValidIndices();
        
        if (validIndices.length <= 0)
        {
          // End game
        }
      }
    }
    
    p1Score = 0;
    p2Score = 0;
    for (int i = 0; i < board.length; i++)
    {
      if (board[i] == 1)
        p1Score++;
      else if (board[i] == 2)
        p2Score++;
    }

    SpanElement p1ScoreLabel = querySelector("#player1score");
    SpanElement p2ScoreLabel = querySelector("#player2score");
    p1ScoreLabel.innerHtml = p1Score.toString();
    p2ScoreLabel.innerHtml = p2Score.toString();
  }
  
  void flipTiles(int index)
  {
    List<int> allToFlip = [];

      final int x = index % 8;
      final int y = index ~/ 8;
      
      for (int row = -1; row < 2; row++)
      {
        for (int col = -1; col < 2; col++)
        {
          if (row == 0 && col == 0) continue;
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
                List<int> toFlip = [neighborIndex];
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
                    toFlip.add(nextNeighborIndex);
                    if (board[nextNeighborIndex] == player)
                    {
                      foundEnd = true;
                    }
                  }
                  else break;
                }
                if (foundEnd)
                {
                  toFlip.forEach((f) => allToFlip.add(f));
                }
              }
            }
          }
        }
      }
    
    for (int i = 0; i < allToFlip.length; i++)
    {
      board[allToFlip[i]] = player;
    }
  }
  
  void update(double dt)
  {
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
      drawCircle(x, y, radius:24, color:alphaColors[player]);
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