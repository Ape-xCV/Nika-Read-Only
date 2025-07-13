/*
 * Newer KabyLake/KabyLake-R/CoffeeLake boards use _PR.PR00, or _PR.P000 as first CPU path.
 * Adjust this code according to what you find for Processor objects in your own DSDT.
 */
DefinitionBlock ("", "SSDT", 2, "ALASKA", "CPUPLUG0", 0x00000001)
{
    External (_PR_.CPU0, ProcessorObj)

    Scope (_PR.CPU0)
    {
        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            If (!Arg2)
            {
                Return (Buffer (0x01)
                {
                    0x03  // .
                })
            }

            Return (Package (0x02)
            {
                "plugin-type", 
                0x01  // .
            })
        }
    }
}

