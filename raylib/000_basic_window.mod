MODULE BasicWindow;

IMPORT Raylib;

BEGIN
  Raylib.InitWindow(800, 450, "raylib [core] example - basic window");
  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    Raylib.BeginDrawing;
    Raylib.ClearBackground(Raylib.RAYWHITE);
    Raylib.DrawText("Congrats! You created your first window!", 190, 200, 20, Raylib.LIGHTGRAY);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END BasicWindow.
