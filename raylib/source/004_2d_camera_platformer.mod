(*!m2iso+gm2*)
MODULE TwoDCameraPlatformer;

FROM SYSTEM IMPORT ADR, TSIZE;
IMPORT Raylib, Raymath;

(* begin nested module *)
MODULE Detail;

FROM SYSTEM IMPORT ADR, TSIZE;
IMPORT Raylib, Raymath;

TYPE
  TPlayer = RECORD
    Position: Raylib.TVector2;
    Speed: SHORTREAL;
    CanJump: BOOLEAN;
  END;

  TEnvItem = RECORD
    Rect: Raylib.TRectangle;
    Blocking: INTEGER;
    Color: Raylib.TColor;
  END;

  TDescArray = ARRAY[0..4],[0..80] OF CHAR;
  TCameraUpdater = PROCEDURE(VAR Raylib.TCamera2D, VAR TPlayer, VAR ARRAY OF TEnvItem, INTEGER,
                             SHORTREAL, INTEGER, INTEGER);

CONST
  camera_descriptions = TDescArray{
    "Follow player center",
    "Follow player center, but clamp to map edges",
    "Follow player center; smoothed",
    "Follow player center horizontally; update player center vertically after landing",
    "Player push camera on getting too close to screen edge"
  };

PROCEDURE MinReal32(A, B: SHORTREAL): SHORTREAL;
BEGIN
  IF A > B THEN
    RETURN B;
  ELSE
    RETURN A;
  END;
END MinReal32;

PROCEDURE MaxReal32(A, B: SHORTREAL): SHORTREAL;
BEGIN
  IF A > B THEN
    RETURN A;
  ELSE
    RETURN B;
  END;
END MaxReal32;

PROCEDURE UpdatePlayer(VAR Player: TPlayer; VAR EnvItems: ARRAY OF TEnvItem;
                       EnvItemsLength: INTEGER; Delta: SHORTREAL);
CONST
  player_hor_spd = 200.0;
  player_jump_spd = 350.0;
  g = 400.0;
VAR
  I: INTEGER;
  HitObstacle: BOOLEAN;
BEGIN
  WITH Player DO
    IF Raylib.IsKeyDown(Raylib.key_left) THEN
      DEC(Position.X, player_hor_spd * Delta);
    END;
    IF Raylib.IsKeyDown(Raylib.key_right) THEN
      INC(Position.X, player_hor_spd * Delta);
    END;
    IF Raylib.IsKeyDown(Raylib.key_space) AND CanJump THEN
      Speed := -player_jump_spd;
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
          I := EnvItemsLength - 1; (* simulate break *)
        END;
      END;
    END;

    IF NOT HitObstacle THEN
      INC(Position.Y, Speed * Delta);
      INC(Speed, g * Delta);
      CanJump := FALSE;
    ELSE
      CanJump := TRUE;
    END;
  END;
END UpdatePlayer;

PROCEDURE UpdateCameraCenter(VAR Camera: Raylib.TCamera2D; VAR Player: TPlayer;
                             VAR EnvItems: ARRAY OF TEnvItem; EnvItemsLength: INTEGER;
                             Delta: SHORTREAL; Width, Height: INTEGER);
BEGIN
  WITH Camera DO
    Offset.X := VAL(SHORTREAL, Width) / 2.0;
    Offset.Y := VAL(SHORTREAL, Height) / 2.0;
    Target := Player.Position;
  END;
END UpdateCameraCenter;

PROCEDURE UpdateCameraCenterInsideMap(VAR Camera: Raylib.TCamera2D; VAR Player: TPlayer;
                                      VAR EnvItems: ARRAY OF TEnvItem; EnvItemsLength: INTEGER;
                                      Delta: SHORTREAL; Width, Height: INTEGER);
VAR
  Min, Max: Raylib.TVector2;
  MinX, MinY, MaxX, MaxY: SHORTREAL;
  I: INTEGER;
BEGIN
  WITH Camera DO
    Target := Player.Position;
    Offset.X := VAL(SHORTREAL, Width) / 2.0;
    Offset.Y := VAL(SHORTREAL, Height) / 2.0;
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
    IF Max.X < VAL(SHORTREAL, Width) THEN
      Offset.X := VAL(SHORTREAL, Width) - (Max.X - VAL(SHORTREAL, Width) / 2.0);
    END;
    IF Max.Y < VAL(SHORTREAL, Height) THEN
      Offset.Y := VAL(SHORTREAL, Height) - (Max.Y - VAL(SHORTREAL, Height) / 2.0);
    END;
    IF Min.X > 0.0 THEN
      Offset.X := VAL(SHORTREAL, Width) / 2.0 - Min.X;
    END;
    IF Min.Y > 0.0 THEN
      Offset.Y := VAL(SHORTREAL, Height) / 2.0 - Min.Y;
    END;
  END;
END UpdateCameraCenterInsideMap;

PROCEDURE UpdateCameraCenterSmoothFollow(VAR Camera: Raylib.TCamera2D; VAR Player: TPlayer;
                                         VAR EnvItems: ARRAY OF TEnvItem; EnvItemsLength: INTEGER;
                                         Delta: SHORTREAL; Width, Height: INTEGER);
CONST
  min_speed = 30.0;
  min_effect_length = 10.0;
  fraction_speed = 0.8;
VAR
  Diff: Raylib.TVector2;
  Length, Speed: SHORTREAL;
BEGIN
  Camera.Offset.X := VAL(SHORTREAL, Width) / 2.0;
  Camera.Offset.Y := VAL(SHORTREAL, Height) / 2.0;
  Diff := Raymath.Vector2Subtract(Player.Position, Camera.Target);
  Length := Raymath.Vector2Length(Diff);

  IF Length > min_effect_length THEN
    Speed := MaxReal32(fraction_speed * Length, min_speed);
    Camera.Target := Raymath.Vector2Add(Camera.Target,
                                        Raymath.Vector2Scale(Diff, Speed * Delta / Length));
  END;
