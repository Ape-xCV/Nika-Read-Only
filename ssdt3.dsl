/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20240322 (64-bit version)
 * Copyright (c) 2000 - 2023 Intel Corporation
 *
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of ssdt3.aml
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00000061 (97)
 *     Revision         0x02
 *     Checksum         0x07
 *     OEM ID           "ALASKA"
 *     OEM Table ID     "CPUPLUG1"
 *     OEM Revision     0x00000002 (2)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20240322 (539231010)
 *
 * Newer KabyLake/KabyLake-R/CoffeeLake boards use _PR.PR00, or _PR.P000 as first CPU path.
 * Adjust this code according to what you find for Processor objects in your own DSDT.
 */
DefinitionBlock ("", "SSDT", 2, "ALASKA", "CPUPLUG1", 0x00000002)
{
    External (_PR_.PR00, ProcessorObj)

    Scope (_PR.PR00)
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

