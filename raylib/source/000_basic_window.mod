(*!m2iso+gm2*)
MODULE BasicWindow;

IMPORT Raylib;

CONST
  screen_width = 800;
  screen_height = 450;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - basic window");
  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    Raylib.BeginDrawing;
    Raylib.ClearBackground(Raylib.raywhite);
    Raylib.DrawText("Congrats! You created your first window!", 190, 200, 20, Raylib.lightgray);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END BasicWindow.
