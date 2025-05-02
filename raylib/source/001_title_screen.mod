(*!m2iso+gm2*)
MODULE TitleScreen;

IMPORT Raylib;

TYPE
  GameScreen = (LOGO, TITLE, GAMEPLAY, ENDING);

CONST
  screen_width = 800;
  screen_height = 450;

VAR
  CurrentScreen: GameScreen;
  FramesCounter: INTEGER;

BEGIN
  CurrentScreen := LOGO;
  FramesCounter := 0;

  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - basic screen manager");
  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    CASE CurrentScreen OF
      | LOGO:
        INC(FramesCounter);
        IF FramesCounter > 120 THEN
          CurrentScreen := TITLE;
        END;

      | TITLE:
        IF Raylib.IsKeyPressed(Raylib.key_enter) OR Raylib.IsGestureDetected(Raylib.gesture_tap) THEN
          CurrentScreen := GAMEPLAY;
        END;

      | GAMEPLAY:
        IF Raylib.IsKeyPressed(Raylib.key_enter) OR Raylib.IsGestureDetected(Raylib.gesture_tap) THEN
          CurrentScreen := ENDING;
        END;

      | ENDING:
        IF Raylib.IsKeyPressed(Raylib.key_enter) OR Raylib.IsGestureDetected(Raylib.gesture_tap) THEN
          CurrentScreen := TITLE;
        END;
    END;

    Raylib.BeginDrawing;
    Raylib.ClearBackground(Raylib.raywhite);
    CASE CurrentScreen OF
      | LOGO:
        Raylib.DrawText("LOGO SCREEN", 20, 20, 40, Raylib.lightgray);
        Raylib.DrawText("WAIT for 2 SECONDS...", 290, 220, 20, Raylib.gray);

      | TITLE:
        Raylib.DrawRectangle(0, 0, screen_width, screen_height, Raylib.green);
        Raylib.DrawText("TITLE SCREEN", 20, 20, 40, Raylib.darkgreen);
        Raylib.DrawText("PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN", 120, 220, 20,
                        Raylib.darkgreen);

      | GAMEPLAY:
        Raylib.DrawRectangle(0, 0, screen_width, screen_height, Raylib.purple);
        Raylib.DrawText("GAMEPLAY SCREEN", 20, 20, 40, Raylib.maroon);
        Raylib.DrawText("PRESS ENTER or TAP to JUMP to ENDING SCREEN", 130, 220, 20, Raylib.maroon);

      | ENDING:
        Raylib.DrawRectangle(0, 0, screen_width, screen_height, Raylib.blue);
        Raylib.DrawText("ENDING SCREEN", 20, 20, 40, Raylib.darkblue);
        Raylib.DrawText("PRESS ENTER or TAP to RETURN to TITLE SCREEN", 120, 220, 20,
                        Raylib.darkblue);
    END;
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END TitleScreen.
