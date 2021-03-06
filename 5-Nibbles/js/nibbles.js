var game = { };
game.width = 30;
game.height = 30;
game.gridSize = 10;

var snake = { };
snake.direction = 0;
snake.speed = 5;
snake.positions = [];

game.snake = snake;

// Setup UI
var scoreDisplay = document.getElementById('score');
var setup = function()
{
    game.reset();
};

game.reset = function()
{
    game.running = true;
    game.frameTimer = 0;
    game.score = 0;
    
    game.snake.scored = false;
    game.snake.direction = 0;
    game.snake.positions = [];
    var position = {x: 1, y: 0};
    game.snake.positions.push(position);
    position = {x: 0, y: 0};
    game.snake.positions.push(position);
    
    game.lastTimestamp = Date.now();
    
    game.run();
};

document.addEventListener('keydown', function(event)
{
    // TODO: Better direction check, moving to the side+backwards in one "frame" makes you dead
    if (event.keyCode == 39 && game.snake.direction !== 2)
    {
        game.snake.direction = 0;
    }
    else if (event.keyCode == 40 && game.snake.direction !== 3)
    {
        game.snake.direction = 1;
    }
    else if (event.keyCode == 37 && game.snake.direction !== 0)
    {
        game.snake.direction = 2;
    }
    else if (event.keyCode == 38 && game.snake.direction !== 1)
    {
        game.snake.direction = 3;
    }
}, true);

var GenerateCandy = function()
{
    var candyPosition = {x: 0, y: 0};
    var collision = true;
    while (collision)
    {
        collision = false;
        candyPosition.x = Math.floor((Math.random() * (game.width - 1)) + 1);
        candyPosition.y = Math.floor((Math.random() * (game.height - 1)) + 1);
        for (var pos = 0; pos < game.snake.positions.length; pos++)
        {
            if (candyPosition.x === game.snake.positions[pos].x &&
                candyPosition.y === game.snake.positions[pos].y)
            {
                collision = true;
            }
        }
    }
    console.log("Generated candy at " + candyPosition.x + ", " + candyPosition.y);
    return candyPosition;
};

game.candyPosition = GenerateCandy();

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

game.run = function(in_time)
{
    if (game.running)
    {
        var now = Date.now();
        var dt = now - game.lastTimestamp;
        game.frameTimer += dt;
        if (game.frameTimer > (1000 / game.snake.speed))
        {
            game.frameTimer = 0;
            
            game.update();
        }
        game.draw();
        game.lastTimestamp = now;
        raf(game.run);
    }
};

game.update = function()
{
    // Move snake
    for (var pos = game.snake.positions.length - 1; pos > 0; pos--)
    {
        game.snake.positions[pos].x = game.snake.positions[pos - 1].x;
        game.snake.positions[pos].y = game.snake.positions[pos - 1].y;
    }

    var delta = {x: 0, y: 0};
    switch(game.snake.direction)
    {
        case 0:
            delta.x = 1;
            break;
        case 1:
            delta.y = 1;
            break;
        case 2:
            delta.x = -1;
            break;
        case 3:
            delta.y = -1;
            break;
    }
    
    if(game.snake.scored)
    {
        game.snake.scored = false;
        delta.x += game.snake.positions[0].x;
        delta.y += game.snake.positions[0].y;
        game.snake.positions.unshift(delta);
    }
    else
    {
        game.snake.positions[0].x += delta.x;
        game.snake.positions[0].y += delta.y;
    }
    
    // Check for collisions:
    // Walls
    if (game.snake.positions[0].x < 0 || 
        game.snake.positions[0].y < 0 || 
        game.snake.positions[0].x >= game.width || 
        game.snake.positions[0].y >= game.height)
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
    if (game.snake.positions[0].x == game.candyPosition.x && 
        game.snake.positions[0].y == game.candyPosition.y)
    {
        game.candyPosition = GenerateCandy();
        game.snake.speed++;
        game.snake.scored = true;
        game.score++;
    }
    scoreDisplay.innerHTML = game.score;
};

game.draw = function()
{
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    
    // Candy
    ctx.fillStyle = "rgb(0,200,0)";
    ctx.fillRect(game.candyPosition.x * game.gridSize, 
                 game.candyPosition.y * game.gridSize, 
                 game.gridSize, game.gridSize);
    
    // Snake
    ctx.fillStyle = "rgb(200,0,0)";
    for (var pos = 0; pos < game.snake.positions.length; pos++)
    {
        ctx.fillRect (game.snake.positions[pos].x * game.gridSize, 
                      game.snake.positions[pos].y * game.gridSize, 
                      game.gridSize, game.gridSize);
    }
};

window.onload = setup();