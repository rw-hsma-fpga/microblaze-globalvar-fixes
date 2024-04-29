# microblaze-globalvar-fixes
Suggested fixes for clobbered global variables after reset on a Microblaze soft processor system,
as described in our FPL2024 paper:
(add DOI)

## 1a) Add Load Segments

**add_load_segments.sh** 

Use the script as follows:

```bash
./add_load_segments.sh <linkerscript.ld> 
```

## 1b) Split into RAM and ROM 

The bash script **split_into_ram_rom.sh** creates two new memory segments labeled "mbRam" and "mbRom". 
Required for the command are the linkerscript to change and a hex-value which represents the origin adress of the added memory segment. 
The CLI call looks like the following:

```bash
./split_into_ram_rom.sh <linkerscript.ld> <hex-value>
```

For further information on how the script works, see 
[split_into_ram_rom script](1b__split_into_rom_ram__bash/split_into_rom_ram.sh)

## 2a) 

The first way to load the new globals from the linkerscript is to include the headerfile [init_mb_globals.h](2a__init_globals__function/init_mb_globals.h). Afterwards, the function 
```c
void init_mb_globals(void)
```
needs to be called at the top of the main() function. 

## 2b) 

The second way is to run the [make_initglobals_lib.sh](2b__init_globals__library/make_initglobals_lib.sh) script. This will compile a static library from the [init_mb_globals_lib.c](2b__init_globals__library/init_mb_globals_lib.c) source file which will automatically call the function to initialize the globals.

## 3)

In case of using 1b), it is still necessary to make the rom memory segment read-only. The complete guide is explained in [HOWTO.md](3___rdonly_addrfilter__vhdl/HOWTO.md)