(*!m2iso*)
IMPLEMENTATION MODULE Field;

IMPORT C, StopWatch;
FROM Random IMPORT Randomize, RandomCard;
FROM SYSTEM IMPORT ADDRESS, TSIZE;

TYPE
  PField = POINTER TO TField;

  TField = RECORD
    StepTime: StopWatch.PStopWatch;
    Data: ADDRESS;
    DataNext: ADDRESS;
    Width: CARDINAL;
    Height: CARDINAL;
    Steps: CARDINAL;
    Delay: CARDINAL;
    AliveSymbol: CHAR;
    DeadSymbol: CHAR;
    BorderSymbol: CHAR;
    Measure: BOOLEAN;
  END;

(* internal *)

PROCEDURE CountCells(Field: PField; VAR Alive, Dead: CARDINAL);
VAR
  Ptr: POINTER TO CHAR;
  X, Y: CARDINAL;
BEGIN
  Alive := 0;
  Dead := 0;

  FOR Y := 1 TO (Field^.Height - 2) DO
    Ptr := Field^.Data;
    INC(Ptr, Y * Field^.Width + 1);

    FOR X := 1 TO (Field^.Width - 2) DO
      IF Ptr^ = Field^.AliveSymbol THEN
        INC(Alive);
      ELSIF Ptr^ = Field^.DeadSymbol THEN
        INC(Dead);
      END;

      INC(Ptr);
    END;
  END;
END CountCells;

PROCEDURE SetSymbol(VAR Field: PField; Symbol: CHAR; Alive: BOOLEAN): BOOLEAN;
VAR
  Ptr: POINTER TO CHAR;
  I: CARDINAL;
