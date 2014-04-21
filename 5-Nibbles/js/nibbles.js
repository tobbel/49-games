document.addEventListener('keydown', function(event)
{
    if (event.keyCode == 39)
    {
        game.snake.direction = 0;
    }
    else if (event.keyCode == 40)
    {
        game.snake.direction = 1;
    }
    else if (event.keyCode == 37)
    {
        game.snake.direction = 2;
    }
    else if (event.keyCode == 38)
    {
        game.snake.direction = 3;
    }
}, true);

var game = { };
game.running = true;
game.frameTimer = 0;
game.width = 30;
game.height = 30;
game.gridSize = 10;

var snake = { };
snake.x = 0;
snake.y = 0;
snake.direction = 0;
snake.size = 1;
snake.speed = 5;
game.snake = snake;

var raf =
        window.requestAnimationFrame       || 
        window.webkitRequestAnimationFrame || 
        window.mozRequestAnimationFrame    || 
        window.oRequestAnimationFrame      || 
        window.msRequestAnimationFrame;

var canvas = document.getElementById('canvas');
var ctx;
if (canvas.getContext)
{
    ctx = canvas.getContext('2d');
}

var lastTimestamp = Date.now();
game.run = function(in_time)
{
    if (game.running)
    {
        var now = Date.now();
        var dt = now - lastTimestamp;
        game.frameTimer += dt;
        if (game.frameTimer > (1000 / game.snake.speed))
        {
            game.frameTimer = 0;
            
            game.update();
            game.draw();
        }
        lastTimestamp = now;
        raf(game.run);
    }
};

game.update = function()
{
    // Move snake
    switch(game.snake.direction)
    {
        case 0:
            game.snake.x++;
            break;
        case 1:
            game.snake.y++;
            break;
        case 2:
            game.snake.x--;
            break;
        case 3:
            game.snake.y--;
            break;
    }
    
    // Check for collisions:
    // Walls
    if (game.snake.x < 0 || game.snake.y < 0 || game.snake.x > game.width || game.snake.y > game.height)
    {
        alert('dead');
        game.running = false;
    }
    
    // Itself
    
    // Canny
};

game.draw = function()
{
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    ctx.fillStyle = "rgb(200,0,0)";
    ctx.fillRect (game.snake.x * game.gridSize, game.snake.y * game.gridSize, game.gridSize, game.gridSize);
};