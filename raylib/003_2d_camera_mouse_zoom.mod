MODULE TwoDCameraMouseZoom;

FROM SYSTEM IMPORT ADR, REAL32;
IMPORT Raylib, Raymath, Rlgl;

CONST
  SCREEN_WIDTH = 800;
  SCREEN_HEIGHT = 450;
  ZOOM_INCREMENT = 0.125;

VAR
  Camera: Raylib.TCamera2D;
  Delta, MouseWorldPos: Raylib.TVector2;
  Wheel: REAL32;

BEGIN
  Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT,
                    ADR("raylib [core] example - 2d camera mouse zoom"));

  Camera.Zoom := 1.0;

  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    IF Raylib.IsMouseButtonDown(Raylib.MOUSE_BUTTON_RIGHT) THEN
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
        INC(Zoom, Wheel * ZOOM_INCREMENT);
        IF Zoom < ZOOM_INCREMENT THEN
          Zoom := ZOOM_INCREMENT;
        END;
      END;
    END;

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.BLACK);

      Raylib.BeginMode2D(Camera);
        Rlgl.rlPushMatrix;
        Rlgl.rlTranslatef(0.0, 25.0 * 50.0, 0.0);
        Rlgl.rlRotatef(90.0, 1.0, 0.0, 0.0);
        Raylib.DrawGrid(100, 50.0);
        Rlgl.rlPopMatrix;

        Raylib.DrawCircle(100, 100, 50.0, Raylib.YELLOW);
      Raylib.EndMode2D;

      Raylib.DrawText(ADR("Mouse right button drag to move, mouse wheel to zoom"), 10, 10, 20,
                      Raylib.WHITE);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END TwoDCameraMouseZoom.
