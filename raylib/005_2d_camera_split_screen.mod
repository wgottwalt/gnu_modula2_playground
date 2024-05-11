MODULE TwoDCameraSplitScreen;

FROM libc IMPORT memset, strncpy;
FROM SYSTEM IMPORT ADR, INTEGER32, REAL32;
IMPORT Raylib;

CONST
  CHAR_ARRAY_SIZE = 16;
  SCREEN_WIDTH = 800;
  SCREEN_HEIGHT = 440;
  PLAYER_SIZE = 40;

VAR
  CharBuffer: ARRAY[1..CHAR_ARRAY_SIZE] OF CHAR;
  Player1, Player2: Raylib.TRectangle;
  Camera1, Camera2: Raylib.TCamera2D;
  ScreenCamera1, ScreenCamera2: Raylib.TRenderTexture;
  SplitScreenRect: Raylib.TRectangle;
  I, J: INTEGER32;

BEGIN
  Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - 2d camera split screen");

  Player1 := Raylib.TRectangle{200.0, 200.0, PLAYER_SIZE, PLAYER_SIZE};
  Player2 := Raylib.TRectangle{250.0, 200.0, PLAYER_SIZE, PLAYER_SIZE};

  WITH Camera1 DO
    Target.X := Player1.X;
    Target.Y := Player1.Y;
    Offset.X := 200.0;
    Offset.Y := 200.0;
    Rotation := 0.0;
    Zoom := 1.0;
  END;

  WITH Camera2 DO
    Target.X := Player2.X;
    Target.Y := Player2.Y;
    Offset.X := 200.0;
    Offset.Y := 200.0;
    Rotation := 0.0;
    Zoom := 1.0;
  END;

  ScreenCamera1 := Raylib.LoadRenderTexture(SCREEN_WIDTH / 2, SCREEN_HEIGHT);
  ScreenCamera2 := Raylib.LoadRenderTexture(SCREEN_WIDTH / 2, SCREEN_HEIGHT);

  WITH SplitScreenRect DO
    X := 0.0;
    Y := 0.0;
    Width := VAL(REAL32, ScreenCamera1.Texture.Width);
    Height := VAL(REAL32, -ScreenCamera1.Texture.Height);
  END;

  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    IF Raylib.IsKeyDown(Raylib.KEY_S) THEN
      INC(Player1.Y, 3.0);
    ELSIF Raylib.IsKeyDown(Raylib.KEY_W) THEN
      DEC(Player1.Y, 3.0);
    END;
    IF Raylib.IsKeyDown(Raylib.KEY_D) THEN
      INC(Player1.X, 3.0);
    ELSIF Raylib.IsKeyDown(Raylib.KEY_A) THEN
      DEC(Player1.X, 3.0);
    END;

    IF Raylib.IsKeyDown(Raylib.KEY_UP) THEN
      DEC(Player2.Y, 3.0);
    ELSIF Raylib.IsKeyDown(Raylib.KEY_DOWN) THEN
      INC(Player2.Y, 3.0);
    END;
    IF Raylib.IsKeyDown(Raylib.KEY_RIGHT) THEN
      INC(Player2.X, 3.0);
    ELSIF Raylib.IsKeyDown(Raylib.KEY_LEFT) THEN
      DEC(Player2.X, 3.0);
    END;

    WITH Camera1.Target DO
      X := Player1.X;
      Y := Player1.Y;
    END;
    WITH Camera2.Target DO
      X := Player2.X;
      Y := Player2.Y;
    END;

    Raylib.BeginTextureMode(ScreenCamera1);
      Raylib.ClearBackground(Raylib.RAYWHITE);

      Raylib.BeginMode2D(Camera1);
        FOR I := 0 TO (SCREEN_WIDTH / PLAYER_SIZE) DO
          Raylib.DrawLine(PLAYER_SIZE * I, 0, PLAYER_SIZE * I, SCREEN_HEIGHT, Raylib.LIGHTGRAY);
        END;

        FOR I := 0 TO (SCREEN_HEIGHT / PLAYER_SIZE) DO
          Raylib.DrawLine(0, PLAYER_SIZE * I, SCREEN_WIDTH, PLAYER_SIZE * I, Raylib.LIGHTGRAY);
        END;

        FOR I := 0 TO (SCREEN_WIDTH / PLAYER_SIZE - 1) DO
          FOR J := 0 TO (SCREEN_HEIGHT / PLAYER_SIZE - 1) DO
            memset(ADR(CharBuffer), 0, CHAR_ARRAY_SIZE);
            strncpy(ADR(CharBuffer), Raylib.TextFormat("[%i,%i]", I, J), CHAR_ARRAY_SIZE);
            Raylib.DrawText(CharBuffer, 10 + PLAYER_SIZE * I, 15 + PLAYER_SIZE * J, 10,
                            Raylib.LIGHTGRAY);
          END;
        END;

        Raylib.DrawRectangleRec(Player1, Raylib.RED);
        Raylib.DrawRectangleRec(Player2, Raylib.BLUE);
      Raylib.EndMode2D;

      Raylib.DrawRectangle(0, 0, Raylib.GetScreenWidth() / 2, 30, Raylib.Fade(Raylib.RAYWHITE,
                           0.6));
      Raylib.DrawText("PLAYER1: W/S/A/D to move", 10, 10, 10, Raylib.MAROON);
    Raylib.EndTextureMode;

    Raylib.BeginTextureMode(ScreenCamera2);
      Raylib.ClearBackground(Raylib.RAYWHITE);

      Raylib.BeginMode2D(Camera2);
        FOR I := 0 TO (SCREEN_WIDTH / PLAYER_SIZE) DO
          Raylib.DrawLine(PLAYER_SIZE * I, 0, PLAYER_SIZE * I, SCREEN_HEIGHT, Raylib.LIGHTGRAY);
        END;

        FOR I := 0 TO (SCREEN_HEIGHT / PLAYER_SIZE) DO
          Raylib.DrawLine(0, PLAYER_SIZE * I, SCREEN_WIDTH, PLAYER_SIZE * I, Raylib.LIGHTGRAY);
        END;

        FOR I := 0 TO (SCREEN_WIDTH / PLAYER_SIZE - 1) DO
          FOR J := 0 TO (SCREEN_HEIGHT / PLAYER_SIZE - 1) DO
            memset(ADR(CharBuffer), 0, CHAR_ARRAY_SIZE);
            strncpy(ADR(CharBuffer), Raylib.TextFormat("[%i,%i]", I, J), CHAR_ARRAY_SIZE);
            Raylib.DrawText(CharBuffer, 10 + PLAYER_SIZE * I, 15 + PLAYER_SIZE * J, 10,
                            Raylib.LIGHTGRAY);
          END;
        END;

        Raylib.DrawRectangleRec(Player1, Raylib.RED);
        Raylib.DrawRectangleRec(Player2, Raylib.BLUE);
      Raylib.EndMode2D;

      Raylib.DrawRectangle(0, 0, Raylib.GetScreenWidth() / 2, 30,
                           Raylib.Fade(Raylib.RAYWHITE, 0.6));
      Raylib.DrawText("PLAYER2: UP/DOWN/LEFT/RIGHT to move", 10, 10, 10, Raylib.DARKBLUE);
    Raylib.EndTextureMode;

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.BLACK);

      Raylib.DrawTextureRec(ScreenCamera1.Texture, SplitScreenRect, Raylib.TVector2{0, 0},
                            Raylib.WHITE);
      Raylib.DrawTextureRec(ScreenCamera2.Texture, SplitScreenRect,
                            Raylib.TVector2{VAL(REAL32, SCREEN_WIDTH) / 2.0, 0.0}, Raylib.WHITE);
      Raylib.DrawRectangle(Raylib.GetScreenWidth() / 2 - 2, 0, 4, Raylib.GetScreenHeight(),
                           Raylib.LIGHTGRAY);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END TwoDCameraSplitScreen.
