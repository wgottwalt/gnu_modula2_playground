(*!m2iso+gm2*)
MODULE PickingInThreeDMode;

IMPORT Raylib;

CONST
  screen_width = 800;
  screen_height = 450;

VAR
  Camera: Raylib.TCamera;
  Collision: Raylib.TRayCollision;
  Bounding: Raylib.TBoundingBox;
  Ray: Raylib.TRay;
  CubePosition, CubeSize: Raylib.TVector3;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - 3d picking");

  Camera := Raylib.TCamera{{10.0, 10.0, 10.0}, {0.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, 45.0,
                           Raylib.camera_perspective};
  CubePosition := Raylib.TVector3{0.0, 1.0, 0.0};
  CubeSize := Raylib.TVector3{2.0, 2.0, 2.0};
  Ray := Raylib.TRay{{0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}};
  Collision := Raylib.TRayCollision{FALSE, 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}};

  Raylib.SetTargetFPS(60);
  WHILE NOT Raylib.WindowShouldClose() DO
    IF Raylib.IsCursorHidden() THEN
      Raylib.UpdateCamera(Camera, Raylib.camera_first_person);
    END;

    IF Raylib.IsMouseButtonPressed(Raylib.mouse_button_right) THEN
      IF Raylib.IsCursorHidden() THEN
        Raylib.EnableCursor;
      ELSE
        Raylib.DisableCursor;
      END;
    END;

    IF Raylib.IsMouseButtonPressed(Raylib.mouse_button_left) THEN
      IF NOT Collision.Hit THEN
        Ray := Raylib.GetScreenToWorldRay(Raylib.GetMousePosition(), Camera);

        WITH Bounding DO
          Min.X := CubePosition.X - CubeSize.X / 2.0;
          Min.Y := CubePosition.Y - CubeSize.Y / 2.0;
          Min.Z := CubePosition.Z - CubeSize.Z / 2.0;
          Max.X := CubePosition.X + CubeSize.X / 2.0;
          Max.Y := CubePosition.Y + CubeSize.Y / 2.0;
          Max.Z := CubePosition.Z + CubeSize.Z / 2.0;
        END;

        Collision := Raylib.GetRayCollisionBox(Ray, Bounding);
      ELSE
        Collision.Hit := FALSE;
      END;
    END;

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.raywhite);

      Raylib.BeginMode3D(Camera);
        IF Collision.Hit THEN
          Raylib.DrawCube(CubePosition, CubeSize.X, CubeSize.Y, CubeSize.Z, Raylib.red);
          Raylib.DrawCubeWires(CubePosition, CubeSize.X, CubeSize.Y, CubeSize.Z, Raylib.maroon);

          Raylib.DrawCubeWires(CubePosition, CubeSize.X + 0.2, CubeSize.Y + 0.2, CubeSize.Z + 0.2,
                               Raylib.green);
        ELSE
          Raylib.DrawCube(CubePosition, CubeSize.X, CubeSize.Y, CubeSize.Z, Raylib.gray);
          Raylib.DrawCubeWires(CubePosition, CubeSize.X, CubeSize.Y, CubeSize.Z, Raylib.darkgray);
        END;

        Raylib.DrawRay(Ray, Raylib.maroon);
        Raylib.DrawGrid(10, 1.0);
      Raylib.EndMode3D;

      Raylib.DrawText("Try clicking on the box with your mouse!", 240, 10, 20, Raylib.darkgray);

      IF Collision.Hit THEN
        Raylib.DrawText("BOX SELECTED", (screen_width - Raylib.MeasureText("BOX SELECTED", 30)) / 2,
                        VAL(INTEGER, VAL(SHORTREAL, screen_height) * 0.1), 30, Raylib.green);
      END;

      Raylib.DrawText("Right click mouse to toggle camera controls", 10, 430, 10, Raylib.gray);
      Raylib.DrawFPS(10, 10);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END PickingInThreeDMode.
