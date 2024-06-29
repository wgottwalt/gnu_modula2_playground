(*!m2iso*)
IMPLEMENTATION MODULE PciAccess;

FROM SYSTEM IMPORT CSIZE_T;
IMPORT LibPciAccessBinding;

TYPE
  PCARDINAL8 = POINTER TO CARDINAL8;
  PCARDINAL16 = POINTER TO CARDINAL16;
  PCARDINAL32 = POINTER TO CARDINAL32;
  PDeviceIterator = POINTER TO TDeviceIterator;
  PINTEGER32 = POINTER TO INTEGER32;

  TDeviceIterator = RECORD
    NextIndex: CARDINAL32;
    Mode: (MatchAny, MatchSlot, MatchId);
    Match: RECORD
      CASE BOOLEAN OF
        | FALSE: Slot: TSlotMatch
        | TRUE: Id: TIdMatch
      END;
    END;
  END;

PROCEDURE DeviceHasKernelDriver(Dev: PDevice): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_has_kernel_driver(Dev);
END DeviceHasKernelDriver;

PROCEDURE DeviceIsBootVga(Dev: PDevice): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_is_boot_vga(Dev);
END DeviceIsBootVga;

PROCEDURE DeviceReadRom(Dev: PDevice; Buffer: ADDRESS): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_read_rom(Dev, Buffer);
END DeviceReadRom;

PROCEDURE DeviceMapRange(Dev: PDevice; Base, Size: TAddr; MapFlags: CARDINAL32;
                         Addr: ADDRESS): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_map_range(Dev, Base, Size, MapFlags, Addr);
END DeviceMapRange;

PROCEDURE DeviceUnmapRange(Dev: PDevice; Memory: ADDRESS; Size: TAddr): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_unmap_range(Dev, Memory, Size);
END DeviceUnmapRange;

PROCEDURE DeviceProbe(Dev: PDevice): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_probe(Dev);
END DeviceProbe;

PROCEDURE DeviceGetAgpInfo(Dev: PDevice): PAgpInfo;
BEGIN
  RETURN LibPciAccessBinding.pci_device_get_agp_info(Dev);
END DeviceGetAgpInfo;

PROCEDURE DeviceGetBridgeInfo(Dev: PDevice): PBridgeInfo;
BEGIN
  RETURN LibPciAccessBinding.pci_device_get_bridge_info(Dev);
END DeviceGetBridgeInfo;

PROCEDURE DeviceGetPcmciaBridgeInfo(Dev: PDevice): PPcmciaBridgeInfo;
BEGIN
  RETURN LibPciAccessBinding.pci_device_get_pcmcia_bridge_info(Dev);
END DeviceGetPcmciaBridgeInfo;

PROCEDURE DeviceGetBridgeBuses(Dev: PDevice; PrimaryBus, SecondaryBus,
                               SubordinateBus: PINTEGER32): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_get_bridge_buses(Dev, PrimaryBus, SecondaryBus,
                                                         SubordinateBus);
END DeviceGetBridgeBuses;

PROCEDURE SystemInit(): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_system_init();
END SystemInit;

PROCEDURE SystemInitDevMem(Fd: INTEGER32);
BEGIN
  LibPciAccessBinding.pci_system_init_dev_mem(Fd);
END SystemInitDevMem;

PROCEDURE SystemCleanup;
BEGIN
  LibPciAccessBinding.pci_system_cleanup;
END SystemCleanup;

PROCEDURE SlotMatchIteratorCreate(Match: PSlotMatch): PDeviceIterator;
BEGIN
  RETURN LibPciAccessBinding.pci_slot_match_iterator_create(Match);
END SlotMatchIteratorCreate;

PROCEDURE IdMatchIteratorCreate(Match: PIdMatch): PDeviceIterator;
BEGIN
  RETURN LibPciAccessBinding.pci_id_match_iterator_create(Match);
END IdMatchIteratorCreate;

PROCEDURE IteratorDestroy(Iter: PDeviceIterator);
BEGIN
  LibPciAccessBinding.pci_iterator_destroy(Iter);
END IteratorDestroy;

PROCEDURE DeviceNext(Iter: PDeviceIterator): PDevice;
BEGIN
  RETURN LibPciAccessBinding.pci_device_next(Iter);
END DeviceNext;

PROCEDURE DeviceFindBySlot(Domain, Bus, Dev, Func: CARDINAL32): PDevice;
BEGIN
  RETURN LibPciAccessBinding.pci_device_find_by_slot(Domain, Bus, Dev, Func);
END DeviceFindBySlot;

PROCEDURE DeviceGetParentBridge(Dev: PDevice): PDevice;
BEGIN
  RETURN LibPciAccessBinding.pci_device_get_parent_bridge(Dev);
END DeviceGetParentBridge;

