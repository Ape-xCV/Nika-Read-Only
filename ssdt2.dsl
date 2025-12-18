DefinitionBlock ("", "SSDT", 2, "ALASKA", "A M I ", 0x00000001)
{
    External (_SB_.PCI0, DeviceObj)

    Scope (_SB.PCI0)
    {
        Device (TIMR)
        {
            Name (_HID, EisaId ("PNP0100") /* PC-class System Timer */)  // _HID: Hardware ID
            Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
            {
                IO (Decode16, 0x0040, 0x0040, 0x01, 0x04)
                IO (Decode16, 0x0050, 0x0050, 0x10, 0x04)
            })

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }  // end of TIMR device
    }  // end of _SB.PCI0 scope
}

