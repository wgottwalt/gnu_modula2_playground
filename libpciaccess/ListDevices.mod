(*!m2iso*)
MODULE Test;

FROM STextIO IMPORT WriteLn, WriteString;
FROM SWholeIO IMPORT WriteCard, WriteInt;
FROM SYSTEM IMPORT ADDRESS, CSIZE_T, INTEGER32;
IMPORT PciAccess;

PROCEDURE PrintDevice(Device: PciAccess.PDevice; Verbose: BOOLEAN);
VAR
  DeviceName, VendorName: PciAccess.TString;
BEGIN
  VendorName := PciAccess.DeviceGetVendorName(Device);
  DeviceName := PciAccess.DeviceGetDeviceName(Device);

  WriteString(VendorName); WriteString(" :: "); WriteString(DeviceName);
END PrintDevice;

VAR
  Device: PciAccess.PDevice;
  Iter: PciAccess.PDeviceIterator;
  I, Result: INTEGER32;

BEGIN
  Iter := NIL;
  I := 0;

  Result := PciAccess.SystemInit();

  Iter := PciAccess.SlotMatchIteratorCreate(NIL);
  Device := PciAccess.DeviceNext(Iter);
  WHILE Device <> NIL DO
    INC(I);
    WriteInt(I, 0); WriteString(" :: "); PrintDevice(Device, FALSE); WriteLn;
    Device := PciAccess.DeviceNext(Iter);
  END;
  PciAccess.IteratorDestroy(Iter);
  Iter := NIL;

  PciAccess.SystemCleanup;
END Test.
