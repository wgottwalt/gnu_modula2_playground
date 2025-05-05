(*!m2iso+gm2*)
MODULE InitializeThreeDCameraMode;

IMPORT Raylib;

CONST
  screen_width = 800;
  screen_height = 450;

VAR
  Camera: Raylib.TCamera3D;
  CubePosition: Raylib.TVector3;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - 3d camera mode");

  Camera := Raylib.TCamera3D{{0.0, 10.0, 10.0}, {0.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, 45.0,
                             Raylib.camera_perspective};
  CubePosition := Raylib.TVector3{0.0, 0.0, 0.0};

  Raylib.SetTargetFPS(60);
  WHILE NOT Raylib.WindowShouldClose() DO
    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.raywhite);

      Raylib.BeginMode3D(Camera);
        Raylib.DrawCube(CubePosition, 2.0, 2.0, 2.0, Raylib.red);
        Raylib.DrawCubeWires(CubePosition, 2.0, 2.0, 2.0, Raylib.maroon);

        Raylib.DrawGrid(10, 1.0);
      Raylib.EndMode3D;

      Raylib.DrawText("Welcome to the third dimension!", 10, 40, 20, Raylib.darkgray);
      Raylib.DrawFPS(10, 10);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow();
END InitializeThreeDCameraMode.
