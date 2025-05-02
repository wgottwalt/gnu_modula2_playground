(*!m2iso+gm2*)
MODULE TwoDCameraSplitScreen;

FROM SYSTEM IMPORT ADDRESS, ADR;
IMPORT Raylib;

CONST
  screen_width = 800;
  screen_height = 440;
  player_size = 40;

VAR
  Player1, Player2: Raylib.TRectangle;
  Camera1, Camera2: Raylib.TCamera2D;
  ScreenCamera1, ScreenCamera2: Raylib.TRenderTexture;
  SplitScreenRect: Raylib.TRectangle;
  Buffer: POINTER TO ARRAY[0..(Raylib.max_text_buffer_length - 1)] OF CHAR;
  I, J: INTEGER;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - 2d camera split screen");

  Player1 := Raylib.TRectangle{200.0, 200.0, player_size, player_size};
  Player2 := Raylib.TRectangle{250.0, 200.0, player_size, player_size};

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

  ScreenCamera1 := Raylib.LoadRenderTexture(screen_width / 2, screen_height);
  ScreenCamera2 := Raylib.LoadRenderTexture(screen_width / 2, screen_height);

  WITH SplitScreenRect DO
    X := 0.0;
    Y := 0.0;
    Width := VAL(SHORTREAL, ScreenCamera1.Texture.Width);
    Height := VAL(SHORTREAL, -ScreenCamera1.Texture.Height);
  END;

  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    IF Raylib.IsKeyDown(Raylib.key_s) THEN
      INC(Player1.Y, 3.0);
    ELSIF Raylib.IsKeyDown(Raylib.key_w) THEN
      DEC(Player1.Y, 3.0);
    END;
    IF Raylib.IsKeyDown(Raylib.key_d) THEN
      INC(Player1.X, 3.0);
    ELSIF Raylib.IsKeyDown(Raylib.key_a) THEN
      DEC(Player1.X, 3.0);
    END;

    IF Raylib.IsKeyDown(Raylib.key_up) THEN
      DEC(Player2.Y, 3.0);
    ELSIF Raylib.IsKeyDown(Raylib.key_down) THEN
      INC(Player2.Y, 3.0);
    END;
    IF Raylib.IsKeyDown(Raylib.key_right) THEN
      INC(Player2.X, 3.0);
    ELSIF Raylib.IsKeyDown(Raylib.key_left) THEN
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
      Raylib.ClearBackground(Raylib.raywhite);

      Raylib.BeginMode2D(Camera1);
        FOR I := 0 TO (screen_width / player_size) DO
          Raylib.DrawLine(player_size * I, 0, player_size * I, screen_height, Raylib.lightgray);
        END;

        FOR I := 0 TO (screen_height / player_size) DO
          Raylib.DrawLine(0, player_size * I, screen_width, player_size * I, Raylib.lightgray);
        END;

        FOR I := 0 TO (screen_width / player_size - 1) DO
          FOR J := 0 TO (screen_height / player_size - 1) DO
            Buffer := Raylib.TextFormat("[%i,%i]", I, J);
            Raylib.DrawText(Buffer^, 10 + player_size * I, 15 + player_size * J, 10,
                            Raylib.lightgray);
          END;
        END;

        Raylib.DrawRectangleRec(Player1, Raylib.red);
        Raylib.DrawRectangleRec(Player2, Raylib.blue);
      Raylib.EndMode2D;

      Raylib.DrawRectangle(0, 0, Raylib.GetScreenWidth() / 2, 30, Raylib.Fade(Raylib.raywhite,
                           0.6));
      Raylib.DrawText("PLAYER1: W/S/A/D to move", 10, 10, 10, Raylib.maroon);
    Raylib.EndTextureMode;

    Raylib.BeginTextureMode(ScreenCamera2);
      Raylib.ClearBackground(Raylib.raywhite);

      Raylib.BeginMode2D(Camera2);
        FOR I := 0 TO (screen_width / player_size) DO
          Raylib.DrawLine(player_size * I, 0, player_size * I, screen_height, Raylib.lightgray);
        END;

        FOR I := 0 TO (screen_height / player_size) DO
          Raylib.DrawLine(0, player_size * I, screen_width, player_size * I, Raylib.lightgray);
        END;

        FOR I := 0 TO (screen_width / player_size - 1) DO
          FOR J := 0 TO (screen_height / player_size - 1) DO
            Buffer := Raylib.TextFormat("[%i,%i]", I, J);
            Raylib.DrawText(Buffer^, 10 + player_size * I, 15 + player_size * J, 10,
                            Raylib.lightgray);
          END;
        END;

        Raylib.DrawRectangleRec(Player1, Raylib.red);
        Raylib.DrawRectangleRec(Player2, Raylib.blue);
      Raylib.EndMode2D;

      Raylib.DrawRectangle(0, 0, Raylib.GetScreenWidth() / 2, 30,
                           Raylib.Fade(Raylib.raywhite, 0.6));
      Raylib.DrawText("PLAYER2: UP/DOWN/LEFT/RIGHT to move", 10, 10, 10, Raylib.darkblue);
    Raylib.EndTextureMode;

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.black);

      Raylib.DrawTextureRec(ScreenCamera1.Texture, SplitScreenRect, Raylib.TVector2{0, 0},
                            Raylib.white);
      Raylib.DrawTextureRec(ScreenCamera2.Texture, SplitScreenRect,
                            Raylib.TVector2{VAL(SHORTREAL, screen_width) / 2.0, 0.0}, Raylib.white);
      Raylib.DrawRectangle(Raylib.GetScreenWidth() / 2 - 2, 0, 4, Raylib.GetScreenHeight(),
                           Raylib.lightgray);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END TwoDCameraSplitScreen.