PROCEDURE GetStrings(M: PIdMatch; VAR DeviceName, VendorName, SubdeviceName, SubvendorName: TString);
VAR
  Device, Vendor, Subdevice, Subvendor: ADDRESS;
BEGIN
  Device := NIL;
  Vendor := NIL;
  Subdevice := NIL;
  Subvendor := NIL;

  LibPciAccessBinding.pci_get_strings(M, Device, Vendor, Subdevice, Subvendor);

  StringCopy(Device, DeviceName);
  StringCopy(Vendor, VendorName);
  StringCopy(Subdevice, SubdeviceName);
  StringCopy(Subvendor, SubvendorName);
END GetStrings;

PROCEDURE DeviceGetDeviceName(Dev: PDevice): TString;
VAR
  Result: TString;
BEGIN
  StringCopy(LibPciAccessBinding.pci_device_get_device_name(Dev), Result);

  RETURN Result;
END DeviceGetDeviceName;

PROCEDURE DeviceGetSubdeviceName(Dev: PDevice): TString;
VAR
  Result: TString;
BEGIN
  StringCopy(LibPciAccessBinding.pci_device_get_subdevice_name(Dev), Result);

  RETURN Result;
END DeviceGetSubdeviceName;

PROCEDURE DeviceGetVendorName(Dev: PDevice): TString;
VAR
  Result: TString;
BEGIN
  StringCopy(LibPciAccessBinding.pci_device_get_vendor_name(Dev), Result);

  RETURN Result;
END DeviceGetVendorName;

PROCEDURE DeviceGetSubvendorName(Dev: PDevice): TString;
VAR
  Result: TString;
BEGIN
  StringCopy(LibPciAccessBinding.pci_device_get_subvendor_name(Dev), Result);

  RETURN Result;
END DeviceGetSubvendorName;

PROCEDURE DeviceEnable(Dev: PDevice);
BEGIN
  LibPciAccessBinding.pci_device_enable(Dev);
END DeviceEnable;

PROCEDURE DeviceDisable(Dev: PDevice);
BEGIN
  LibPciAccessBinding.pci_device_disable(Dev);
END DeviceDisable;

PROCEDURE DeviceCfgRead(Dev: PDevice; Data: ADDRESS; Offset, Size: TAddr;
                        BytesRead: PAddr): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_cfg_read(Dev, Data, Offset, Size, BytesRead);
END DeviceCfgRead;

PROCEDURE DeviceCfgReadU8(Dev: PDevice; Data: PCARDINAL8; Offset: TAddr): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_cfg_read_u8(Dev, Data, Offset);
END DeviceCfgReadU8;

PROCEDURE DeviceCfgReadU16(Dev: PDevice; Data: PCARDINAL16; Offset: TAddr): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_cfg_read_u16(Dev, Data, Offset);
END DeviceCfgReadU16;

PROCEDURE DeviceCfgReadU32(Dev: PDevice; Data: PCARDINAL32; Offset: TAddr): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_cfg_read_u32(Dev, Data, Offset);
END DeviceCfgReadU32;

PROCEDURE DeviceCfgWrite(Dev: PDevice; Data: ADDRESS; Offset, Size: TAddr;
                         BytesWritten: PAddr): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_cfg_write(Dev, Data, Offset, Size, BytesWritten);
END DeviceCfgWrite;

PROCEDURE DeviceCfgWriteU8(Dev: PDevice; Data: CARDINAL8; Offset: TAddr): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_cfg_write_u8(Dev, Data, Offset);
END DeviceCfgWriteU8;

PROCEDURE DeviceCfgWriteU16(Dev: PDevice; Data: CARDINAL16; Offset: TAddr): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_cfg_write_u16(Dev, Data, Offset);
END DeviceCfgWriteU16;

PROCEDURE DeviceCfgWriteU32(Dev: PDevice; Data: CARDINAL32; Offset: TAddr): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_cfg_write_u32(Dev, Data, Offset);
END DeviceCfgWriteU32;

PROCEDURE DeviceCfgWriteBits(Dev: PDevice; Mask: CARDINAL32; Offset: TAddr): INTEGER32;
BEGIN
  RETURN LibPciAccessBinding.pci_device_cfg_write_bits(Dev, Mask, Offset);
END DeviceCfgWriteBits;

(* internal support *)

PROCEDURE StringCopy(From: ADDRESS; VAR To: ARRAY OF CHAR);
VAR
  Pointer: POINTER TO CHAR;
  Length: CSIZE_T;
  I: CSIZE_T;
BEGIN
  Pointer := From;
  Length := HIGH(To);
  I := 0;

  WHILE (I < Length) AND (Pointer <> NIL) AND (Pointer^ <> 0C) DO
    To[I] := Pointer^;
    INC(Pointer);
    INC(I);
  END;
  IF I < Length THEN
    To[I] := 0C;
  END;
END StringCopy;

END PciAccess.
