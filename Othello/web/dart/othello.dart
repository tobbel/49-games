import 'dart:async';
import 'dart:html';
import 'dart:math';

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
  
  final String backgroundColor = 'green'; 
  
  // Automatically sets this.canvas to in parameter
  Othello(this.canvas);
  
  void start()
  {
    canvasWidth = canvas.width;
    canvasHeight = canvas.height;
    
    window.requestAnimationFrame(update);
  }
  
  void update(double time)
  {
    // TODO: Update stuffz
    // TODO: Update rate
    draw(time);
  }
  
  void draw(double time)
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
    Random random = new Random();
    for (int i = 0; i < 64; i++)
    {
      int x = offset + (64 * (i % 8));
      int y = offset + (64 * (i ~/ 8));
      if (random.nextBool())
        drawCircle(x, y, 'black');
      else
        drawCircle(x, y, 'white');
    }
  }
  
  void drawCircle(int x, int y, String color)
  {

    int radius = 30;
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