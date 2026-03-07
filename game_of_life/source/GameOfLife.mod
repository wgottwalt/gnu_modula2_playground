(*!m2iso*)
MODULE GameOfLife;

IMPORT C, Delay, Field, StopWatch;

VAR
  F: Field.PField;
  S: StopWatch.PStopWatch;
  Diff: LONGCARD;
  Height, I: CARDINAL;
  Display: Field.TDisplaySet;
BEGIN
  F := NIL;

  IF Field.Init(F, 80, 25, TRUE) AND StopWatch.Init(S) THEN
    Field.Height(F, Height);
    Field.SetAliveSymbol(F, 'o');
    Field.SetDeadSymbol(F, '.');
    Field.SetPerfMeasuring(F, TRUE);
    Diff := 0;
    Display := Field.TDisplaySet{Field.field, Field.border, Field.header};

    FOR I := 1 TO 100 DO
      StopWatch.Start(S);
      Field.Print(F, Display);
      Field.Step(F);
      StopWatch.Stop(S);

      Delay.Delay(500);
      IF Field.border IN Display THEN
        IF Field.header IN Display THEN
          C.printf("\x1b[%uA", Height + 3);
        ELSE
          C.printf("\x1b[%uA", Height + 2);
        END;
      ELSIF NOT (Field.border IN Display) THEN
        IF Field.header IN Display THEN
          C.printf("\x1b[%uA", Height + 1);
        ELSE
          C.printf("\x1b[%uA", Height);
        END;
      END;
    END;

    Field.Destroy(F);
    StopWatch.Destroy(S);
  END;
END GameOfLife.
