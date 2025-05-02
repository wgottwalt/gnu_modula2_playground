(*!m2iso+gm2*)
MODULE InitializeThreeDCameraFree;

FROM SYSTEM IMPORT ADR;
IMPORT Raylib;

CONST
  screen_width = 800;
  screen_height = 450;

VAR
  Camera: Raylib.TCamera3D;
  CubePosition: Raylib.TVector3;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - 3d camera free");

  WITH Camera DO
    Position := Raylib.TVector3{10.0, 10.0, 10.0};
    Target := Raylib.TVector3{0.0, 0.0, 0.0};
    Up := Raylib.TVector3{0.0, 1.0, 0.0};
    FovY := 45.0;
    Projection := Raylib.camera_perspective;
  END;

  CubePosition := Raylib.TVector3{0.0, 0.0, 0.0};

  Raylib.DisableCursor;
  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    Raylib.UpdateCamera(Camera, Raylib.camera_free);

    IF Raylib.IsKeyPressed(Raylib.key_z) THEN
      Camera.Target := Raylib.TVector3{0.0, 0.0, 0.0};
    END;

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.raywhite);

      Raylib.BeginMode3D(Camera);
        Raylib.DrawCube(CubePosition, 2.0, 2.0, 2.0, Raylib.red);
        Raylib.DrawCubeWires(CubePosition, 2.0, 2.0, 2.0, Raylib.maroon);
        Raylib.DrawGrid(10, 1.0);
      Raylib.EndMode3D;

      Raylib.DrawRectangle(10, 10, 320, 93, Raylib.Fade(Raylib.skyblue, 0.5));
      Raylib.DrawRectangleLines(10, 10, 320, 93, Raylib.blue);

      Raylib.DrawText("Free camera default controls:", 20, 20, 10, Raylib.black);
      Raylib.DrawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, Raylib.darkgray);
      Raylib.DrawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, Raylib.darkgray);
      Raylib.DrawText("- Z to zoom to (0, 0, 0)", 40, 80, 10, Raylib.darkgray);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END InitializeThreeDCameraFree.
