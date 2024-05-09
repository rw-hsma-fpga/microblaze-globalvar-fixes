## How to make part of your LMB memory *read-only*

1. Starting point:
	* An existing Vivado project *with*
	* a Block Design with a Microblaze processor *with*
	* an LMB (Local Memory Bus) sub-block (plus sign, darker shade of blue)
	
2. Add the VHDL file **rdonly_addrfilter.vhd**  to your Vivado project:
	* In the *Sources* window, click the ```+``` sign.
	* *Add or create design sources* -> *Next*
	* *Add Files*
	* Choose **rdonly_addrfilter.vhd** and *OK*
	* *Finish*
	
3. Add the VHDL file to the block diagram:
	1. In the *Sources* window, *Right-click* on **rdonly_addrfilter.vhd**
	* Choose *Add Module to Block Design*
	* **rdonly_addrfilter_v1_0** is now a block with an *RTL* logo
	
4. *Ungroup* your LMB subblock:
	* *Right mouse button* on the LMB sub-block
	* *Ungroup Hierarchy*
	* The block diagram now has 5 new individual blocks:
		* ilmb_v10 (instruction bus)
		* dlmb_v10 (data bus)
		* ilmb_bram_if_cntlr (instruction BRAM controller)
		* dlmb_bram_if_cntlr (data BRAM controller)
		* lmb_bram (dual-port BlockRAM with LMB ports)

<img src="add_rdonly.png" style="width:60em">
		
5. Integrate **rdonly_addrfilter_v1_0**, resulting in the picture above:
	* Arrange LMB blocks and **rdonly_addrfilter_v1_0** roughly as shown
	* Expand **dlmb_bram_if_cntlr**'s *BRAM_PORT* and  **lmb_bram**'s *BRAM_PORTA* with ```+```
	* Connect

 		* **rdonly_addrfilter_v1_0**'s input *addr_in_[0:31]* to **dlmb_bram_if_cntlr**'s  output *BRAM_Addr_A[0:31]* 	
		* **lmb_bram**'s input *addra[31:0]* also to **dlmb_bram_if_cntlr**'s  output *BRAM_Addr_A[0:31]*
	 	* **rdonly_addrfilter_v1_0**'s input *wren_in[0:3]* to **dlmb_bram_if_cntlr**'s  output *BRAM_WEN_A[0:3]*
	 	* **rdonly_addrfilter_v1_0**'s output *wren_out[3:0]* to **lmb_bram**'s input *wea[3:0]*
 
 	* Hide full ports again; the individually connected ports are still visible as shown  in the image.
 	
6. *Double click* on **rdonly_addrfilter_v1_0** to set the access parameters:
	* Set ```Rdwr Startaddr``` to the beginning of the desired writeable/RAM range.  
		* Write accesses below that address will be blocked, so the lower range will behave like ROM.  
		* The default setting ```0x00000000``` means all memory acts as RAM as if the filter had not been added.  
		* "Round" hexadecimal numbers like ```0x3000``` will lead to less logic.	
	* Set ```Memsize Log2``` to the number of bits required for the LMB BRAM size, e.g.:
		* 14 : 16 KBytes
		* 16 : 64 KBytes
		* 17 : 128 KBytes (default, maximum size available in *Block Automation*)
		* 20 : 1 MByte  
	This is again intended to minimize compare logic; pick a larger value to be on the safe side and avoid aliasing the ROM window to higher addresses.
	* Save the settings with *OK*. The address filtering will be active after rebuilding the bitstream.
		* Be aware of *Vitis'* poor record of updating bitstreams in existing software projects. Create a new platform or even a new *Vitis* workspace to be sure.

7. *OPTIONAL*: For cosmetic reasons and easier handling, create a memory sub-block again:
	* Mark all 6 blocks together
	* *Right click* -> *Create hierachy*
	* Specify cell name **LMB**, click *Ok*
	* Open the sub-block with the ```+``` sign again
	* Click exactly on the pin **LMB_M** at the sub-block edge
	 	* In the window *sub-block properties* on the left, change the name **LMB_M** to **DLMB** or **ILMB** depending on the connected port
 	* Repeat with the pin **LMB_M1**
 	* Close the sub-block with the ```-``` sign

 	
