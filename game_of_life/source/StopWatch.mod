(*!m2iso+gm2*)
IMPLEMENTATION MODULE StopWatch;

IMPORT C, SYSTEM;

TYPE
  TStopWatch = RECORD
    StartTime: C.TTimeSpec;
    StopTime: C.TTimeSpec;
    StartDone: BOOLEAN;
    StopDone: BOOLEAN;
  END;
  PStopWatch = POINTER TO TStopWatch;

VAR
  Resolution: C.TTimeSpec;

(* --- *)

PROCEDURE Init(VAR StopWatch: PStopWatch; [Start: BOOLEAN = FALSE]): [BOOLEAN];
BEGIN
  IF StopWatch = NIL THEN
    StopWatch := C.malloc(SYSTEM.TSIZE(TStopWatch));

    IF StopWatch # NIL THEN
      IF Start THEN
        C.clock_gettime(C.CLOCK_MONOTONIC_RAW, SYSTEM.ADR(StopWatch^.StartTime));
        StopWatch^.StartDone := TRUE;
      ELSE
        StopWatch^.StartTime := C.TTimeSpec{0, 0};
        StopWatch^.StartDone := FALSE;
      END;
      StopWatch^.StopTime := C.TTimeSpec{0, 0};
      StopWatch^.StopDone := FALSE;

      RETURN TRUE;
    END;
  END;

  RETURN FALSE;
END Init;

PROCEDURE Destroy(VAR StopWatch: PStopWatch): [BOOLEAN];
BEGIN
  IF StopWatch # NIL THEN
    C.free(StopWatch);
    StopWatch := NIL;

    RETURN TRUE;
  END;

  RETURN FALSE;
END Destroy;

PROCEDURE ResolutionInNanoSeconds(VAR Ns: LONGCARD): [BOOLEAN];
BEGIN
  IF (Resolution.TvSec # 0) OR (Resolution.TvNSec # 0) THEN
    Ns := VAL(LONGCARD, Resolution.TvSec) * 1000000000 + VAL(LONGCARD, Resolution.TvNSec);

    RETURN TRUE;
  END;

  RETURN FALSE;
END ResolutionInNanoSeconds;

(* --- *)

PROCEDURE Start(VAR StopWatch: PStopWatch): [BOOLEAN];
BEGIN
  IF StopWatch # NIL THEN
    C.clock_gettime(C.CLOCK_MONOTONIC_RAW, SYSTEM.ADR(StopWatch^.StartTime));
    StopWatch^.StartDone := TRUE;

    RETURN TRUE;
  END;

  RETURN FALSE;
END Start;

PROCEDURE Stop(VAR StopWatch: PStopWatch): [BOOLEAN];
BEGIN
  IF StopWatch # NIL THEN
    C.clock_gettime(C.CLOCK_MONOTONIC_RAW, SYSTEM.ADR(StopWatch^.StopTime));
    StopWatch^.StopDone := TRUE;

    RETURN TRUE;
  END;

  RETURN FALSE;
END Stop;

PROCEDURE DiffInNanoSeconds(StopWatch: PStopWatch; VAR Ns: LONGCARD): [BOOLEAN];
VAR
  Tmp1, Tmp2: LONGCARD;
BEGIN
  IF (StopWatch # NIL) AND StopWatch^.StartDone AND StopWatch^.StopDone THEN
    Tmp1 := VAL(LONGCARD, StopWatch^.StartTime.TvSec) * 1000000000 +
            VAL(LONGCARD, StopWatch^.StartTime.TvNSec);
    Tmp2 := VAL(LONGCARD, StopWatch^.StopTime.TvSec) * 1000000000 +
            VAL(LONGCARD, StopWatch^.StopTime.TvNSec);
    Ns := Tmp2 - Tmp1;

    RETURN TRUE;
  END;

  RETURN FALSE;
END DiffInNanoSeconds;

BEGIN
  C.clock_getres(C.CLOCK_MONOTONIC_RAW, SYSTEM.ADR(Resolution));
END StopWatch.
