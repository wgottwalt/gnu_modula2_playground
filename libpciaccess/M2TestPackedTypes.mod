(*!m2iso*)
MODULE M2TestPackedTypes;

FROM STextIO IMPORT WriteLn, WriteString;
FROM SWholeIO IMPORT WriteCard;
FROM SYSTEM IMPORT TSIZE;
IMPORT PciAccess;

VAR
  AgpInfo: PciAccess.TAgpInfo;
  MemRegion: PciAccess.TMemRegion;
BEGIN
  WriteString("TAgpInfo (type, instance):   ");
  WriteCard(TSIZE(PciAccess.TAgpInfo), 0); WriteString(" "); WriteCard(SIZE(AgpInfo), 0);
  WriteLn;

  WriteString("TMemRegion (type, instance): ");
  WriteCard(TSIZE(PciAccess.TMemRegion), 0); WriteString(" "); WriteCard(SIZE(MemRegion), 0);
  WriteLn;
END M2TestPackedTypes.
