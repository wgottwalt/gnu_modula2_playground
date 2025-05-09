(*!m2iso+gm2*)
MODULE AutomationEvents;

FROM SYSTEM IMPORT TSIZE;
IMPORT Raylib;

TYPE
  TPlayer = RECORD
    Position: Raylib.TVector2;
    Speed: SHORTREAL;
    CanJump: BOOLEAN;
  END;

  TEnvElement = RECORD
    Rect: Raylib.TRectangle;
    Blocking: INTEGER;
    Color: Raylib.TColor;
  END;

CONST
  screen_width = 800;
  screen_height = 450;
  gravity = 400;
  player_jump_spd = 350.0;
  player_hor_spd = 200.0;
  max_environment_elements = 5;

VAR
  Buffer: POINTER TO ARRAY[0..(Raylib.max_text_buffer_length - 1)] OF CHAR;
  EnvElements: ARRAY[0..(max_environment_elements - 1)] OF TEnvElement;
  Camera: Raylib.TCamera2D;
  TempRec: Raylib.TRectangle;
  Player: TPlayer;
  Max, Min: Raylib.TVector2;
  AEList: Raylib.TAutomationEventList;
  DroppedFiles: Raylib.TFilePathList;
  AutomationEventPtr: Raylib.PAutomationEvent;
  DeltaTime, MinX, MinY, MaxX, MaxY: SHORTREAL;
  FrameCounter, PlayFrameCounter, CurrentPlayFrame: CARDINAL;
  HitObstacle, I: INTEGER;
  EventRecording, EventPlaying: BOOLEAN;

PROCEDURE FMinF(A, B: SHORTREAL): SHORTREAL;
BEGIN
  IF A < B THEN
    RETURN A;
  ELSE
    RETURN B;
  END;
END FMinF;

PROCEDURE FMaxF(A, B: SHORTREAL): SHORTREAL;
BEGIN
  IF A > B THEN
    RETURN A;
  ELSE
    RETURN B;
  END;
