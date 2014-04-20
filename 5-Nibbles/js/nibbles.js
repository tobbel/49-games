document.addEventListener('keydown', function(event) {
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
game.fps = 100;
game.running = true;
game.frameTimer = Date.now();

var snake = { };
snake.x = 0;
snake.y = 0;
snake.direction = 0;
snake.length = 1;
snake.speed = 1;
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


game.run = function()
{
    if (game.running)
    {
        if (Date.now() - game.frameTimer > 1)
        {
            game.frameTimer = Date.now();
            raf(game.run, 1000 / game.fps);
            
            game.update();
            game.draw();
        }
    }
};

game.update = function()
{
    // Move snake
    switch(game.snake.direction)
    {
        case 0:
            game.snake.x += game.snake.speed;
            break;
        case 1:
            game.snake.y += game.snake.speed;
            break;
        case 2:
            game.snake.x -= game.snake.speed;
            break;
        case 3:
            game.snake.y -= game.snake.speed;
            break;
    }
    
    // Check for collisions:
    // Walls
    if (game.snake.x < 0 || game.snake.y < 0)
    {
        alert('dead');
        game.running = false;
    }
    
    // Itself
}

game.draw = function()
{
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    ctx.fillStyle = "rgb(200,0,0)";
    ctx.fillRect (game.snake.x, game.snake.y, 10, 10);
}