BEGIN
  IF (Field # NIL) AND (Field^.Data # NIL) AND (Field^.AliveSymbol # Symbol) AND
      (Field^.DeadSymbol # Symbol)
  THEN
    Ptr := Field^.Data;
    FOR I := 1 TO (Field^.Width * Field^.Height) DO
      IF Alive THEN
        IF Ptr^ = Field^.AliveSymbol THEN
          Ptr^ := Symbol;
        END;
      ELSE
        IF Ptr^ = Field^.DeadSymbol THEN
          Ptr^ := Symbol;
        END;
      END;
      INC(Ptr);
    END;

    IF Alive THEN
      Field^.AliveSymbol := Symbol;
    ELSE
      Field^.DeadSymbol := Symbol;
    END;

    RETURN TRUE;
  END;

  RETURN FALSE;
END SetSymbol;

(* exported *)

PROCEDURE Init(VAR Field: PField; Width, Height: CARDINAL; [Random: BOOLEAN = FALSE]): [BOOLEAN];
VAR
  Tmp: PField;
  Ptr: POINTER TO CHAR;
  I, X, Y: CARDINAL;
BEGIN
  IF (Field = NIL) AND (Width > 0) AND (Width <= maxWidth) AND (Height > 0) AND
     (Height <= maxHeight)
  THEN
    Field := C.malloc(TSIZE(TField));
    IF Field # NIL THEN
      Field^.StepTime := NIL;
      Field^.Data := NIL;
      Field^.DataNext := NIL;

      INC(Width, 2);
      INC(Height, 2);

      StopWatch.Init(Field^.StepTime);
      Field^.Data := C.malloc(Width * Height);
      Field^.DataNext := C.malloc(Width * Height);

      IF (Field^.Data # NIL) AND (Field^.DataNext # NIL) THEN
        Field^.Width := Width;
        Field^.Height := Height;
        Field^.Steps := 0;
        Field^.Delay := defDelayMS;
        Field^.AliveSymbol := defAliveSymbol;
        Field^.DeadSymbol := defDeadSymbol;
        Field^.BorderSymbol := defBorderSymbol;
        Field^.Measure := FALSE;

        Ptr := Field^.Data;
        FOR I := 1 TO (Field^.Width * Field^.Height) DO
          Ptr^ := Field^.DeadSymbol;
          INC(Ptr);
        END;

        IF Random THEN
          FOR Y := 1 TO (Field^.Height - 2) DO
            Ptr := Field^.Data;
            INC(Ptr, Y * Field^.Width + 1);

            FOR X := 1 TO (Field^.Width - 2) DO
              IF RandomCard(3) = 2 THEN
                Ptr^ := Field^.AliveSymbol;
              END;
              INC(Ptr);
            END;
          END;
        END;

        RETURN TRUE;
      ELSE
        IF Field^.StepTime # NIL THEN
          StopWatch.Destroy(Field^.StepTime);
        END;
        IF Field^.Data # NIL THEN
          C.free(Field^.Data);
        END;
        IF Field^.DataNext # NIL THEN
          C.free(Field^.DataNext);
        END;

        C.free(Field);
        Field := NIL;
      END;
    END;
  END;

  RETURN FALSE;
END Init;

PROCEDURE Destroy(VAR Field: PField): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    IF Field^.StepTime # NIL THEN
      StopWatch.Destroy(Field^.StepTime);
    END;
    IF Field^.Data # NIL THEN
      C.free(Field^.Data);
    END;
    IF Field^.DataNext # NIL THEN
      C.free(Field^.DataNext);
    END;

    C.free(Field);
    Field := NIL;

    RETURN TRUE;
  END;

  RETURN FALSE;
END Destroy;

(* --- *)

PROCEDURE Width(Field: PField; VAR Width: CARDINAL): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    Width := Field^.Width - 2;

    RETURN TRUE;
  END;

  RETURN FALSE;
END Width;

PROCEDURE Height(Field: PField; VAR Height: CARDINAL): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    Height := Field^.Height - 2;

    RETURN TRUE;
  END;

  RETURN FALSE;
END Height;

PROCEDURE Steps(Field: PField; VAR Steps: CARDINAL): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    Steps := Field^.Steps;

    RETURN TRUE;
  END;

  RETURN FALSE;
END Steps;

PROCEDURE CycleDelayMs(Field: PField; VAR Delay: CARDINAL): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    Delay := Field^.Delay;

    RETURN TRUE;
  END;

  RETURN FALSE;
END CycleDelayMs;

PROCEDURE AliveSymbol(Field: PField; VAR Symbol: CHAR): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    Symbol := Field^.AliveSymbol;

    RETURN TRUE;
  END;

  RETURN FALSE;
END AliveSymbol;

PROCEDURE DeadSymbol(Field: PField; VAR Symbol: CHAR): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    Symbol := Field^.DeadSymbol;

    RETURN TRUE;
  END;

  RETURN FALSE;
END DeadSymbol;

PROCEDURE BorderSymbol(Field: PField; VAR Symbol: CHAR): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    Symbol := Field^.BorderSymbol;

    RETURN TRUE;
  END;

  RETURN FALSE;
END BorderSymbol;

PROCEDURE PerfMeasuring(Field: PField; VAR Measure: BOOLEAN): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    Measure := Field^.Measure;

    RETURN TRUE;
  END;

  RETURN FALSE;
END PerfMeasuring;

PROCEDURE PerfInNanoSeconds(Field: PField; VAR Ns: LONGCARD): [BOOLEAN];
VAR
  Tmp: LONGCARD;
BEGIN
  IF (Field # NIL) AND StopWatch.DiffInNanoSeconds(Field^.StepTime, Tmp) THEN
    Ns := Tmp;

    RETURN TRUE;
  END;

  RETURN FALSE;
END PerfInNanoSeconds;

PROCEDURE CellsAlive(Field: PField; VAR Alive: CARDINAL): [BOOLEAN];
VAR
  Tmp: CARDINAL;
BEGIN
  IF (Field # NIL) AND (Field^.Data # NIL) THEN
    CountCells(Field, Alive, Tmp);

    RETURN TRUE;
  END;

  RETURN FALSE;
END CellsAlive;

PROCEDURE CellsDead(Field: PField; VAR Dead: CARDINAL): [BOOLEAN];
VAR
  Tmp: CARDINAL;
BEGIN
  IF (Field # NIL) AND (Field^.Data # NIL) THEN
    CountCells(Field, Tmp, Dead);

    RETURN TRUE;
  END;

  RETURN FALSE;
END CellsDead;

PROCEDURE Cell(Field: PField; X, Y: CARDINAL; VAR Cell: BOOLEAN): [BOOLEAN];
VAR
  Ptr: POINTER TO CHAR;
BEGIN
  IF (Field # NIL) AND (Field^.Data # NIL) AND (X < (Field^.Width - 2)) AND
      (Y < (Field^.Height - 2))
  THEN
    Ptr := Field^.Data;
    INC(Ptr, (Y + 1) * Field^.Width + X + 1);

    IF Ptr^ = Field^.AliveSymbol THEN
      Cell := TRUE;
    ELSE
      Cell := FALSE;
    END;

    RETURN TRUE;
  END;

  RETURN FALSE;
END Cell;

PROCEDURE Print(Field: PField; [Display: TDisplaySet = TDisplaySet{field}]): [BOOLEAN];
VAR
  Ptr: POINTER TO CHAR;
  Diff: LONGCARD;
  Alive, Dead: CARDINAL;
  I, J: CARDINAL;
BEGIN
  IF (Field # NIL) AND (Field^.Data # NIL) THEN
    IF header IN Display THEN
      CellsAlive(Field, Alive);
      CellsDead(Field, Dead);

      IF Field^.Measure THEN
        IF NOT StopWatch.DiffInNanoSeconds(Field^.StepTime, Diff) THEN
          C.printf("%ux%u alive:%05u dead:%05u steps:%08u\n", Field^.Width - 2, Field^.Height - 2,
                   Alive, Dead, Field^.Steps);
        ELSE
          C.printf("%ux%u alive:%05u dead:%05u steps:%08u steptime:%010luns\n", Field^.Width - 2,
                   Field^.Height - 2, Alive, Dead, Field^.Steps, Diff);
        END;
      ELSE
        C.printf("%ux%u alive:%05u dead:%05u steps:%08u\n", Field^.Width - 2, Field^.Height - 2,
                 Alive, Dead, Field^.Steps);
      END;
    END;

    IF border IN Display THEN
      Ptr := Field^.Data;
      FOR I := 1 TO Field^.Width DO
        C.printf("%c", Field^.BorderSymbol);
      END;
      C.printf("\n");
    END;

    IF (field IN Display) AND (border IN Display) THEN
      INC(Ptr, Field^.Width + 1);
      FOR I := 1 TO (Field^.Height - 2) DO
        C.printf("%c%.*s%c\n", Field^.BorderSymbol, Field^.Width - 2, Ptr, Field^.BorderSymbol);
        INC(Ptr, Field^.Width);
      END;
    ELSIF (field IN Display) AND NOT (border IN Display) THEN
      Ptr := Field^.Data;
      FOR I := 1 TO (Field^.Height - 2) DO
        C.printf("%.*s\n", Field^.Width - 2, Ptr);
        INC(Ptr, Field^.Width);
      END;
    ELSIF NOT (field IN Display) AND (border IN Display) THEN
      FOR I := 1 TO (Field^.Height - 2) DO
        C.putchar(ORD(Field^.BorderSymbol));
        FOR J := 1 TO (Field^.Width - 2) DO
          C.putchar(ORD(' '));
        END;
        C.printf("%c\n", Field^.BorderSymbol);
      END;
    END;

    IF border IN Display THEN
      Ptr := (Field^.Height - 1) * Field^.Width;
      FOR I := 1 TO Field^.Width DO
        C.printf("%c", Field^.BorderSymbol);
      END;
      C.printf("\n");
    END;

    RETURN TRUE;
  END;

  RETURN FALSE;
END Print;

(* --- *)

PROCEDURE Reset(VAR Field: PField; [Random: BOOLEAN = FALSE]): [BOOLEAN];
VAR
  Ptr: POINTER TO CHAR;
  X, Y: CARDINAL;
BEGIN
  IF (Field # NIL) AND (Field^.Data # NIL) THEN
    Field^.AliveSymbol := defAliveSymbol;
    Field^.DeadSymbol := defDeadSymbol;

    IF Random THEN
      FOR Y := 1 TO (Field^.Height - 2) DO
        Ptr := Field^.Data;
        INC(Ptr, Y * Field^.Width + 1);

        FOR X := 1 TO (Field^.Width - 2) DO
          IF RandomCard(3) = 2 THEN
            Ptr^ := Field^.AliveSymbol;
          END;
          INC(Ptr);
        END;
      END;
    ELSE
      Ptr := Field^.Data;
      FOR X := 1 TO (Field^.Width * Field^.Height) DO
        Ptr^ := Field^.DeadSymbol;
        INC(Ptr);
      END;
    END;

    RETURN TRUE;
  END;

  RETURN FALSE;
END Reset;

PROCEDURE Step(VAR Field: PField; [Steps: CARDINAL = 1]): [BOOLEAN];
VAR
  Ptr, PtrYX: POINTER TO CHAR;
  S, X, Y, Count: CARDINAL;
BEGIN
  IF (Field # NIL) AND (Field^.Data # NIL) AND (Field^.DataNext # NIL) THEN
    FOR S := 1 TO Steps DO
      IF Field^.Measure THEN
        StopWatch.Start(Field^.StepTime);
      END;

      Ptr := Field^.DataNext;
      FOR X := 1 TO (Field^.Width * Field^.Height) DO
        Ptr^ := Field^.DeadSymbol;
        INC(Ptr);
      END;

      FOR Y := 1 TO (Field^.Height - 2) DO
        FOR X := 1 TO (Field^.Width - 2) DO
          PtrYX := Field^.Data;
          Count := 0;

          INC(PtrYX, (Y - 1) * Field^.Width + X - 1);
          IF PtrYX^ = Field^.AliveSymbol THEN INC(Count) END;
          INC(PtrYX);
          IF PtrYX^ = Field^.AliveSymbol THEN INC(Count) END;
          INC(PtrYX);
          IF PtrYX^ = Field^.AliveSymbol THEN INC(Count) END;

          INC(PtrYX, Field^.Width - 2);
          IF PtrYX^ = Field^.AliveSymbol THEN INC(Count) END;
          INC(PtrYX, 2);
          IF PtrYX^ = Field^.AliveSymbol THEN INC(Count) END;

          INC(PtrYX, Field^.Width - 2);
          IF PtrYX^ = Field^.AliveSymbol THEN INC(Count) END;
          INC(PtrYX);
          IF PtrYX^ = Field^.AliveSymbol THEN INC(Count) END;
          INC(PtrYX);
          IF PtrYX^ = Field^.AliveSymbol THEN INC(Count) END;

          IF (Count > 1) AND (Count < 4) THEN
            Ptr := Field^.DataNext;
            PtrYX := Field^.Data;
            INC(Ptr, Y * Field^.Width + X);
            INC(PtrYX, Y * Field^.Width + X);

            IF Count = 3 THEN
              Ptr^ := Field^.AliveSymbol;
            ELSE
              Ptr^ := PtrYX^;
            END;
          END;
        END;
      END;

      Ptr := Field^.Data;
      Field^.Data := Field^.DataNext;
      Field^.DataNext := Ptr;

      INC(Field^.Steps);

      IF Field^.Measure THEN
        StopWatch.Stop(Field^.StepTime);
      END;
    END;

    RETURN TRUE;
  END;

  RETURN FALSE;
END Step;

PROCEDURE SetCell(VAR Field: PField; X, Y: CARDINAL; [State: BOOLEAN = TRUE]): [BOOLEAN];
VAR
  Ptr: POINTER TO CHAR;
BEGIN
  IF (Field # NIL) AND (Field^.Data # NIL) AND (X < (Field^.Width - 2)) AND
      (Y < (Field^.Height - 2))
  THEN
    Ptr := Field^.Data;
    INC(Ptr, (Y + 1) * Field^.Width + X + 1);

    IF State THEN
      Ptr^ := Field^.AliveSymbol;
    ELSE
      Ptr^ := Field^.DeadSymbol;
    END;

    RETURN TRUE;
  END;

  RETURN FALSE;
END SetCell;

PROCEDURE SetCycleDelayMs(VAR Field: PField; Delay: CARDINAL): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    Field^.Delay := Delay;

    RETURN TRUE;
  END;

  RETURN FALSE;
END SetCycleDelayMs;

PROCEDURE SetAliveSymbol(VAR Field: PField; Symbol: CHAR): [BOOLEAN];
BEGIN
  RETURN SetSymbol(Field, Symbol, TRUE);
END SetAliveSymbol;

PROCEDURE SetDeadSymbol(VAR Field: PField; Symbol: CHAR): [BOOLEAN];
BEGIN
  RETURN SetSymbol(Field, Symbol, FALSE);
END SetDeadSymbol;

PROCEDURE SetBorderSymbol(VAR Field: PField; Symbol: CHAR): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    Field^.BorderSymbol := Symbol;

    RETURN TRUE;
  END;

  RETURN FALSE;
END SetBorderSymbol;

PROCEDURE SetPerfMeasuring(VAR Field: PField; Measure: BOOLEAN): [BOOLEAN];
BEGIN
  IF Field # NIL THEN
    Field^.Measure := Measure;

    RETURN TRUE;
  END;

  RETURN FALSE;
END SetPerfMeasuring;

BEGIN
  Randomize;
END Field.
