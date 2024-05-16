MODULE TitleScreen;

FROM SYSTEM IMPORT ADR, INTEGER32;
IMPORT Raylib;

TYPE
  GameScreen = (LOGO, TITLE, GAMEPLAY, ENDING);

CONST
  SCREEN_WIDTH = 800;
  SCREEN_HEIGHT = 450;

VAR
  CurrentScreen: GameScreen;
  FramesCounter: INTEGER32;

BEGIN
  CurrentScreen := LOGO;
  FramesCounter := 0;

  Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT,
                    ADR("raylib [core] example - basic screen manager"));
  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    CASE CurrentScreen OF
      LOGO:
        INC(FramesCounter);
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
        Raylib.DrawText(ADR("LOGO SCREEN"), 20, 20, 40, Raylib.LIGHTGRAY);
        Raylib.DrawText(ADR("WAIT for 2 SECONDS..."), 290, 220, 20, Raylib.GRAY) |

      TITLE:
        Raylib.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Raylib.GREEN);
        Raylib.DrawText(ADR("TITLE SCREEN"), 20, 20, 40, Raylib.DARKGREEN);
        Raylib.DrawText(ADR("PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN"), 120, 220, 20,
                        Raylib.DARKGREEN) |

      GAMEPLAY:
        Raylib.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Raylib.PURPLE);
        Raylib.DrawText(ADR("GAMEPLAY SCREEN"), 20, 20, 40, Raylib.MAROON);
        Raylib.DrawText(ADR("PRESS ENTER or TAP to JUMP to ENDING SCREEN"), 130, 220, 20,
                        Raylib.MAROON) |

      ENDING:
        Raylib.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Raylib.BLUE);
        Raylib.DrawText(ADR("ENDING SCREEN"), 20, 20, 40, Raylib.DARKBLUE);
        Raylib.DrawText(ADR("PRESS ENTER or TAP to RETURN to TITLE SCREEN"), 120, 220, 20,
                        Raylib.DARKBLUE);
    END;
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END TitleScreen.
