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

## 2b) 

## 3)