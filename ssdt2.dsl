DefinitionBlock ("", "SSDT", 2, "ALASKA", "A M I ", 0x00000001)
{
    External (_SB_.PCI0.LPCB, DeviceObj)

    Scope (_SB.PCI0.LPCB)
    {
        Device (TIMR)
        {
            Name (_HID, EisaId ("PNP0100") /* PC-class System Timer */)  // _HID: Hardware ID
            Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
            {
                // Standard 8254 PIT I/O Range (0x40 - 0x43)
                IO (Decode16, 0x0040, 0x0040, 0x01, 0x04)
                // Legacy System Timer IRQ
                IRQNoFlags () { 0 }
            })

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }  // end of TIMR device
    }  // end of _SB.PCI0 scope
}

