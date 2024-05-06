MODULE TwoDCamera;

FROM SYSTEM IMPORT INTEGER32, REAL32;
IMPORT Raylib;

CONST
  MAX_BUILDINGS = 100;
  SCREEN_WIDTH = 800;
  SCREEN_HEIGHT = 450;

VAR
  Player: Raylib.TRectangle;
  Buildings: ARRAY[1..MAX_BUILDINGS] OF Raylib.TRectangle;
  BuildColors: ARRAY[1..MAX_BUILDINGS] OF Raylib.TColor;
  Camera: Raylib.TCamera2D;
  Spacing: INTEGER32;
  I: INTEGER32;

BEGIN
  Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - 2d camera");

  Player := Raylib.TRectangle{400, 280, 40, 40};

  FOR I := 1 TO MAX_BUILDINGS DO
    WITH Buildings[I] DO
      Width := VAL(REAL32, Raylib.GetRandomValue(50, 200));
      Height := VAL(REAL32, Raylib.GetRandomValue(100, 800));
      Y := VAL(REAL32, SCREEN_HEIGHT) - 130.0 - Height;
      X := -6000.0 + VAL(REAL32, Spacing);
      Spacing := Spacing + VAL(INTEGER32, Width);
    END;
    WITH BuildColors[I] DO
      R := Raylib.GetRandomValue(200, 240);
      G := Raylib.GetRandomValue(200, 240);
      B := Raylib.GetRandomValue(200, 250);
      A := 255;
    END;
  END;

  WITH Camera DO
    Target.X := Player.X + 20.0;
    Target.Y := Player.Y + 20.0;
    Offset.X := VAL(REAL32, SCREEN_WIDTH) / 2.0;
    Offset.Y := VAL(REAL32, SCREEN_HEIGHT) / 2.0;
    Rotation := 0.0;
    Zoom := 1.0;
  END;

  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    IF Raylib.IsKeyDown(Raylib.KEY_RIGHT) THEN
      INC(Player.X, 2.0);
    ELSE
      IF Raylib.IsKeyDown(Raylib.KEY_LEFT) THEN
        DEC(Player.X, 2.0);
      END;
    END;

    WITH Camera DO
      WITH Target DO
        X := Player.X + 20.0;
        Y := Player.Y + 20.0;
      END;

      IF Raylib.IsKeyDown(Raylib.KEY_A) THEN
        DEC(Rotation);
      ELSE
        IF Raylib.IsKeyDown(Raylib.KEY_S) THEN
          INC(Rotation);
        END;
      END;

      IF Rotation > 40.0 THEN
        Rotation := 40.0;
      ELSE
        IF Rotation < -40.0 THEN
          Rotation := -40.0;
        END;
      END;

      INC(Zoom, Raylib.GetMouseWheelMove() * 0.05);

      IF Zoom > 3.0 THEN
        Zoom := 3.0;
      ELSE
        IF Zoom < 0.1 THEN
          Zoom := 0.1;
        END;
      END;

      IF Raylib.IsKeyPressed(Raylib.KEY_R) THEN
        Zoom := 1.0;
        Rotation := 0.0;
      END;
    END;

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.RAYWHITE);

      Raylib.BeginMode2D(Camera);
        Raylib.DrawRectangle(-6000, 320, 13000, 8000, Raylib.DARKGRAY);

        FOR I := 1 TO MAX_BUILDINGS DO
          Raylib.DrawRectangleRec(Buildings[I], BuildColors[I]);
        END;
        Raylib.DrawRectangleRec(Player, Raylib.RED);

        WITH Camera.Target DO
          Raylib.DrawLine(VAL(INTEGER32, X), -SCREEN_HEIGHT * 10, VAL(INTEGER32, X),
                          SCREEN_HEIGHT * 10, Raylib.GREEN);
          Raylib.DrawLine(-SCREEN_WIDTH * 10, VAL(INTEGER32, Y), SCREEN_WIDTH * 10,
                          VAL(INTEGER32, Y), Raylib.GREEN);
        END;
      Raylib.EndMode2D;

      Raylib.DrawText("SCREEN AREA", 640, 10, 20, Raylib.RED);

      Raylib.DrawRectangle(0, 0, SCREEN_WIDTH, 5, Raylib.RED);
      Raylib.DrawRectangle(0, 5, 5, SCREEN_HEIGHT - 10, Raylib.RED);
      Raylib.DrawRectangle(SCREEN_WIDTH - 5, 5, 5, SCREEN_HEIGHT - 10, Raylib.RED);
      Raylib.DrawRectangle(0, SCREEN_HEIGHT - 5, SCREEN_WIDTH, 5, Raylib.RED);

      Raylib.DrawRectangle(10, 10, 250, 113, Raylib.Fade(Raylib.SKYBLUE, 0.5));
      Raylib.DrawRectangleLines(10, 10, 250, 113, Raylib.BLUE);

      Raylib.DrawText("Free 2d camera controls:", 20, 20, 10, Raylib.BLACK);
      Raylib.DrawText("- Right/Left to move Offset", 40, 40, 10, Raylib.DARKGRAY);
      Raylib.DrawText("- Mouse Wheel to Zoom in-out", 40, 60, 10, Raylib.DARKGRAY);
      Raylib.DrawText("- A / S to Rotate", 40, 80, 10, Raylib.DARKGRAY);
      Raylib.DrawText("- R to reset Zoom and Rotation", 40, 100, 10, Raylib.DARKGRAY);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END TwoDCamera.
