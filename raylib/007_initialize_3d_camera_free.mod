MODULE InitializeThreeDCameraFree;

FROM SYSTEM IMPORT ADR;
IMPORT Raylib;

CONST
  SCREEN_WIDTH = 800;
  SCREEN_HEIGHT = 450;

VAR
  Camera: Raylib.TCamera3D;
  CubePosition: Raylib.TVector3;

BEGIN
  Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, ADR("raylib [core] example - 3d camera free"));

  WITH Camera DO
    Position := Raylib.TVector3{10.0, 10.0, 10.0};
    Target := Raylib.TVector3{0.0, 0.0, 0.0};
    Up := Raylib.TVector3{0.0, 1.0, 0.0};
    FovY := 45.0;
    Projection := Raylib.CAMERA_PERSPECTIVE;
  END;

  CubePosition := Raylib.TVector3{0.0, 0.0, 0.0};

  Raylib.DisableCursor;
  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    Raylib.UpdateCamera(Camera, Raylib.CAMERA_FREE);

    IF Raylib.IsKeyPressed(Raylib.KEY_Z) THEN
      Camera.Target := Raylib.TVector3{0.0, 0.0, 0.0};
    END;

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.RAYWHITE);

      Raylib.BeginMode3D(Camera);
        Raylib.DrawCube(CubePosition, 2.0, 2.0, 2.0, Raylib.RED);
        Raylib.DrawCubeWires(CubePosition, 2.0, 2.0, 2.0, Raylib.MAROON);
        Raylib.DrawGrid(10, 1.0);
      Raylib.EndMode3D;

      Raylib.DrawRectangle(10, 10, 320, 93, Raylib.Fade(Raylib.SKYBLUE, 0.5));
      Raylib.DrawRectangleLines(10, 10, 320, 93, Raylib.BLUE);

      Raylib.DrawText(ADR("Free camera default controls:"), 20, 20, 10, Raylib.BLACK);
      Raylib.DrawText(ADR("- Mouse Wheel to Zoom in-out"), 40, 40, 10, Raylib.DARKGRAY);
      Raylib.DrawText(ADR("- Mouse Wheel Pressed to Pan"), 40, 60, 10, Raylib.DARKGRAY);
      Raylib.DrawText(ADR("- Z to zoom to (0, 0, 0)"), 40, 80, 10, Raylib.DARKGRAY);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END InitializeThreeDCameraFree.
