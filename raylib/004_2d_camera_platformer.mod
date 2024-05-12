MODULE TwoDCameraPlatformer;

FROM SYSTEM IMPORT ADR, INTEGER32, REAL32, TSIZE;
IMPORT Raylib, Raymath;

(* begin nested module *)
MODULE Detail;

FROM SYSTEM IMPORT ADR, INTEGER32, REAL32, TSIZE;
IMPORT Raylib, Raymath;

TYPE
  TPlayer = RECORD
    Position: Raylib.TVector2;
    Speed: REAL32;
    CanJump: BOOLEAN;
  END;

  TEnvItem = RECORD
    Rect: Raylib.TRectangle;
    Blocking: INTEGER32;
    Color: Raylib.TColor;
  END;

  TDescArray = ARRAY[0..4],[0..80] OF CHAR;
  TCameraUpdater = PROCEDURE(VAR Raylib.TCamera2D, VAR TPlayer, VAR ARRAY OF TEnvItem, INTEGER32,
                             REAL32, INTEGER32, INTEGER32);

CONST
  CAMERA_DESCRIPTIONS = TDescArray{
    "Follow player center",
    "Follow player center, but clamp to map edges",
    "Follow player center; smoothed",
    "Follow player center horizontally; update player center vertically after landing",
    "Player push camera on getting too close to screen edge"
  };

PROCEDURE MinReal32(A, B: REAL32): REAL32;
BEGIN
  IF A > B THEN
    RETURN B;
  ELSE
    RETURN A;
  END;
END MinReal32;

PROCEDURE MaxReal32(A, B: REAL32): REAL32;
BEGIN
  IF A > B THEN
    RETURN A;
  ELSE
    RETURN B;
  END;
END MaxReal32;

PROCEDURE UpdatePlayer(VAR Player: TPlayer; VAR EnvItems: ARRAY OF TEnvItem;
                       EnvItemsLength: INTEGER32; Delta: REAL32);
CONST
  PLAYER_HOR_SPD = 200.0;
  PLAYER_JUMP_SPD = 350.0;
  G = 400.0;
VAR
  I: INTEGER32;
  HitObstacle: BOOLEAN;
BEGIN
  WITH Player DO
    IF Raylib.IsKeyDown(Raylib.KEY_LEFT) THEN
      DEC(Position.X, PLAYER_HOR_SPD * Delta);
    END;
    IF Raylib.IsKeyDown(Raylib.KEY_RIGHT) THEN
      INC(Position.X, PLAYER_HOR_SPD * Delta);
    END;
    IF Raylib.IsKeyDown(Raylib.KEY_SPACE) AND CanJump THEN
      Speed := -PLAYER_JUMP_SPD;
      CanJump := FALSE;
    END;

    HitObstacle := FALSE;
    FOR I := 0 TO (EnvItemsLength - 1) DO
      WITH EnvItems[I] DO
        IF (Blocking <> 0) AND (Rect.X <= Position.X) AND ((Rect.X + Rect.Width) >= Position.X) AND
           (Rect.Y >= Position.Y) AND (Rect.Y <= (Position.Y + Speed * Delta))
        THEN
          HitObstacle := TRUE;
          Speed := 0.0;
          Position.Y := Rect.Y;
          I := EnvItemsLength - 1; (* having a working EXIT/BREAK here would be nice *)
        END;
      END;
    END;

    IF NOT HitObstacle THEN
      INC(Position.Y, Speed * Delta);
      INC(Speed, G * Delta);
      CanJump := FALSE;
    ELSE
      CanJump := TRUE;
    END;
  END;
END UpdatePlayer;

PROCEDURE UpdateCameraCenter(VAR Camera: Raylib.TCamera2D; VAR Player: TPlayer;
                             VAR EnvItems: ARRAY OF TEnvItem; EnvItemsLength: INTEGER32;
                             Delta: REAL32; Width, Height: INTEGER32);
BEGIN
  WITH Camera DO
    Offset.X := VAL(REAL32, Width) / 2.0;
    Offset.Y := VAL(REAL32, Height) / 2.0;
    Target := Player.Position;
  END;
