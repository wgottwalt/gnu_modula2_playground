MODULE BasicWindow;

IMPORT Raylib;

CONST
  SCREEN_WIDTH = 800;
  SCREEN_HEIGHT = 450;

BEGIN
  Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic window");
  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    Raylib.BeginDrawing;
    Raylib.ClearBackground(Raylib.RAYWHITE);
    Raylib.DrawText("Congrats! You created your first window!", 190, 200, 20, Raylib.LIGHTGRAY);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END BasicWindow.
