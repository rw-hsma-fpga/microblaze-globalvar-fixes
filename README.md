# microblaze-globalvar-fixes
Suggested fixes for clobbered global variables after reset on a Microblaze soft processor system,
as described in our FPL2024 paper:
(add DOI)

## 1a) Add Load Segments

The **add_load_segments.sh** script creates new sections in the linker script.
These sections are then used by the .data, .sdata and .tdata sections as load sections. 
For example the line
```bash
.data : AT ( __load_data_start) {
```

defines that all .data information is stored in the new section .load_data. 
Later, the contents of the .load_data section are then copied to the .data section with the 2a) or 2b) presented solutions.
 

Use the script as follows:

```bash
./add_load_segments.sh <linkerscript.ld> 
```

## 1b) Split into RAM and ROM 

The bash script **split_into_ram_rom.sh** creates two new memory segments labeled "mbRAM" and "mbROM". 
Required for the command are the linkerscript to change and a hex-value which represents the origin adress of the added memory segment. 
The CLI call looks like the following:

```bash
./split_into_ram_rom.sh <linkerscript.ld> <hex-value>
```

For example, for a new origin address with input **0x3000** the splitting would look something like:

![Split_Ram_Rom](1b__split_into_rom_ram__bash/split_ram_rom.png)

For further information on how the script works, see 
[split_into_ram_rom script](1b__split_into_rom_ram__bash/split_into_rom_ram.sh)

## 2a) Init Globals from function

The first way to load the new globals from the linkerscript is to include the headerfile [init_mb_globals.h](2a__init_globals__function/init_mb_globals.h). Afterwards, the function 
```c
void init_mb_globals(void)
```
needs to be called at the top of the main() function. 

## 2b) Init Globals from library

The second way is to run the [make_initglobals_lib.sh](2b__init_globals__library/make_initglobals_lib.sh) script. This will compile a static library from the [init_mb_globals_lib.c](2b__init_globals__library/init_mb_globals_lib.c) source file which will automatically call the function to initialize the globals.

## 3) Add read-only to 1b) ROM Segment

In case of using 1b), it is still necessary to make the rom memory segment read-only. The complete guide is explained in [HOWTO.md](3___rdonly_addrfilter__vhdl/HOWTO.md)