END UpdateCameraCenter;

PROCEDURE UpdateCameraCenterInsideMap(VAR Camera: Raylib.TCamera2D; VAR Player: TPlayer;
                                      VAR EnvItems: ARRAY OF TEnvItem; EnvItemsLength: INTEGER32;
                                      Delta: REAL32; Width, Height: INTEGER32);
VAR
  Min, Max: Raylib.TVector2;
  MinX, MinY, MaxX, MaxY: REAL32;
  I: INTEGER32;
BEGIN
  WITH Camera DO
    Target := Player.Position;
    Offset.X := VAL(REAL32, Width) / 2.0;
    Offset.Y := VAL(REAL32, Height) / 2.0;
  END;

  MinX := 1000.0;
  MinY := 1000.0;
  MaxX := -1000.0;
  MaxY := -1000.0;

  FOR I := 0 TO (EnvItemsLength - 1) DO
    WITH EnvItems[I] DO
      MinX := MinReal32(Rect.X, MinX);
      MaxX := MaxReal32(Rect.X + Rect.Width, MaxX);
      MinY := MinReal32(Rect.Y, MinY);
      MaxY := MaxReal32(Rect.Y + Rect.Height, MaxY);
    END;
  END;

  Max := Raylib.GetWorldToScreen2D(Raylib.TVector2{MaxX, MaxY}, Camera);
  Min := Raylib.GetWorldToScreen2D(Raylib.TVector2{MinX, MinY}, Camera);

  WITH Camera DO
    IF Max.X < VAL(REAL32, Width) THEN
      Offset.X := VAL(REAL32, Width) - (Max.X - VAL(REAL32, Width) / 2.0);
    END;
    IF Max.Y < VAL(REAL32, Height) THEN
      Offset.Y := VAL(REAL32, Height) - (Max.Y - VAL(REAL32, Height) / 2.0);
    END;
    IF Min.X > 0.0 THEN
      Offset.X := VAL(REAL32, Width) / 2.0 - Min.X;
    END;
    IF Min.Y > 0.0 THEN
      Offset.Y := VAL(REAL32, Height) / 2.0 - Min.Y;
    END;
  END;
END UpdateCameraCenterInsideMap;

PROCEDURE UpdateCameraCenterSmoothFollow(VAR Camera: Raylib.TCamera2D; VAR Player: TPlayer;
                                         VAR EnvItems: ARRAY OF TEnvItem;
                                         EnvItemsLength: INTEGER32; Delta: REAL32;
                                         Width, Height: INTEGER32);
CONST
  MIN_SPEED = 30.0;
  MIN_EFFECT_LENGTH = 10.0;
  FRACTION_SPEED = 0.8;
VAR
  Diff: Raylib.TVector2;
  Length, Speed: REAL32;
BEGIN
  Camera.Offset.X := VAL(REAL32, Width) / 2.0;
  Camera.Offset.Y := VAL(REAL32, Height) / 2.0;
  Diff := Raymath.Vector2Subtract(Player.Position, Camera.Target);
  Length := Raymath.Vector2Length(Diff);

  IF Length > MIN_EFFECT_LENGTH THEN
    Speed := MaxReal32(FRACTION_SPEED * Length, MIN_SPEED);
    Camera.Target := Raymath.Vector2Add(Camera.Target,
                                        Raymath.Vector2Scale(Diff, Speed * Delta / Length));
  END;
END UpdateCameraCenterSmoothFollow;

PROCEDURE UpdateCameraEvenOutOnLanding(VAR Camera: Raylib.TCamera2D; VAR Player: TPlayer;
                                       VAR EnvItems: ARRAY OF TEnvItem; EnvItemsLength: INTEGER32;
                                       Delta: REAL32; Width, Height: INTEGER32);
CONST
  EVEN_OUT_SPEED = 700.0;
