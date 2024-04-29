MODULE TitleScreen;

FROM SYSTEM IMPORT INTEGER32;
IMPORT Raylib;

TYPE
  GameScreen = (LOGO, TITLE, GAMEPLAY, ENDING);

CONST
  ScreenWidth = 800;
  ScreenHeight = 450;

VAR
  CurrentScreen: GameScreen;
  FramesCounter: INTEGER32;

BEGIN
  CurrentScreen := LOGO;
  FramesCounter := 0;

  Raylib.InitWindow(ScreenWidth, ScreenHeight, "raylib [core] example - basic screen manager");
  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    CASE CurrentScreen OF
      LOGO:
        FramesCounter := FramesCounter + 1;
        IF FramesCounter > 120 THEN
          CurrentScreen := TITLE;
        END |

      TITLE:
        IF Raylib.IsKeyPressed(Raylib.KEY_ENTER) OR Raylib.IsGestureDetected(Raylib.GESTURE_TAP) THEN
          CurrentScreen := GAMEPLAY;
        END |

      GAMEPLAY:
        IF Raylib.IsKeyPressed(Raylib.KEY_ENTER) OR Raylib.IsGestureDetected(Raylib.GESTURE_TAP) THEN
          CurrentScreen := ENDING
        END |

      ENDING:
        IF Raylib.IsKeyPressed(Raylib.KEY_ENTER) OR Raylib.IsGestureDetected(Raylib.GESTURE_TAP) THEN
          CurrentScreen := TITLE
        END;
    END;

    Raylib.BeginDrawing;
    Raylib.ClearBackground(Raylib.RAYWHITE);
    CASE CurrentScreen OF
      LOGO:
        Raylib.DrawText("LOGO SCREEN", 20, 20, 40, Raylib.LIGHTGRAY);
        Raylib.DrawText("WAIT for 2 SECONDS...", 290, 220, 20, Raylib.GRAY) |

      TITLE:
        Raylib.DrawRectangle(0, 0, ScreenWidth, ScreenHeight, Raylib.GREEN);
        Raylib.DrawText("TITLE SCREEN", 20, 20, 40, Raylib.DARKGREEN);
        Raylib.DrawText("PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN", 120, 220, 20,
                        Raylib.DARKGREEN) |

      GAMEPLAY:
        Raylib.DrawRectangle(0, 0, ScreenWidth, ScreenHeight, Raylib.PURPLE);
        Raylib.DrawText("GAMEPLAY SCREEN", 20, 20, 40, Raylib.MAROON);
        Raylib.DrawText("PRESS ENTER or TAP to JUMP to ENDING SCREEN", 130, 220, 20,
                        Raylib.MAROON) |

      ENDING:
        Raylib.DrawRectangle(0, 0, ScreenWidth, ScreenHeight, Raylib.BLUE);
        Raylib.DrawText("ENDING SCREEN", 20, 20, 40, Raylib.DARKBLUE);
        Raylib.DrawText("PRESS ENTER or TAP to RETURN to TITLE SCREEN", 120, 220, 20,
                        Raylib.DARKBLUE);
    END;
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END TitleScreen.
