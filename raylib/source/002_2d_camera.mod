(*!m2iso+gm2*)
MODULE TwoDCamera;

FROM SYSTEM IMPORT BYTE;
IMPORT Raylib;

CONST
  max_buildings = 100;
  screen_width = 800;
  screen_height = 450;

VAR
  Player: Raylib.TRectangle;
  Buildings: ARRAY[1..max_buildings] OF Raylib.TRectangle;
  BuildColors: ARRAY[1..max_buildings] OF Raylib.TColor;
  Camera: Raylib.TCamera2D;
  Spacing, I: INTEGER;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - 2d camera");

  Player := Raylib.TRectangle{400, 280, 40, 40};

  FOR I := 1 TO max_buildings DO
    WITH Buildings[I] DO
      Width := VAL(SHORTREAL, Raylib.GetRandomValue(50, 200));
      Height := VAL(SHORTREAL, Raylib.GetRandomValue(100, 800));
      Y := VAL(SHORTREAL, screen_height) - 130.0 - Height;
      X := -6000.0 + VAL(SHORTREAL, Spacing);
      Spacing := Spacing + VAL(INTEGER, Width);
    END;
    WITH BuildColors[I] DO
      R := VAL(BYTE, Raylib.GetRandomValue(200, 240));
      G := VAL(BYTE, Raylib.GetRandomValue(200, 240));
      B := VAL(BYTE, Raylib.GetRandomValue(200, 250));
      A := 255;
    END;
  END;

  WITH Camera DO
    Target.X := Player.X + 20.0;
    Target.Y := Player.Y + 20.0;
    Offset.X := VAL(SHORTREAL, screen_width) / 2.0;
    Offset.Y := VAL(SHORTREAL, screen_height) / 2.0;
    Rotation := 0.0;
    Zoom := 1.0;
  END;

  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    IF Raylib.IsKeyDown(Raylib.key_right) THEN
      INC(Player.X, 2.0);
    ELSIF Raylib.IsKeyDown(Raylib.key_left) THEN
      DEC(Player.X, 2.0);
    END;

    WITH Camera DO
      WITH Target DO
        X := Player.X + 20.0;
        Y := Player.Y + 20.0;
      END;

      IF Raylib.IsKeyDown(Raylib.key_a) THEN
        DEC(Rotation, 1.0);
      ELSIF Raylib.IsKeyDown(Raylib.key_s) THEN
        INC(Rotation, 1.0);
      END;

      IF Rotation > 40.0 THEN
        Rotation := 40.0;
      ELSIF Rotation < -40.0 THEN
        Rotation := -40.0;
      END;

      INC(Zoom, Raylib.GetMouseWheelMove() * 0.05);

      IF Zoom > 3.0 THEN
        Zoom := 3.0;
      ELSIF Zoom < 0.1 THEN
        Zoom := 0.1;
      END;

      IF Raylib.IsKeyPressed(Raylib.key_r) THEN
        Zoom := 1.0;
        Rotation := 0.0;
      END;
    END;

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.raywhite);

      Raylib.BeginMode2D(Camera);
        Raylib.DrawRectangle(-6000, 320, 13000, 8000, Raylib.darkgray);

        FOR I := 1 TO max_buildings DO
          Raylib.DrawRectangleRec(Buildings[I], BuildColors[I]);
        END;
        Raylib.DrawRectangleRec(Player, Raylib.red);

        WITH Camera.Target DO
          Raylib.DrawLine(VAL(INTEGER, X), -screen_height * 10, VAL(INTEGER, X),
                          screen_height * 10, Raylib.green);
          Raylib.DrawLine(-screen_width * 10, VAL(INTEGER, Y), screen_width * 10,
                          VAL(INTEGER, Y), Raylib.green);
        END;
      Raylib.EndMode2D;

      Raylib.DrawText("SCREEN AREA", 640, 10, 20, Raylib.red);

      Raylib.DrawRectangle(0, 0, screen_width, 5, Raylib.red);
      Raylib.DrawRectangle(0, 5, 5, screen_height - 10, Raylib.red);
      Raylib.DrawRectangle(screen_width - 5, 5, 5, screen_height - 10, Raylib.red);
      Raylib.DrawRectangle(0, screen_height - 5, screen_width, 5, Raylib.red);

      Raylib.DrawRectangle(10, 10, 250, 113, Raylib.Fade(Raylib.skyblue, 0.5));
      Raylib.DrawRectangleLines(10, 10, 250, 113, Raylib.blue);

      Raylib.DrawText("Free 2d camera controls:", 20, 20, 10, Raylib.black);
      Raylib.DrawText("- Right/Left to move Offset", 40, 40, 10, Raylib.darkgray);
      Raylib.DrawText("- Mouse Wheel to Zoom in-out", 40, 60, 10, Raylib.darkgray);
      Raylib.DrawText("- A / S to Rotate", 40, 80, 10, Raylib.darkgray);
      Raylib.DrawText("- R to reset Zoom and Rotation", 40, 100, 10, Raylib.darkgray);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END TwoDCamera.
