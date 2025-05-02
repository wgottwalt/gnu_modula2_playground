(*!m2iso+gm2*)
MODULE ThreeDCameraFirstPerson;

FROM SYSTEM IMPORT ADR, BYTE;
IMPORT Raylib, Raymath, RCamera;

CONST
  max_columns = 20;
  screen_width = 800;
  screen_height = 450;

VAR
  Camera: Raylib.TCamera;
  CameraMode: INTEGER;
  Heights: ARRAY[0..(max_columns - 1)] OF SHORTREAL;
  Positions: ARRAY[0..(max_columns - 1)] OF Raylib.TVector3;
  Colors: ARRAY[0..(max_columns - 1)] OF Raylib.TColor;
  I: INTEGER;
  Buffer: POINTER TO ARRAY[0..(Raylib.max_text_buffer_length - 1)] OF CHAR;
  CharBuffer: ARRAY[0..15] OF CHAR;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - 3d camera first person");

  WITH Camera DO
    Position := Raylib.TVector3{0.0, 2.0, 4.0};
    Target := Raylib.TVector3{0.0, 2.0, 0.0};
    Up := Raylib.TVector3{0.0, 1.0, 0.0};
    FovY := 60.0;
    Projection := Raylib.camera_perspective;
  END;

  CameraMode := Raylib.camera_first_person;

  FOR I := 0 TO (max_columns - 1) DO
    Heights[I] := Raylib.GetRandomValue(1, 12);

    WITH Positions[I] DO
      X := VAL(SHORTREAL, Raylib.GetRandomValue(-15, 15));
      Y := Heights[I] / 2.0;
      Z := VAL(SHORTREAL, Raylib.GetRandomValue(-15, 15));
    END;

    WITH Colors[I] DO
      R := VAL(BYTE, Raylib.GetRandomValue(20, 255));
      G := VAL(BYTE, Raylib.GetRandomValue(10, 55));
      B := 30;
      A := 255;
    END;
  END;

  Raylib.DisableCursor;
  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    IF Raylib.IsKeyPressed(Raylib.key_one) THEN
      CameraMode := Raylib.camera_free;
      Camera.Up := Raylib.TVector3{0.0, 1.0, 0.0};
    END;

    IF Raylib.IsKeyPressed(Raylib.key_two) THEN
      CameraMode := Raylib.camera_first_person;
      Camera.Up := Raylib.TVector3{0.0, 1.0, 0.0};
    END;

    IF Raylib.IsKeyPressed(Raylib.key_three) THEN
      CameraMode := Raylib.camera_third_person;
      Camera.Up := Raylib.TVector3{0.0, 1.0, 0.0};
    END;

    IF Raylib.IsKeyPressed(Raylib.key_four) THEN
      CameraMode := Raylib.camera_orbital;
      Camera.Up := Raylib.TVector3{0.0, 1.0, 0.0};
    END;

    IF Raylib.IsKeyPressed(Raylib.key_p) THEN
      IF Camera.Projection = Raylib.camera_perspective THEN
        CameraMode := Raylib.camera_third_person;

        WITH Camera DO
          Position := Raylib.TVector3{0.0, 2.0, -100.0};
          Target := Raylib.TVector3{0.0, 2.0, 0.0};
          Up := Raylib.TVector3{0.0, 1.0, 0.0};
          Projection := Raylib.camera_orthographic;
          FovY := 20.0;

          RCamera.CameraYaw(Camera, -135.0 * Raymath.deg2rad, TRUE);
          RCamera.CameraPitch(Camera, -45.0 * Raymath.deg2rad, TRUE, TRUE, FALSE);
        END;
      ELSIF Camera.Projection = Raylib.camera_orthographic THEN
        CameraMode := Raylib.camera_third_person;

        WITH Camera DO
          Position := Raylib.TVector3{0.0, 2.0, 10.0};
          Target := Raylib.TVector3{0.0, 2.0, 0.0};
          Up := Raylib.TVector3{0.0, 1.0, 0.0};
          Projection := Raylib.camera_perspective;
          FovY := 60.0;
        END;
      END;
    END;

    Raylib.UpdateCamera(Camera, CameraMode);

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.raywhite);

      Raylib.BeginMode3D(Camera);
        Raylib.DrawPlane(Raylib.TVector3{0.0, 0.0, 0.0}, Raylib.TVector2{32.0, 32.0},
                         Raylib.lightgray);
        Raylib.DrawCube(Raylib.TVector3{-16.0, 2.5, 0.0}, 1.0, 5.0, 32.0, Raylib.blue);
        Raylib.DrawCube(Raylib.TVector3{16.0, 2.5, 0.0}, 1.0, 5.0, 32.0, Raylib.lime);
        Raylib.DrawCube(Raylib.TVector3{0.0, 2.5, 16.0}, 32.0, 5.0, 1.0, Raylib.gold);

        FOR I := 0 TO (max_columns - 1) DO
          Raylib.DrawCube(Positions[I], 2.0, Heights[I], 2.0, Colors[I]);
          Raylib.DrawCubeWires(Positions[I], 2.0, Heights[I], 2.0, Raylib.maroon);
        END;

        IF CameraMode = Raylib.camera_third_person THEN
          Raylib.DrawCube(Camera.Target, 0.5, 0.5, 0.5, Raylib.purple);
          Raylib.DrawCubeWires(Camera.Target, 0.5, 0.5, 0.5, Raylib.darkpurple);
        END;
      Raylib.EndMode3D;

      Raylib.DrawRectangle(5, 5, 330, 100, Raylib.Fade(Raylib.skyblue, 0.5));
      Raylib.DrawRectangleLines(5, 5, 330, 100, Raylib.blue);

      Raylib.DrawText("Camera controls:", 15, 15, 10, Raylib.black);
      Raylib.DrawText("- Move keys: W, A, S, D, Space, Left-Ctrl", 15, 30, 10, Raylib.black);
      Raylib.DrawText("- Look around: arrow keys or mouse", 15, 45, 10, Raylib.black);
      Raylib.DrawText("- Camera mode keys: 1, 2, 3, 4", 15, 60, 10, Raylib.black);
      Raylib.DrawText("- Zoom keys: num-plus, num-minus or mouse scroll", 15, 75, 10, Raylib.black);
      Raylib.DrawText("- Camera projection key: P", 15, 90, 10, Raylib.black);

      Raylib.DrawRectangle(600, 5, 195, 100, Raylib.Fade(Raylib.skyblue, 0.5));
      Raylib.DrawRectangleLines(600, 5, 195, 100, Raylib.blue);

      Raylib.DrawText("Camera status:", 610, 15, 10, Raylib.black);

      CASE CameraMode OF
        | Raylib.camera_free: CharBuffer := "FREE";
        | Raylib.camera_first_person: CharBuffer := "FIRST_PERSON";
        | Raylib.camera_third_person: CharBuffer := "THIRD_PERSON";
        | Raylib.camera_orbital: CharBuffer := "ORBITAL";
      ELSE
        CharBuffer := "CUSTOM";
      END;
      Buffer := Raylib.TextFormat("- Mode: %s", CharBuffer);
      Raylib.DrawText(Buffer^, 610, 30, 10, Raylib.black);

      WITH Camera DO
        CASE Projection OF
          | Raylib.camera_perspective: CharBuffer := "PERSPECTIVE";
          | Raylib.camera_orthographic: CharBuffer := "ORTHOGRAPHIC";
        ELSE
          CharBuffer := "CUSTOM";
        END;
        Buffer := Raylib.TextFormat("- Projection: %s", CharBuffer);
        Raylib.DrawText(Buffer^, 610, 45, 10, Raylib.black);

        WITH Position DO
          Buffer := Raylib.TextFormat("- Position: (%06.3f, %06.3f, %06.3f)", VAL(REAL, X),
                                      VAL(REAL, Y), VAL(REAL, Z));
          Raylib.DrawText(Buffer^, 610, 60, 10, Raylib.black);
        END;
        WITH Target DO
          Buffer := Raylib.TextFormat("- Target: (%06.3f, %06.3f, %06.3f)", VAL(REAL, X),
                                      VAL(REAL, Y), VAL(REAL, Z));
          Raylib.DrawText(Buffer^, 610, 75, 10, Raylib.black);
        END;
        WITH Up DO
          Buffer := Raylib.TextFormat("- Up: (%06.3f, %06.3f, %06.3f)", VAL(REAL, X), VAL(REAL, Y),
                                      VAL(REAL, Z));
          Raylib.DrawText(Buffer^, 610, 90, 10, Raylib.black);
        END;
      END;
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END ThreeDCameraFirstPerson.