END FMaxF;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - automation events");

  Player := TPlayer{{400.0, 280.0}, 0.0, FALSE};

  EnvElements[0] := TEnvElement{{0.0, 0.0, 1000.0, 400.0}, 0, Raylib.lightgray};
  EnvElements[1] := TEnvElement{{0.0, 400.0, 1000.0, 200.0}, 1, Raylib.gray};
  EnvElements[2] := TEnvElement{{300.0, 200.0, 400.0, 10.0}, 1, Raylib.gray};
  EnvElements[3] := TEnvElement{{250.0, 300.0, 100.0, 10.0}, 1, Raylib.gray};
  EnvElements[4] := TEnvElement{{650.0, 300.0, 100.0, 10.0}, 1, Raylib.gray};

  WITH Camera DO
    Offset := Raylib.TVector2{VAL(SHORTREAL, screen_width) / 2.0,
                              VAL(SHORTREAL, screen_height) / 2.0};
    Target := Player.Position;
    Rotation := 0.0;
    Zoom := 1.0;
  END;

  AEList := Raylib.LoadAutomationEventList("");
  Raylib.SetAutomationEventList(AEList);

  EventRecording := FALSE;
  EventPlaying := FALSE;

  FrameCounter := 0;
  PlayFrameCounter := 0;
  CurrentPlayFrame := 0;

  Raylib.SetTargetFPS(60);
  WHILE NOT Raylib.WindowShouldClose() DO
    DeltaTime := 0.015;

    (* dropped files logic *)
    IF Raylib.IsFileDropped() THEN
      DroppedFiles := Raylib.LoadDroppedFiles();
      Buffer := DroppedFiles.Paths;

      IF Raylib.IsFileExtension(Buffer^, ".txt;.rae") THEN
        Raylib.UnloadAutomationEventList(AEList);
        AEList := Raylib.LoadAutomationEventList(Buffer^);

        EventRecording := FALSE;

        EventPlaying := TRUE;
        PlayFrameCounter := 0;
        CurrentPlayFrame := 0;

        WITH Player DO
          Position := Raylib.TVector2{400.0, 280.0};
          Speed := 0.0;
          CanJump := FALSE;

          WITH Camera DO
            Target := Position;
            Offset := Raylib.TVector2{VAL(SHORTREAL, screen_width) / 2.0,
                                      VAL(SHORTREAL, screen_height) / 2.0};
            Rotation := 0.0;
            Zoom := 1.0;
          END;
        END;
      END;

      Raylib.UnloadDroppedFiles(DroppedFiles);
    END;

    (* update player *)
    WITH Player DO
      IF Raylib.IsKeyDown(Raylib.key_left) THEN
        DEC(Position.X, player_hor_spd * DeltaTime);
      END;
      IF Raylib.IsKeyDown(Raylib.key_right) THEN
        INC(Position.X, player_hor_spd * DeltaTime);
      END;
      IF (Raylib.IsKeyDown(Raylib.key_space) AND CanJump) THEN
        Speed := -player_jump_spd;
        CanJump := FALSE;
      END;

      HitObstacle := 0;
      FOR I := 0 TO (max_environment_elements - 1) DO
        WITH EnvElements[I] DO
          IF ((Blocking # 0) AND (Rect.X <= Position.X) AND
              ((Rect.X + Rect.Width) >= Position.X) AND (Rect.Y >= Position.Y) AND
              (Rect.Y <= (Position.Y + Speed * DeltaTime)))
          THEN
            HitObstacle := 1;
            Speed := 0.0;
            Position.Y := Rect.Y;
          END;
        END;
      END;

      IF (HitObstacle = 0) THEN
        INC(Position.Y, Speed * DeltaTime);
        INC(Speed, VAL(SHORTREAL, gravity) * DeltaTime);
        CanJump := FALSE;
      ELSE
        CanJump := TRUE;
      END;

      IF Raylib.IsKeyPressed(Raylib.key_r) THEN
        Position := Raylib.TVector2{400.0, 280.0};
        Speed := 0.0;
        CanJump := FALSE;

        WITH Camera DO
          Target := Position;
          Offset := Raylib.TVector2{VAL(SHORTREAL, screen_width) / 2.0,
                                    VAL(SHORTREAL, screen_height) / 2.0};
          Rotation := 0.0;
          Zoom := 1.0;
        END;
      END;
    END;

    (* events playing *)
    IF EventPlaying THEN
      AutomationEventPtr := AEList.Events;
      INC(AutomationEventPtr, CurrentPlayFrame * TSIZE(Raylib.TAutomationEvent));

      LOOP
        IF PlayFrameCounter # AutomationEventPtr^.Frame THEN
          EXIT;
        END;

        Raylib.PlayAutomationEvent(AutomationEventPtr^);
        INC(CurrentPlayFrame);

        IF CurrentPlayFrame = AEList.Count THEN
          EventPlaying := FALSE;
          CurrentPlayFrame := 0;
          PlayFrameCounter := 0;

          Raylib.TraceLog(Raylib.log_info, "FINISH PLAYING!");
          EXIT;
        END;

        AutomationEventPtr := AEList.Events;
        INC(AutomationEventPtr, CurrentPlayFrame * TSIZE(Raylib.TAutomationEvent));
      END;

      INC(PlayFrameCounter);
    END;

    (* update camera *)
    WITH Camera DO
      Target := Player.Position;
      Offset := Raylib.TVector2{VAL(SHORTREAL, screen_width) / 2.0,
                                VAL(SHORTREAL, screen_height) / 2.0};

      INC(Zoom, Raylib.GetMouseWheelMove() * 0.05);
      IF Zoom > 3.0 THEN
        Zoom := 3.0;
      ELSIF Zoom < 0.25 THEN
        Zoom := 0.25;
      END;
    END;

    MinX := 1000.0;
    MinY := 1000.0;
    MaxX := 1000.0;
    MaxY := 1000.0;
    FOR I := 0 TO (max_environment_elements - 1) DO
      WITH EnvElements[I] DO
        MinX := FMinF(Rect.X, MinX);
        MaxX := FMaxF(Rect.X + Rect.Width, MaxX);
        MinY := FMinF(Rect.Y, MinY);
        MaxY := FMaxF(Rect.Y + Rect.Height, MaxY);
      END;
    END;

    Max := Raylib.GetWorldToScreen2D(Raylib.TVector2{MaxX, MaxY}, Camera);
    Min := Raylib.GetWorldToScreen2D(Raylib.TVector2{MinX, MinY}, Camera);

    WITH Camera DO
      IF Max.X < VAL(SHORTREAL, screen_width) THEN
        Offset.X := VAL(SHORTREAL, screen_width) - (Max.X - VAL(SHORTREAL, screen_width) / 2.0);
      END;
      IF Max.Y < VAL(SHORTREAL, screen_height) THEN
        Offset.Y := VAL(SHORTREAL, screen_height) - (Max.Y - VAL(SHORTREAL, screen_height) / 2.0);
      END;
      IF Min.X > 0.0 THEN
        Offset.X := VAL(SHORTREAL, screen_width) / 2.0 - Min.X;
      END;
      IF Min.Y > 0.0 THEN
        Offset.Y := VAL(SHORTREAL, screen_height) / 2.0 - Min.Y;
      END;
    END;

    (* events management *)
    IF Raylib.IsKeyPressed(Raylib.key_s) THEN
      IF NOT EventPlaying THEN
        IF EventRecording THEN
          Raylib.StopAutomationEventRecording;
          EventRecording := FALSE;

          IF Raylib.ExportAutomationEventList(AEList, "automation.rae") THEN
            Raylib.TraceLog(Raylib.log_info, "RECORDED FRAMES: %i", AEList.Count);
          END;
        ELSE
          Raylib.SetAutomationEventBaseFrame(180);
          Raylib.StartAutomationEventRecording;
          EventRecording := TRUE;
        END;
      END;
    ELSIF Raylib.IsKeyPressed(Raylib.key_a) THEN
      IF (NOT EventRecording AND (AEList.Count > 0)) THEN
        EventPlaying := TRUE;
        PlayFrameCounter := 0;
        CurrentPlayFrame := 0;

        WITH Player DO
          Position := Raylib.TVector2{400.0, 280.0};
          Speed := 0.0;
          CanJump := FALSE;
        END;

        WITH Camera DO
          Target := Player.Position;
          Offset := Raylib.TVector2{VAL(SHORTREAL, screen_width) / 2.0,
                                    VAL(SHORTREAL, screen_height) / 2.0};
          Rotation := 0.0;
          Zoom := 1.0;
        END;
      END;
    END;

    IF (EventRecording OR EventPlaying) THEN
      INC(FrameCounter);
    ELSE
      FrameCounter := 0;
    END;

    (* drawing *)
    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.lightgray);

      Raylib.BeginMode2D(Camera);
        FOR I := 0 TO (max_environment_elements - 1) DO
          Raylib.DrawRectangleRec(EnvElements[I].Rect, EnvElements[I].Color);
        END;

        WITH TempRec DO
          X := Player.Position.X - 20.0;
          Y := Player.Position.Y - 40.0;
          Width := 40.0;
          Height := 40.0;
        END;
        Raylib.DrawRectangleRec(TempRec, Raylib.red);
      Raylib.EndMode2D;

      Raylib.DrawRectangle(10, 10, 290, 145, Raylib.Fade(Raylib.skyblue, 0.5));
      Raylib.DrawRectangleLines(10, 10, 290, 145, Raylib.Fade(Raylib.blue, 0.8));

      Raylib.DrawText("Controls:", 20, 20, 10, Raylib.black);
      Raylib.DrawText("- RIGHT | LEFT: Player movement", 30, 40, 10, Raylib.darkgray);
      Raylib.DrawText("- SPACE: Player jump", 30, 60, 10, Raylib.darkgray);
      Raylib.DrawText("- R: Reset game state", 30, 80, 10, Raylib.darkgray);
      Raylib.DrawText("- S: START/STOP RECORDING INPUT EVENTS", 30, 110, 10, Raylib.black);
      Raylib.DrawText("- A: REPLAY LAST RECORDED INPUT EVENTS", 30, 130, 10, Raylib.black);

      IF EventRecording THEN
        Raylib.DrawRectangle(10, 160, 290, 30, Raylib.Fade(Raylib.red, 0.3));
        Raylib.DrawRectangleLines(10, 160, 290, 30, Raylib.Fade(Raylib.maroon, 0.8));
        Raylib.DrawCircle(30, 175, 10.0, Raylib.maroon);

        IF ((FrameCounter / 15) MOD 2) = 1 THEN
          Buffer := Raylib.TextFormat("RECORDING EVENTS... [%i]", AEList.Count);
          Raylib.DrawText(Buffer^, 50, 170, 10, Raylib.maroon);
        END;
      ELSIF EventPlaying THEN
        Raylib.DrawRectangle(10, 160, 290, 30, Raylib.Fade(Raylib.lime, 0.3));
        Raylib.DrawRectangleLines(10, 160, 290, 30, Raylib.Fade(Raylib.darkgreen, 0.8));
        Raylib.DrawTriangle(Raylib.TVector2{20.0, 155.0 + 10.0},
                            Raylib.TVector2{20.0, 155.0 + 30.0},
                            Raylib.TVector2{40.0, 155.0 + 20.0}, Raylib.darkgreen);

        IF ((FrameCounter / 15) MOD 2) = 1 THEN
          Buffer := Raylib.TextFormat("PLAYING RECORDED EVENTS... [%i]", CurrentPlayFrame);
          Raylib.DrawText(Buffer^, 50, 170, 10, Raylib.darkgreen);
        END;
      END;
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END AutomationEvents.
