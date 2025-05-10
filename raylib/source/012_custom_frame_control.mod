(*!m2iso+gm2*)
MODULE CustomFrameControl;

FROM Delay IMPORT Delay;
IMPORT Raylib;

CONST
  screen_width = 800;
  screen_height = 450;

VAR
  Buffer: POINTER TO ARRAY[0..(Raylib.max_text_buffer_length - 1)] OF CHAR;
  PreviousTime, CurrentTime, UpdateDrawTime, WaitTime: REAL;
  DeltaTime, TimeCounter, Position: SHORTREAL;
  TargetFPS, I: INTEGER;
  Pause: BOOLEAN;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - custom frame control");

  PreviousTime := Raylib.GetTime();
  CurrentTime := 0.0;
  UpdateDrawTime := 0.0;
  WaitTime := 0.0;
  DeltaTime := 0.0;
  TimeCounter := 0.0;
  Position := 0.0;
  TargetFPS := 60;
  Pause := FALSE;

  WHILE NOT Raylib.WindowShouldClose() DO
    Raylib.PollInputEvents();

    IF Raylib.IsKeyPressed(Raylib.key_space) THEN
      Pause := NOT Pause;
    END;

    IF Raylib.IsKeyPressed(Raylib.key_up) THEN
      INC(TargetFPS, 20);
    ELSIF Raylib.IsKeyPressed(Raylib.key_down) THEN
      DEC(TargetFPS, 20);
    END;

    IF TargetFPS < 0 THEN
      TargetFPS := 0;
    END;

    IF NOT Pause THEN
      INC(Position, 200.0 * DeltaTime);
      IF Position >= VAL(SHORTREAL, Raylib.GetScreenWidth()) THEN
        Position := 0.0;
      END;
      INC(TimeCounter, DeltaTime);
    END;

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.raywhite);

      FOR I := 0 TO (Raylib.GetScreenWidth() / 200 - 1) DO
        Raylib.DrawRectangle(200 * I, 0, 1, Raylib.GetScreenHeight(), Raylib.skyblue);
      END;

      Raylib.DrawCircle(VAL(INTEGER, Position), Raylib.GetScreenHeight() / 2 - 25, 50.0,
                        Raylib.red);
      (* all printf based functions can not deal with floats, you need to cast to doubles *)
      Buffer := Raylib.TextFormat("%03.0f ms", VAL(REAL, TimeCounter * 1000.0));
      Raylib.DrawText(Buffer^, VAL(INTEGER, Position) - 40, Raylib.GetScreenHeight() / 2 - 100, 20,
                      Raylib.maroon);
      Buffer := Raylib.TextFormat("PosX: %03.0f", VAL(REAL, Position));
      Raylib.DrawText(Buffer^, VAL(INTEGER, Position) - 50, Raylib.GetScreenHeight() / 2 + 40, 20,
                      Raylib.black);

      Raylib.DrawText(
        "Circle is moving at a constant 200 pixels/sec,\nindependently of the frame rate.",
        10, 10, 20, Raylib.darkgray);
      Raylib.DrawText("PRESS SPACE to PAUSE MOVEMENT", 10, Raylib.GetScreenHeight() - 60, 20,
                      Raylib.gray);
      Raylib.DrawText("PRESS UP | DOWN to CHANGE TARGET FPS", 10, Raylib.GetScreenHeight() - 30, 20,
                      Raylib.gray);
      Buffer := Raylib.TextFormat("TARGET FPS: %i", TargetFPS);
      Raylib.DrawText(Buffer^, Raylib.GetScreenWidth() - 220, 10, 20, Raylib.lime);
      IF DeltaTime # 0.0 THEN
        Buffer := Raylib.TextFormat("CURRENT FPS: %i", VAL(INTEGER, 1.0 / DeltaTime));
        Raylib.DrawText(Buffer^, Raylib.GetScreenWidth() - 220, 40, 20, Raylib.green);
      END;
    Raylib.EndDrawing;

    Raylib.SwapScreenBuffer;

    CurrentTime := Raylib.GetTime();
    UpdateDrawTime := CurrentTime - PreviousTime;

    IF TargetFPS > 0 THEN
      WaitTime := 1.0 / VAL(REAL, TargetFPS) - UpdateDrawTime;
      IF WaitTime > 0.0 THEN
        (* Raylib needs to be compiled with SUPPORT_CUSTOM_FRAME_CONTROL *)
        (*Raylib.WaitTime(VAL(REAL, WaitTime));*)
        Delay(VAL(INTEGER, WaitTime * 1000.0));
        CurrentTime := Raylib.GetTime();
        DeltaTime := VAL(SHORTREAL, CurrentTime - PreviousTime);
      END;
    ELSE
      DeltaTime := VAL(SHORTREAL, UpdateDrawTime);
    END;

    PreviousTime := CurrentTime;
  END;

  Raylib.CloseWindow;
END CustomFrameControl.
