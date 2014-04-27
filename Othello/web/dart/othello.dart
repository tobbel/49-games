import 'dart:async';
import 'dart:html';

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
    var context = canvas.context2D;
    context.clearRect(0, 0, canvasWidth, canvasHeight);
    
    // Green background
    context.fillStyle = backgroundColor;
    context.fillRect(0, 0, canvasWidth, canvasHeight);
    
  }
}