BEGIN
  WITH Camera DO
    Offset.X := VAL(REAL32, Width) / 2.0;
    Offset.Y := VAL(REAL32, Height) / 2.0;
    Target.X := Player.Position.X;

    IF EveningOut THEN
      IF EvenOutTarget > Target.Y THEN
        INC(Target.Y, EVEN_OUT_SPEED * Delta);
        IF Target.Y > EvenOutTarget THEN
          Target.Y := EvenOutTarget;
          EveningOut := FALSE;
        END;
      ELSE
        DEC(Target.Y, EVEN_OUT_SPEED * Delta);
        IF Target.Y < EvenOutTarget THEN
          Target.Y := EvenOutTarget;
          EveningOut := FALSE;
        END;
      END;
    ELSE
      WITH Player DO
        IF CanJump AND (Speed = 0.0) AND (Position.Y <> Target.Y) THEN
          EveningOut := TRUE;
          EvenOutTarget := Position.Y;
        END;
      END;
    END;
  END;
END UpdateCameraEvenOutOnLanding;

PROCEDURE UpdateCameraPlayerBoundsPush(VAR Camera: Raylib.TCamera2D; VAR Player: TPlayer;
                                       VAR EnvItems: ARRAY OF TEnvItem; EnvItemsLength: INTEGER32;
                                       Delta: REAL32; Width, Height: INTEGER32);
VAR
  BBox, BBoxWorldMin, BBoxWorldMax, Tmp, Tmp2: Raylib.TVector2;
BEGIN
  BBox := Raylib.TVector2{0.2, 0.2};

  Tmp.X := (1.0 - BBox.X) * 0.5 * VAL(REAL32, Width);
  Tmp.Y := (1.0 - BBox.Y) * 0.5 * VAL(REAL32, Height);
  Tmp2 := Tmp;
  BBoxWorldMin := Raylib.GetScreenToWorld2D(Tmp, Camera);

  Tmp.X := (1.0 + BBox.X) * 0.5 * VAL(REAL32, Width);
  Tmp.Y := (1.0 + BBox.Y) * 0.5 * VAL(REAL32, Height);
  BBoxWorldMax := Raylib.GetScreenToWorld2D(Tmp, Camera);

  Camera.Offset := Tmp2;

  WITH Player DO
    IF Position.X < BBoxWorldMin.X THEN
      Camera.Target.X := Position.X;
    END;
    IF Position.Y < BBoxWorldMin.Y THEN
      Camera.Target.Y := Position.Y;
    END;
    IF Position.X > BBoxWorldMax.X THEN
      Camera.Target.X := BBoxWorldMin.X + Position.X - BBoxWorldMax.X;
    END;
    IF Position.Y > BBoxWorldMax.Y THEN
      Camera.Target.Y := BBoxWorldMin.Y + Position.Y - BBoxWorldMax.Y;
    END;
  END;
END UpdateCameraPlayerBoundsPush;

VAR
  CameraUpdaters: ARRAY[0..4] OF TCameraUpdater;
  CameraUpdatersLength: INTEGER32;
  EvenOutTarget: REAL32;
  EveningOut: BOOLEAN;

BEGIN
  CameraUpdaters[0] := ADR(UpdateCameraCenter);
  CameraUpdaters[1] := ADR(UpdateCameraCenterInsideMap);
  CameraUpdaters[2] := ADR(UpdateCameraCenterSmoothFollow);
  CameraUpdaters[3] := ADR(UpdateCameraEvenOutOnLanding);
  CameraUpdaters[4] := ADR(UpdateCameraPlayerBoundsPush);

  CameraUpdatersLength := TSIZE(CameraUpdaters) / TSIZE(CameraUpdaters[0]);

  EvenOutTarget := 0.0;
  EveningOut := FALSE;
END Detail;
(* end nested module *)

CONST
  SCREEN_WIDTH = 800;
  SCREEN_HEIGHT = 450;

VAR
  Player: Detail.TPlayer;
  PlayerRect: Raylib.TRectangle;
  Camera: Raylib.TCamera2D;
  EnvItems: ARRAY[0..4] OF Detail.TEnvItem;
  EnvItemsLength: INTEGER32;
  CameraOption: INTEGER32;
  DeltaTime: REAL32;
  I: INTEGER32;

