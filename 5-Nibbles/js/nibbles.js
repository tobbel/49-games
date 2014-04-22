document.addEventListener('keydown', function(event)
{
    if (event.keyCode == 39 && game.snake.direction != 2)
    {
        game.snake.direction = 0;
    }
    else if (event.keyCode == 40 && game.snake.direction != 3)
    {
        game.snake.direction = 1;
    }
    else if (event.keyCode == 37 && game.snake.direction != 0)
    {
        game.snake.direction = 2;
    }
    else if (event.keyCode == 38 && game.snake.direction != 1)
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
snake.direction = 0;
// Unused for now
snake.size = 5;
snake.speed = 5;

snake.positions = [];
var position = {x: 5, y: 1};
snake.positions.push(position);
position = {x: 4, y: 1};
snake.positions.push(position);
position = {x: 3, y: 1};
snake.positions.push(position);
position = {x: 2, y: 1};
snake.positions.push(position);
position = {x: 1, y: 1};
snake.positions.push(position);
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
        }
        game.draw();
        lastTimestamp = now;
        raf(game.run);
    }
};

game.update = function()
{
    // Move snake
    for (var pos = game.snake.positions.length - 1; pos > 0; pos--)
    {
        console.log(game.snake.positions[pos]);
        game.snake.positions[pos].x = game.snake.positions[pos - 1].x;
        game.snake.positions[pos].y = game.snake.positions[pos - 1].y;
    }
    
    switch(game.snake.direction)
    {
        case 0:
            game.snake.positions[0].x++;
            break;
        case 1:
            game.snake.positions[0].y++;
            break;
        case 2:
            game.snake.positions[0].x--;
            break;
        case 3:
            game.snake.positions[0].y--;
            break;
    }
    
    // Check for collisions:
    // Walls
    if (game.snake.positions[0].x < 0 || game.snake.positions[0].y < 0 || game.snake.positions[0].x >= game.width || game.snake.positions[0].y >= game.height)
    {
        alert('dead');
        game.running = false;
    }
    
    // Itself
    for (var pos = 1; pos < game.snake.positions.length; pos++)
    {
        if (game.snake.positions[0].x === game.snake.positions[pos].x &&
            game.snake.positions[0].y === game.snake.positions[pos].y)
        {
            alert('dead');
            game.running = false;
        }
    }
    
    // Canny
};

game.draw = function()
{
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    ctx.fillStyle = "rgb(200,0,0)";
    for (var pos = 0; pos < game.snake.positions.length; pos++)
    {
        ctx.fillRect (game.snake.positions[pos].x * game.gridSize, game.snake.positions[pos].y * game.gridSize, game.gridSize, game.gridSize);
    }
};