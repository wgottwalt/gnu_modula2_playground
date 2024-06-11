MODULE NestedVariadicRecords;

FROM CardinalIO IMPORT WriteHex;
FROM SShortIO IMPORT WriteFixed;
FROM STextIO IMPORT WriteLn, WriteString;
FROM SWholeIO IMPORT WriteCard, WriteInt;
FROM SYSTEM IMPORT CARDINAL8, CARDINAL16, CARDINAL32, INTEGER8, INTEGER16, INTEGER32, REAL32, TSIZE;

CONST
  SIZE32 = TSIZE(CARDINAL32);

TYPE
  (* creating anonymous unions inside structs seem not to be possible *)
  TColor = RECORD
    CASE CARDINAL8 OF
      0: Unsigned: RECORD
        CASE BOOLEAN OF
          FALSE: Rgba: RECORD
            R, G, B, A: CARDINAL8;
          END |
          TRUE: Value: CARDINAL32 |
        END;
      END |
      1: Signed: RECORD
        CASE BOOLEAN OF
          FALSE: Rgba: RECORD
            R, G, B, A: INTEGER8;
          END |
          TRUE: Value: INTEGER32 |
        END;
      END |
      2: Float: REAL32 |
      3: Values: ARRAY[0..SIZE32] OF CARDINAL8 |
    ELSE
      Raw: ARRAY[0..SIZE32] OF CHAR;
    END;
  END;

VAR
  Color: TColor;
  I: CARDINAL8;

BEGIN
  WITH Color.Unsigned.Rgba DO
    R := 255;
    G := 127;
    B := 0;
    A := 255;
  END;

  WriteString("unsigned value: "); WriteCard(Color.Unsigned.Value, 0); WriteLn;
  WriteString("signed value:   "); WriteInt(Color.Signed.Value, 0); WriteLn;
  WriteString("float value:    "); WriteFixed(Color.Float, 8, 0); WriteLn;
  WriteString("as string:      "); WriteString(Color.Raw); WriteLn;

  WriteString("values as hex: ");
  FOR I := 0 TO (SIZE32 - 1) DO
    WriteString(" "); WriteHex(Color.Values[I], 2);
  END;
  WriteLn;

  WriteString("unsigned rgba:  ");
  WITH Color.Unsigned.Rgba DO
    WriteCard(R, 0); WriteString(" ");
    WriteCard(G, 0); WriteString(" ");
    WriteCard(B, 0); WriteString(" ");
    WriteCard(A, 0); WriteLn;
  END;

  WriteString("signed rgba:    ");
  WITH Color.Signed.Rgba DO
    WriteInt(R, 0); WriteString(" ");
    WriteInt(G, 0); WriteString(" ");
    WriteInt(B, 0); WriteString(" ");
    WriteInt(A, 0); WriteLn;
  END; 
END NestedVariadicRecords.
