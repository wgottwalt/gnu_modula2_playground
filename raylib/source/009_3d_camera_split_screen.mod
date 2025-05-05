(*!m2iso+gm2*)
MODULE ThreeDCameraSplitScreen;

IMPORT Raylib;

CONST
  screen_width = 800;
  screen_height = 450;
  count = 5.0;
  spacing = 4.0;

VAR
  CameraPlayer1, CameraPlayer2: Raylib.TCamera;
  ScreenPlayer1, ScreenPlayer2: Raylib.TRenderTexture;
  SplitScreenRect: Raylib.TRectangle;
  Temp: Raylib.TVector3;
  OffsetThisFrame, X, Z: SHORTREAL;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - 3d camera split screen");

  CameraPlayer1 := Raylib.TCamera{{0.0, 1.0, -3.0}, {0.0, 1.0, 0.0}, {0.0, 1.0, 0.0}, 45.0,
                                  Raylib.camera_perspective};
  CameraPlayer2 := Raylib.TCamera{{-3.0, 3.0, 0.0}, {0.0, 3.0, 0.0}, {0.0, 1.0, 0.0}, 45.0,
                                  Raylib.camera_perspective};

  ScreenPlayer1 := Raylib.LoadRenderTexture(screen_width / 2, screen_height);
  ScreenPlayer2 := Raylib.LoadRenderTexture(screen_width / 2, screen_height);

  WITH SplitScreenRect DO
    X := 0.0;
    Y := 0.0;
    Width := VAL(SHORTREAL, ScreenPlayer1.Texture.Width);
    Height := VAL(SHORTREAL, -ScreenPlayer1.Texture.Height);
  END;

  Raylib.SetTargetFPS(60);
  WHILE NOT Raylib.WindowShouldClose() DO
    OffsetThisFrame := 10.0 * Raylib.GetFrameTime();

    WITH CameraPlayer1 DO
      IF Raylib.IsKeyDown(Raylib.key_w) THEN
        INC(Position.Z, OffsetThisFrame);
        INC(Target.Z, OffsetThisFrame);
      ELSIF Raylib.IsKeyDown(Raylib.key_s) THEN
        DEC(Position.Z, OffsetThisFrame);
        DEC(Target.Z, OffsetThisFrame);
      END;
    END;

    WITH CameraPlayer2 DO
      IF Raylib.IsKeyDown(Raylib.key_up) THEN
        INC(Position.X, OffsetThisFrame);
        INC(Target.X, OffsetThisFrame);
      ELSIF Raylib.IsKeyDown(Raylib.key_down) THEN
        DEC(Position.X, OffsetThisFrame);
        DEC(Target.X, OffsetThisFrame);
      END;
    END;

    Raylib.BeginTextureMode(ScreenPlayer1);
      Raylib.ClearBackground(Raylib.skyblue);

      Raylib.BeginMode3D(CameraPlayer1);
        Raylib.DrawPlane(Raylib.TVector3{0.0, 0.0, 0.0}, Raylib.TVector2{50.0, 50.0}, Raylib.beige);

        X := (-count * spacing);
        WHILE X <= (count * spacing) DO
          Z := (-count * spacing);
          WHILE Z <= (count * spacing) DO
            Temp.X := X;
            Temp.Y := 1.5;
            Temp.Z := Z;
            Raylib.DrawCube(Temp, 1.0, 1.0, 1.0, Raylib.lime);

            Temp.Y := 0.5;
            Raylib.DrawCube(Temp, 0.25, 1.0, 0.25, Raylib.brown);

            INC(Z, spacing);
          END;

          INC(X, spacing);
        END;

        Raylib.DrawCube(CameraPlayer1.Position, 1.0, 1.0, 1.0, Raylib.red);
        Raylib.DrawCube(CameraPlayer2.Position, 1.0, 1.0, 1.0, Raylib.blue);
      Raylib.EndMode3D;

      Raylib.DrawRectangle(0, 0, Raylib.GetScreenWidth() / 2, 40,
                           Raylib.Fade(Raylib.raywhite, 0.8));
      Raylib.DrawText("PLAYER1: W/S to move", 10, 10, 20, Raylib.maroon);
    Raylib.EndTextureMode;

    Raylib.BeginTextureMode(ScreenPlayer2);
      Raylib.ClearBackground(Raylib.skyblue);

      Raylib.BeginMode3D(CameraPlayer2);
        Raylib.DrawPlane(Raylib.TVector3{0.0, 0.0, 0.0}, Raylib.TVector2{50.0, 50.0}, Raylib.beige);

        X := (-count * spacing);
        WHILE X <= (count * spacing) DO
          Z := (-count * spacing);
          WHILE Z <= (count * spacing) DO
            Temp.X := X;
            Temp.Y := 1.5;
            Temp.Z := Z;
            Raylib.DrawCube(Temp, 1.0, 1.0, 1.0, Raylib.lime);

            Temp.Y := 0.5;
            Raylib.DrawCube(Temp, 0.25, 1.0, 0.25, Raylib.brown);

            INC(Z, spacing);
          END;

          INC(X, spacing);
        END;

        Raylib.DrawCube(CameraPlayer1.Position, 1.0, 1.0, 1.0, Raylib.red);
        Raylib.DrawCube(CameraPlayer2.Position, 1.0, 1.0, 1.0, Raylib.blue);
      Raylib.EndMode3D;

      Raylib.DrawRectangle(0, 0, Raylib.GetScreenWidth() / 2, 40,
                           Raylib.Fade(Raylib.raywhite, 0.8));
      Raylib.DrawText("PLAYER2: UP/DOWN to move", 10, 10, 20, Raylib.darkblue);
    Raylib.EndTextureMode;

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.black);

      Raylib.DrawTextureRec(ScreenPlayer1.Texture, SplitScreenRect, Raylib.TVector2{0.0, 0.0},
                            Raylib.white);
      Raylib.DrawTextureRec(ScreenPlayer2.Texture, SplitScreenRect,
                            Raylib.TVector2{VAL(SHORTREAL, screen_width) / 2.0, 0.0}, Raylib.white);

      Raylib.DrawRectangle(Raylib.GetScreenWidth() / 2 - 2, 0, 4, Raylib.GetScreenHeight(),
                           Raylib.lightgray);
    Raylib.EndDrawing;
  END;

  Raylib.UnloadRenderTexture(ScreenPlayer2);
  Raylib.UnloadRenderTexture(ScreenPlayer1);

  Raylib.CloseWindow;
END ThreeDCameraSplitScreen.
