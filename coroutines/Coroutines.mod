MODULE Coroutines;

FROM RandomNumber IMPORT Randomize, RandomShortCard;
FROM SYSTEM IMPORT ADR, BYTE, CARDINAL32, NEWPROCESS, PROCESS, SIZE, TRANSFER;
FROM STextIO IMPORT WriteLn, WriteString;
FROM SWholeIO IMPORT ReadCard, WriteCard;

CONST
  Win = 21;

VAR
  Main, Player1, Player2: PROCESS;
  Area1, Area2: ARRAY[1..16384] OF BYTE;

PROCEDURE Func1;
VAR
  Sum, Throw: CARDINAL32;
BEGIN
  Sum := 0;
  LOOP
    Throw := RandomShortCard(1, 11);
    WriteString("Player 1 ("); WriteCard(Sum, 0); WriteString(")");
    WriteString("->rolled("); WriteCard(Throw, 0); WriteString(")");

    IF (Sum + Throw) > Win THEN
      WriteString("->missed("); WriteCard(Throw, 0); WriteString(")"); WriteLn;
      TRANSFER(Player1, Player2);
    ELSIF (Sum + Throw) = Win THEN
      WriteString("->won("); WriteCard(Throw, 0); WriteString(")"); WriteLn;
      TRANSFER(Player1, Main);
    ELSE
      INC(Sum, Throw);
      WriteString("->sum("); WriteCard(Sum, 0); WriteString(")"); WriteLn;
      TRANSFER(Player1, Player2);
    END;
  END;
END Func1;

PROCEDURE Func2;
VAR
  Sum, Throw: CARDINAL32;
BEGIN
  Sum := 0;
  LOOP
    Throw := RandomShortCard(1, 11);
    WriteString("Player 2 ("); WriteCard(Sum, 0); WriteString(")");
    WriteString("->rolled("); WriteCard(Throw, 0); WriteString(")");

    IF (Sum + Throw) > Win THEN
      WriteString("->missed("); WriteCard(Throw, 0); WriteString(")"); WriteLn;
      TRANSFER(Player2, Player1);
    ELSIF (Sum + Throw) = Win THEN
      WriteString("->won("); WriteCard(Throw, 0); WriteString(")"); WriteLn;
      TRANSFER(Player2, Main);
    ELSE
      INC(Sum, Throw);
      WriteString("->sum("); WriteCard(Sum, 0); WriteString(")"); WriteLn;
      TRANSFER(Player2, Player1);
    END;
  END;
END Func2;

BEGIN
  Randomize;

  WriteString("*** ROLL THE DICE ***"); WriteLn;
  WriteString("target sum: "); WriteCard(Win, 0); WriteLn;

  NEWPROCESS(Func1, ADR(Area1), SIZE(Area1), Player1);
  NEWPROCESS(Func2, ADR(Area2), SIZE(Area2), Player2);
  TRANSFER(Main, Player1);

  WriteString("*** END ***"); WriteLn;
END Coroutines.
