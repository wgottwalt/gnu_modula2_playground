MODULE ProceduresAreConstants;

IMPORT STextIO;

CONST
  WriteLn = STextIO.WriteLn;
  WriteString = STextIO.WriteString;

BEGIN
  WriteString("Procedures are constants, so are 'function pointers'."); WriteLn;
END ProceduresAreConstants.