BEGIN
  Raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - 2d camera");

  WITH Player DO
    Position := Raylib.TVector2{400, 280};
    Speed := 0.0;
    CanJump := FALSE;
  END;

  EnvItems[0] := Detail.TEnvItem{Raylib.TRectangle{0.0, 0.0, 1000.0, 400.0}, 0, Raylib.LIGHTGRAY};
  EnvItems[1] := Detail.TEnvItem{Raylib.TRectangle{0.0, 400.0, 1000.0, 200.0}, 1, Raylib.GRAY};
  EnvItems[2] := Detail.TEnvItem{Raylib.TRectangle{300.0, 200.0, 400.0, 10.0}, 1, Raylib.GRAY};
  EnvItems[3] := Detail.TEnvItem{Raylib.TRectangle{250.0, 300.0, 100.0, 10.0}, 1, Raylib.GRAY};
  EnvItems[4] := Detail.TEnvItem{Raylib.TRectangle{650.0, 300.0, 100.0, 10.0}, 1, Raylib.GRAY};

  EnvItemsLength := TSIZE(EnvItems) / TSIZE(EnvItems[0]);

  WITH Camera DO
    Target := Player.Position;
    Offset := Raylib.TVector2{VAL(REAL32, SCREEN_WIDTH) / 2.0, VAL(REAL32, SCREEN_HEIGHT) / 2.0};
    Rotation := 0.0;
    Zoom := 1.0;
  END;

  Raylib.SetTargetFPS(60);

  WHILE NOT Raylib.WindowShouldClose() DO
    DeltaTime := Raylib.GetFrameTime();
    Detail.UpdatePlayer(Player, EnvItems, EnvItemsLength, DeltaTime);

    WITH Camera DO
      INC(Zoom, Raylib.GetMouseWheelMove() * 0.05);

      IF Zoom > 3.0 THEN
        Zoom := 3.0;
      ELSIF Zoom < 0.25 THEN
        Zoom := 0.25;
      END;

      IF Raylib.IsKeyPressed(Raylib.KEY_R) THEN
        Zoom := 1.0;
        Player.Position := Raylib.TVector2{400.0, 200.0};
      END;
    END;

    IF Raylib.IsKeyPressed(Raylib.KEY_C) THEN
      CameraOption := (CameraOption + 1) MOD Detail.CameraUpdatersLength;
    END;

    Detail.CameraUpdaters[CameraOption](Camera, Player, EnvItems, EnvItemsLength, DeltaTime,
                                        SCREEN_WIDTH, SCREEN_HEIGHT);

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.LIGHTGRAY);

      Raylib.BeginMode2D(Camera);
        FOR I := 0 TO (EnvItemsLength - 1) DO
          Raylib.DrawRectangleRec(EnvItems[I].Rect, EnvItems[I].Color);
        END;

        WITH PlayerRect DO
          X := Player.Position.X - 20.0;
          Y := Player.Position.Y - 40.0;
          Width := 40.0;
          Height := 40.0;
        END;
        Raylib.DrawRectangleRec(PlayerRect, Raylib.RED);

        Raylib.DrawCircle(VAL(INTEGER32, Player.Position.X), VAL(INTEGER32, Player.Position.Y),
                          5.0, Raylib.GOLD);
      Raylib.EndMode2D;

      Raylib.DrawText(ADR("Controls:"), 20, 20, 10, Raylib.BLACK);
      Raylib.DrawText(ADR("- Right/Left to move"), 40, 40, 10, Raylib.DARKGRAY);
      Raylib.DrawText(ADR("- Space to jump"), 40, 60, 10, Raylib.DARKGRAY);
      Raylib.DrawText(ADR("- Mouse Wheel to Zoom in-out, R to reset zoom"), 40, 80, 10,
                      Raylib.DARKGRAY);
      Raylib.DrawText(ADR("- C to change camera mode"), 40, 100, 10, Raylib.DARKGRAY);
      Raylib.DrawText(ADR("Current camera mode:"), 20, 120, 10, Raylib.BLACK);
      Raylib.DrawText(ADR(Detail.CAMERA_DESCRIPTIONS[CameraOption]), 40, 140, 10, Raylib.DARKGRAY);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END TwoDCameraPlatformer.
