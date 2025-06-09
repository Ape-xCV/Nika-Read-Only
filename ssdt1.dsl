/*
 * Override for host defined _OSI to handle "Darwin"...
 * All _OSI calls in DSDT are routed to XOSI...
 */
DefinitionBlock ("", "SSDT", 2, "ALASKA", "A M I ", 0x00000001)
{
    Method (XOSI, 1, NotSerialized)
    {
        Local0 = Package (0x0C)
            {
                "Windows", 
                "Windows 2001", 
                "Windows 2001 SP1", 
                "Windows 2001 SP2", 
                "Windows 2001 SP3", 
                "Windows 2006", 
                "Windows 2006 SP1", 
                "Windows 2006 SP2", 
                "Windows 2009", 
                "Windows 2012", 
                "Windows 2013", 
                "Windows 2015"  // .
            }
        If (_OSI ("Darwin"))
        {
            Return ((Ones != Match (Local0, MEQ, Arg0, MTR, 0x00, 0x00)))
        }
        Else
        {
            Return (_OSI (Arg0))
        }
    }
}

