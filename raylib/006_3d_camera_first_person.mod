MODULE ThreeDCameraFirstPerson;

FROM SYSTEM IMPORT ADR, INTEGER32, REAL32, REAL64;
IMPORT Raylib;
IMPORT Raymath;
IMPORT RCamera;

CONST
  MAX_COLUMNS = 20;
  SCREEN_WIDTH = 800;
  SCREEN_HEIGHT = 450;

VAR
  Camera: Raylib.TCamera;
  CameraMode: INTEGER32;
  Heights: ARRAY[0..(MAX_COLUMNS - 1)] OF REAL32;
  Positions: ARRAY[0..(MAX_COLUMNS - 1)] OF Raylib.TVector3;
  Colors: ARRAY[0..(MAX_COLUMNS - 1)] OF Raylib.TColor;
  I: INTEGER32;
  CharBuffer: ARRAY[0..15] OF CHAR;

BEGIN
  Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT,
                    ADR("raylib [core] example - 3d camera first person"));

  WITH Camera DO
    Position := Raylib.TVector3{0.0, 2.0, 4.0};
    Target := Raylib.TVector3{0.0, 2.0, 0.0};
    Up := Raylib.TVector3{0.0, 1.0, 0.0};
    FovY := 60.0;
    Projection := Raylib.CAMERA_PERSPECTIVE;
  END;

  CameraMode := Raylib.CAMERA_FIRST_PERSON;

  FOR I := 0 TO (MAX_COLUMNS - 1) DO
    Heights[I] := Raylib.GetRandomValue(1, 12);

    WITH Positions[I] DO
      X := VAL(REAL32, Raylib.GetRandomValue(-15, 15));
      Y := Heights[I] / 2.0;
      Z := VAL(REAL32, Raylib.GetRandomValue(-15, 15));
    END;

    WITH Colors[I] DO
      R := Raylib.GetRandomValue(20, 255);
      G := Raylib.GetRandomValue(10, 55);
      B := 30;
      A := 255;
    END;
  END;

  Raylib.DisableCursor;
  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    IF Raylib.IsKeyPressed(Raylib.KEY_ONE) THEN
      CameraMode := Raylib.CAMERA_FREE;
      Camera.Up := Raylib.TVector3{0.0, 1.0, 0.0};
    END;

    IF Raylib.IsKeyPressed(Raylib.KEY_TWO) THEN
      CameraMode := Raylib.CAMERA_FIRST_PERSON;
      Camera.Up := Raylib.TVector3{0.0, 1.0, 0.0};
    END;

    IF Raylib.IsKeyPressed(Raylib.KEY_THREE) THEN
      CameraMode := Raylib.CAMERA_THIRD_PERSON;
      Camera.Up := Raylib.TVector3{0.0, 1.0, 0.0};
    END;

    IF Raylib.IsKeyPressed(Raylib.KEY_FOUR) THEN
      CameraMode := Raylib.CAMERA_ORBITAL;
      Camera.Up := Raylib.TVector3{0.0, 1.0, 0.0};
    END;

    IF Raylib.IsKeyPressed(Raylib.KEY_P) THEN
      IF Camera.Projection = Raylib.CAMERA_PERSPECTIVE THEN
        CameraMode := Raylib.CAMERA_THIRD_PERSON;

        WITH Camera DO
          Position := Raylib.TVector3{0.0, 2.0, -100.0};
          Target := Raylib.TVector3{0.0, 2.0, 0.0};
          Up := Raylib.TVector3{0.0, 1.0, 0.0};
          Projection := Raylib.CAMERA_ORTHOGRAPHIC;
          FovY := 20.0;

          RCamera.CameraYaw(Camera, -135.0 * Raymath.DEG2RAD, TRUE);
          RCamera.CameraPitch(Camera, -45.0 * Raymath.DEG2RAD, TRUE, TRUE, FALSE);
        END;
      ELSIF Camera.Projection = Raylib.CAMERA_ORTHOGRAPHIC THEN
        CameraMode := Raylib.CAMERA_THIRD_PERSON;

        WITH Camera DO
          Position := Raylib.TVector3{0.0, 2.0, 10.0};
          Target := Raylib.TVector3{0.0, 2.0, 0.0};
          Up := Raylib.TVector3{0.0, 1.0, 0.0};
          Projection := Raylib.CAMERA_PERSPECTIVE;
          FovY := 60.0;
        END;
      END;
    END;

    Raylib.UpdateCamera(Camera, CameraMode);

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.RAYWHITE);

      Raylib.BeginMode3D(Camera);
        Raylib.DrawPlane(Raylib.TVector3{0.0, 0.0, 0.0}, Raylib.TVector2{32.0, 32.0},
                         Raylib.LIGHTGRAY);
        Raylib.DrawCube(Raylib.TVector3{-16.0, 2.5, 0.0}, 1.0, 5.0, 32.0, Raylib.BLUE);
        Raylib.DrawCube(Raylib.TVector3{16.0, 2.5, 0.0}, 1.0, 5.0, 32.0, Raylib.LIME);
        Raylib.DrawCube(Raylib.TVector3{0.0, 2.5, 16.0}, 32.0, 5.0, 1.0, Raylib.GOLD);

        FOR I := 0 TO (MAX_COLUMNS - 1) DO
          Raylib.DrawCube(Positions[I], 2.0, Heights[I], 2.0, Colors[I]);
          Raylib.DrawCubeWires(Positions[I], 2.0, Heights[I], 2.0, Raylib.MAROON);
        END;

        IF CameraMode = Raylib.CAMERA_THIRD_PERSON THEN
          Raylib.DrawCube(Camera.Target, 0.5, 0.5, 0.5, Raylib.PURPLE);
          Raylib.DrawCubeWires(Camera.Target, 0.5, 0.5, 0.5, Raylib.DARKPURPLE);
        END;
      Raylib.EndMode3D;

      Raylib.DrawRectangle(5, 5, 330, 100, Raylib.Fade(Raylib.SKYBLUE, 0.5));
      Raylib.DrawRectangleLines(5, 5, 330, 100, Raylib.BLUE);

      Raylib.DrawText(ADR("Camera controls:"), 15, 15, 10, Raylib.BLACK);
      Raylib.DrawText(ADR("- Move keys: W, A, S, D, Space, Left-Ctrl"), 15, 30, 10, Raylib.BLACK);
      Raylib.DrawText(ADR("- Look around: arrow keys or mouse"), 15, 45, 10, Raylib.BLACK);
      Raylib.DrawText(ADR("- Camera mode keys: 1, 2, 3, 4"), 15, 60, 10, Raylib.BLACK);
      Raylib.DrawText(ADR("- Zoom keys: num-plus, num-minus or mouse scroll"), 15, 75, 10,
                      Raylib.BLACK);
      Raylib.DrawText(ADR("- Camera projection key: P"), 15, 90, 10, Raylib.BLACK);

      Raylib.DrawRectangle(600, 5, 195, 100, Raylib.Fade(Raylib.SKYBLUE, 0.5));
      Raylib.DrawRectangleLines(600, 5, 195, 100, Raylib.BLUE);

      Raylib.DrawText(ADR("Camera status:"), 610, 15, 10, Raylib.BLACK);

      CASE CameraMode OF
        Raylib.CAMERA_FREE: CharBuffer := "FREE"
        | Raylib.CAMERA_FIRST_PERSON: CharBuffer := "FIRST_PERSON"
        | Raylib.CAMERA_THIRD_PERSON: CharBuffer := "THIRD_PERSON"
        | Raylib.CAMERA_ORBITAL: CharBuffer := "ORBITAL"
      ELSE
        CharBuffer := "CUSTOM";
      END;
      Raylib.DrawText(Raylib.TextFormat("- Mode: %s", CharBuffer), 610, 30, 10, Raylib.BLACK);

      WITH Camera DO
        CASE Projection OF
          Raylib.CAMERA_PERSPECTIVE: CharBuffer := "PERSPECTIVE"
          | Raylib.CAMERA_ORTHOGRAPHIC: CharBuffer := "ORTHOGRAPHIC"
        ELSE
          CharBuffer := "CUSTOM";
        END;
        Raylib.DrawText(Raylib.TextFormat("- Projection: %s", CharBuffer), 610, 45, 10,
                        Raylib.BLACK);

        WITH Position DO
          Raylib.DrawText(Raylib.TextFormat("- Position: (%06.3f, %06.3f, %06.3f)", VAL(REAL64, X),
                          VAL(REAL64, Y), VAL(REAL64, Z)), 610, 60, 10, Raylib.BLACK);
        END;
        WITH Target DO
          Raylib.DrawText(Raylib.TextFormat("- Target: (%06.3f, %06.3f, %06.3f)", VAL(REAL64, X),
                          VAL(REAL64, Y), VAL(REAL64, Z)), 610, 75, 10, Raylib.BLACK);
        END;
        WITH Up DO
          Raylib.DrawText(Raylib.TextFormat("- Up: (%06.3f, %06.3f, %06.3f)", VAL(REAL64, X),
                          VAL(REAL64, Y), VAL(REAL64, Z)), 610, 90, 10, Raylib.BLACK);
        END;
      END;
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END ThreeDCameraFirstPerson.
