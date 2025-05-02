(*!m2iso+gm2*)
MODULE TwoDCameraMouseZoom;

IMPORT Raylib, Raymath, Rlgl;

CONST
  screen_width = 800;
  screen_height = 450;
  zoom_increment = 0.125;

VAR
  Camera: Raylib.TCamera2D;
  Delta, MouseWorldPos: Raylib.TVector2;
  Wheel: SHORTREAL;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - 2d camera mouse zoom");

  Camera.Zoom := 1.0;

  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    IF Raylib.IsMouseButtonDown(Raylib.mouse_button_right) THEN
      Delta := Raylib.GetMouseDelta();
      Delta := Raymath.Vector2Scale(Delta, -1.0 / Camera.Zoom);
      Camera.Target := Raymath.Vector2Add(Camera.Target, Delta);
    END;

    Wheel := Raylib.GetMouseWheelMove();
    IF Wheel <> 0.0 THEN
      MouseWorldPos := Raylib.GetScreenToWorld2D(Raylib.GetMousePosition(), Camera);
      WITH Camera DO
        Offset := Raylib.GetMousePosition();
        Target := MouseWorldPos;
        INC(Zoom, Wheel * zoom_increment);
        IF Zoom < zoom_increment THEN
          Zoom := zoom_increment;
        END;
      END;
    END;

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.black);

      Raylib.BeginMode2D(Camera);
        Rlgl.rlPushMatrix;
        Rlgl.rlTranslatef(0.0, 25.0 * 50.0, 0.0);
        Rlgl.rlRotatef(90.0, 1.0, 0.0, 0.0);
        Raylib.DrawGrid(100, 50.0);
        Rlgl.rlPopMatrix;

        Raylib.DrawCircle(100, 100, 50.0, Raylib.yellow);
      Raylib.EndMode2D;

      Raylib.DrawText("Mouse right button drag to move, mouse wheel to zoom", 10, 10, 20,
                      Raylib.white);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END TwoDCameraMouseZoom.