END UpdateCameraCenterSmoothFollow;

PROCEDURE UpdateCameraEvenOutOnLanding(VAR Camera: Raylib.TCamera2D; VAR Player: TPlayer;
                                       VAR EnvItems: ARRAY OF TEnvItem; EnvItemsLength: INTEGER;
                                       Delta: SHORTREAL; Width, Height: INTEGER);
CONST
  even_out_speed = 700.0;
BEGIN
  WITH Camera DO
    Offset.X := VAL(SHORTREAL, Width) / 2.0;
    Offset.Y := VAL(SHORTREAL, Height) / 2.0;
    Target.X := Player.Position.X;

    IF EveningOut THEN
      IF EvenOutTarget > Target.Y THEN
        INC(Target.Y, even_out_speed * Delta);
        IF Target.Y > EvenOutTarget THEN
          Target.Y := EvenOutTarget;
          EveningOut := FALSE;
        END;
      ELSE
        DEC(Target.Y, even_out_speed * Delta);
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
                                       VAR EnvItems: ARRAY OF TEnvItem; EnvItemsLength: INTEGER;
                                       Delta: SHORTREAL; Width, Height: INTEGER);
VAR
  BBox, BBoxWorldMin, BBoxWorldMax, Tmp, Tmp2: Raylib.TVector2;
BEGIN
  BBox := Raylib.TVector2{0.2, 0.2};

  Tmp.X := (1.0 - BBox.X) * 0.5 * VAL(SHORTREAL, Width);
  Tmp.Y := (1.0 - BBox.Y) * 0.5 * VAL(SHORTREAL, Height);
  Tmp2 := Tmp;
  BBoxWorldMin := Raylib.GetScreenToWorld2D(Tmp, Camera);

  Tmp.X := (1.0 + BBox.X) * 0.5 * VAL(SHORTREAL, Width);
  Tmp.Y := (1.0 + BBox.Y) * 0.5 * VAL(SHORTREAL, Height);
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
  CameraUpdatersLength: INTEGER;
  EvenOutTarget: SHORTREAL;
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
  screen_width = 800;
  screen_height = 450;

VAR
  Player: Detail.TPlayer;
  PlayerRect: Raylib.TRectangle;
  Camera: Raylib.TCamera2D;
  EnvItems: ARRAY[0..4] OF Detail.TEnvItem;
  EnvItemsLength: INTEGER;
  CameraOption: INTEGER;
  DeltaTime: SHORTREAL;
  I: INTEGER;

BEGIN
  Raylib.InitWindow(screen_width, screen_height, "raylib [core] example - 2d camera");

  WITH Player DO
    Position := Raylib.TVector2{400, 280};
    Speed := 0.0;
    CanJump := FALSE;
  END;

  EnvItems[0] := Detail.TEnvItem{Raylib.TRectangle{0.0, 0.0, 1000.0, 400.0}, 0, Raylib.lightgray};
  EnvItems[1] := Detail.TEnvItem{Raylib.TRectangle{0.0, 400.0, 1000.0, 200.0}, 1, Raylib.gray};
  EnvItems[2] := Detail.TEnvItem{Raylib.TRectangle{300.0, 200.0, 400.0, 10.0}, 1, Raylib.gray};
  EnvItems[3] := Detail.TEnvItem{Raylib.TRectangle{250.0, 300.0, 100.0, 10.0}, 1, Raylib.gray};
  EnvItems[4] := Detail.TEnvItem{Raylib.TRectangle{650.0, 300.0, 100.0, 10.0}, 1, Raylib.gray};

  EnvItemsLength := TSIZE(EnvItems) / TSIZE(EnvItems[0]);

  WITH Camera DO
    Target := Player.Position;
    Offset := Raylib.TVector2{VAL(SHORTREAL, screen_width) / 2.0,
                              VAL(SHORTREAL, screen_height) / 2.0};
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

      IF Raylib.IsKeyPressed(Raylib.key_r) THEN
        Zoom := 1.0;
        Player.Position := Raylib.TVector2{400.0, 200.0};
      END;
    END;

    IF Raylib.IsKeyPressed(Raylib.key_c) THEN
      CameraOption := (CameraOption + 1) MOD Detail.CameraUpdatersLength;
    END;

    Detail.CameraUpdaters[CameraOption](Camera, Player, EnvItems, EnvItemsLength, DeltaTime,
                                        screen_width, screen_height);

    Raylib.BeginDrawing;
      Raylib.ClearBackground(Raylib.lightgray);

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
        Raylib.DrawRectangleRec(PlayerRect, Raylib.red);

        Raylib.DrawCircle(VAL(INTEGER, Player.Position.X), VAL(INTEGER, Player.Position.Y), 5.0,
                          Raylib.gold);
      Raylib.EndMode2D;

      Raylib.DrawText("Controls:", 20, 20, 10, Raylib.black);
      Raylib.DrawText("- Right/Left to move", 40, 40, 10, Raylib.darkgray);
      Raylib.DrawText("- Space to jump", 40, 60, 10, Raylib.darkgray);
      Raylib.DrawText("- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10,
                      Raylib.darkgray);
      Raylib.DrawText("- C to change camera mode", 40, 100, 10, Raylib.darkgray);
      Raylib.DrawText("Current camera mode:", 20, 120, 10, Raylib.black);
      Raylib.DrawText(Detail.camera_descriptions[CameraOption], 40, 140, 10, Raylib.darkgray);
    Raylib.EndDrawing;
  END;

  Raylib.CloseWindow;
END TwoDCameraPlatformer.
