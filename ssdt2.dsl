DefinitionBlock ("", "SSDT", 2, "MCRSFT", "MSACPI", 0x00000001)
{
    External (_SB_.PCI0, DeviceObj)
    External (_PR_.CPU0, ProcessorObj)

    Scope (_SB.PCI0)
    {
        Device (EC0)
        {
            Name (_HID, EisaId ("PNP0C09") /* Embedded Controller Device */)  // _HID: Hardware ID
            Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
            {
                IO (Decode16, 0x0062, 0x0062, 0x00, 0x01)
                IO (Decode16, 0x0066, 0x0066, 0x00, 0x01)
            })
            Name (_GPE, 0)  // _GPE: General Purpose Events
            OperationRegion (EC0, EmbeddedControl, 0, 0xFF)
            Field (EC0, ByteAcc, Lock, Preserve)
            {
                MODE,   1, 
                FAN,    1,
                TMP,    16, 
                AC0,    16, 
                PSV,    16, 
                HOT,    16,
                CRT,    16  // .
            }

            // following is a method that OSPM will schedule after it
            // receives an SCI and queries the EC to retrieve value 7
            Method (_Q07, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Notify (\_SB.PCI0.EC0.TZ0, 0x80) // Thermal Status Change
            }

            PowerResource (PWF0, 0x00, 0x0000)
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Method (_ON, 0, NotSerialized)
                {
                }

                Method (_OFF, 0, NotSerialized)
                {
                }
            }

            Device (FAN0)
            {
                Name (_HID, EisaId ("PNP0C0B") /* Fan (Thermal Solution) */)  // _HID: Hardware ID
                Name (_PR0, Package (0x01)  // _PR0: Power Resources for FAN0
                {
                    PWF0  // .
                })
            }

            ThermalZone (TZ0)
            {
                Method (_TMP, 0, NotSerialized)  // _TMP: Temperature
                {
                    Return (0x1770)
                }

                Method (_AC0, 0, NotSerialized)  // _ACx: Active Cooling, x=0-9
                {
                    Return (0x1770)
                }

                Name (_AL0, Package (0x01)  // _ALx: Active List, x=0-9
                {
                    \_SB.PCI0.EC0.FAN0  // .
                })
                Method (_PSV, 0, NotSerialized)  // _PSV: Passive Temperature
                {
                    Return (0x1670)
                }

                Name (_PSL, Package (0x01)  // _PSL: Passive List
                {
                    \_PR.CPU0  // .
                })
                Method (_HOT, 0, NotSerialized)  // _HOT: Hot Temperature
                {
                    Return (0x1780)
                }

                Method (_CRT, 0, NotSerialized)  // _CRT: Critical Temperature
                {
                    Return (0x1780)
                }

                Method (_SCP, 1, NotSerialized)  // _SCP: Set Cooling Policy
                {
                }

                Name (_TC1, 0x04)  // _TC1: Thermal Constant 1
                Name (_TC2, 0x03)  // _TC2: Thermal Constant 2
                Name (_TSP, 0x96)  // _TSP: Thermal Sampling Period
                Name (_TZP, 0x00)  // _TZP: Thermal Zone Polling
                Name (_STR, Unicode ("System thermal zone"))  // _STR: Description String
            }
        }  // end of EC0 device
    }  // end of _SB.PCI0 scope
}

