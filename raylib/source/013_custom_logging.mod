(*!m2iso+gm2*)
MODULE CustomLogging;

IMPORT CustomLog, Raylib;

CONST
  screen_width = 800;
  screen_height = 450;

BEGIN
  Raylib.SetTraceLogCallback(CustomLog.CustomLog);

  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - custom logging");

  Raylib.SetTargetFPS(60);
  WHILE NOT Raylib.WindowShouldClose() DO
    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.raywhite);

      Raylib.DrawText("Check out the console output to see the custom logger in action!", 60, 200,
                      20, Raylib.lightgray);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END CustomLogging.
