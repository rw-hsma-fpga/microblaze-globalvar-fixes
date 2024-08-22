 #!/bin/bash

#################################
# Checking the input Parameters #
#################################

ABORT=0

if [[ -z "$1" ]]; then
	echo "Input File is missing!" 
	echo "Usage ./split_into_rom_ram.sh <inputfile> <origin adress>"
	ABORT=1
fi

if ! [[ -f "$1" ]]; then
	echo "Input File doesn't exist!"
	ABORT=1
fi 

if [[ -z "$2" ]]; then
	echo "Input of Origin Adress is missing!"
	echo "Usage ./split_into_rom_ram.sh <inputfile> <origin adress>"
	ABORT=1
fi

if ! [[ $2 =~ ^0x.* ]]; then
	echo "Input needs to be hex number!"
	ABORT=1
fi

if [[ ABORT -eq 0 ]]
then
	#########################################
	# Initializing correct Input Parameters #
	#########################################

	input_file=$1
	input_origin_adress=$2

	echo -e "Two Segement Split requested with following inputs"
	echo    "--------------------------------------------------"
	echo -e "File to change:           \t $input_file "
	echo -e "New origin adress of ram: \t $input_origin_adress"
	echo " "

	###################################
	# Create copy of old linkerscript #
	###################################

	cp $input_file "${input_file}.old"
	echo "$input_file saved to ${input_file}.old"
	echo " "

	####################################
	# Searching for the Memory Section #
	####################################

	counter=0
	memory_flag=0
	memory_line=""
	line_counter=0

	while IFS= read -r line 
	do 
		((line_counter++))
		if [[ $line =~ ^MEMORY ]]; then
			memory_flag=1
		fi 
		
		if [[ $memory_flag -eq 1 ]]; then
			((counter++))
			#echo $line_counter
		fi 
		
		if [[ $counter -eq 3 ]]; then
			memory_line=$line
			memory_line_counter=$line_counter
		fi 
	done < $input_file

	###############################################
	# Splitting Memory Variable in all it's parts #
	###############################################

	IFS=' ' read -ra ADDR <<< "$memory_line"

	##################################
	# ADDR[0] = Memory Variable Name #
	# ADDR[4] = Origin Hex Value     #
	# ADDR[7] = Length Hex Value     #
	##################################

	comma=","

	memory_variable_name="${ADDR[0]}"
	old_origin_hex_value="${ADDR[4]//$comma}"
	old_length_hex_value="${ADDR[7]//$comma}"

	###############################################
	# Calculating new Hex Values for new segments #
	###############################################

	#########################################################################################################
	#                                                                                                       #
	# Explanation how new Memory Segments are calculated                                                    #
	# Lets take following example: We have this memory segment in our linker file                           #
	# memory_segment : ORIGIN = 0x50, LENGTH = 0x7FB0                                                       #
	# This resembles the following segment:                                                                 #
	#                                                                                                       #
	#         0x8000 |---------------------|                                                                #         
	#                |                     |                                                                #
	#                |                     |                                                                #
	#                |                     |                                                                #
	#                |       MEMORY        |                                                                #
	#                |       SEGMENT       |                                                                #
	#                |                     |                                                                #
	#                |                     |                                                                #
	#                |                     |                                                                #
	#                |                     |                                                                #
	#           0x50 |-------------------- |                                                                #
	#                                                                                                       #
	# Now we want split the segment into two new segments, so we have to calculate                          #
	# the new origin adress and new length of the second segment.                                           #
	# For the first segment, in this case the "ROM" segment, we can copy the old origin                     #
	# value 0x50, and the the new end adress from the user input value                                      #
	#                                                                                                       #
	# The origin value of the second segment, here the "RAM" segment, will be the above                     #
	# mentioned user input value.                                                                           #
	# The length of the RAM segment will be calculated from the original length                             #
	# subtracted by the length of the ROM segment.                                                          #
	# Afterwards, the end adress of the RAM segment equals it's start adress added to the                   #
	# just calculated RAM length                                                                            #
	#                                                                                                       #
	# If we take aboves example and have the user input be "0x3000" we get the following calculations:      #
	# New ROM Origin    : 0x50                                                                              #
	# New ROM Length    : 0x3000 - 0x50 = 0x2FB0                                                            #
	# New ROM End Adress: 0x3000                                                                            #
	#                                                                                                       #
	# New RAM Origin    : 0x3000                                                                            #
	# New RAM Length    : 0x7FB0 - 0x2FB0 = 0x5000                                                          #
	# New RAM End Adress: 0x3000 + 0x5000 = 0x8000                                                          #
	#                                                                                                       #
	#         0x3000 |---------------------|              0x8000 |---------------------|                    #         
	#                |                     |                     |                     |                    #
	#                |                     |                     |                     |                    #
	#                |                     |                     |                     |                    #
	#                |         ROM         |                     |         RAM         |                    #
	#                |       SEGMENT       |                     |       SEGMENT       |                    #
	#                |                     |                     |                     |                    #
	#                |                     |                     |                     |                    #
	#                |                     |                     |                     |                    #
	#                |                     |                     |                     |                    #
	#           0x50 |---------------------|              0x3000 |---------------------|                    #
	#                                                                                                       #
	#########################################################################################################

	echo "Calculating new memory segments:"
	echo "--------------------------------"

	# Outputting old memory segment
	old_segment_end_adress=0x0 
	printf -v old_segment_end_adress '%#x' "$(($old_origin_hex_value + $old_length_hex_value))"

	echo -e "Old Memory Segment Origin: \t $old_origin_hex_value"
	echo -e "Old Memory Segment Length: \t $old_length_hex_value"
	echo -e "Old Memory Segment End Adress: \t $old_segment_end_adress"
	echo " "

	# Calculating new ROM memory segment 
	rom_memory_segment_start_adress=$old_origin_hex_value
	rom_memory_segment_end_adress=$input_origin_adress
	rom_memory_segment_length=0x0
	printf -v rom_memory_segment_length '%#x' "$(($rom_memory_segment_end_adress - $rom_memory_segment_start_adress))"

	echo -e "New ROM Segment Origin:     \t $rom_memory_segment_start_adress"
	echo -e "New ROM Segment Length:     \t $rom_memory_segment_length"
	echo -e "New ROM Segment End Adress: \t $rom_memory_segment_end_adress"
	echo " "

	# Calculating new RAM memory segment 
	ram_memory_segment_start_adress=$input_origin_adress
	ram_memory_segment_length=0x0
	ram_memory_segment_end_adress=0x0
	printf -v ram_memory_segment_length '%#x' "$(($old_length_hex_value - $rom_memory_segment_length))"
	printf -v ram_memory_segment_end_adress '%#x' "$(($ram_memory_segment_start_adress + $ram_memory_segment_length))"

	echo -e "New RAM Segment Origin:     \t $ram_memory_segment_start_adress"
	echo -e "New RAM Segment Length:     \t $ram_memory_segment_length"
	echo -e "New RAM Segment End Adress: \t $ram_memory_segment_end_adress"
	echo " "

	##########################################
	# Create new rom and ram memory segments #
	##########################################

	rom_name="mbROM"
	ram_name="mbRAM"

	rom_line="${rom_name} : ORIGIN = ${old_origin_hex_value}, LENGTH = ${rom_memory_segment_length}"
	ram_line="${ram_name} : ORIGIN = ${ram_memory_segment_start_adress}, LENGTH = ${ram_memory_segment_length}"

	echo "Following new segments in linker script created:"
	echo "------------------------------------------------"
	echo "$rom_line"
	echo "$ram_line"
	echo " "

	end_memory_segment_line=$((memory_line_counter+1))

	##########################################
	# Insert new rom and ram memory segments #
	##########################################

	sed -i "${end_memory_segment_line}i\ \t${ram_line}" $input_file
	sed -i "${memory_line_counter}s/.*/\t${rom_line}/" $input_file

	##################################################################
	# Replace all memory segments with ram or rom based on the lists #
	##################################################################

	rom_list=".text .text.init .rodata .srodata .sbss2 .sdata2 .note.gnu.build-id .drvcfg_sec .init .fini .init_array .fini_array .ctors .dtors .got .got1 .got2 .eh_frame .jcr .gcc_except_table"
	ram_rom_list=".data .sdata .tdata"
	ram_list="" 

	# Fill ram list with everything that is not rom or ram_rom(loadable)
	matchstr="^\.[-A-Za-z0-9._]+[ ]:|(NOLOAD)"
	non_ram_list=$(echo " ${rom_list} ${ram_rom_list} ")
	while IFS= read -r line 
	do 
		if [[ $line =~ $matchstr ]]; then
	        line=$(echo ${line} | cut -d " " -f1)
			if echo "$non_ram_list" | grep -q "[ ]${line}[ ]" ; then : ; else
				ram_list=$(echo "${ram_list} ${line}")
			fi
		fi 
	done < $input_file

	rom="} > ${rom_name}"
	ram="} > ${ram_name}"
	ram_rom="} > ${ram_name} AT > ${rom_name}"

	#################################################################################################
	# How does the following section operate?                                                       #
	#                                                                                               #
	# Let's take the above declared ram_list="bss sbss".                                            #
	# The script will search for the sections declared in the list.                                 #
	# In this case "bss" and "sbss".                                                                #
	# For that, the script will be going through the whole linker script                            #
	# and will search for the section markers.                                                      #
	# With some regex magic everything is possible.                                                 #
	# For every element the script will go through the script once. In this case 2 times.           # 
	# It will look for the line in which for example "sbss" will appear.                            #
	# Since the section is not only the .sbss part, but is a whole line,                            #
	# we will have to split up the line and do another regex check.                                 #
	# This is needed because sbss2 also exists.                                                     #
	# Meaning the "sbss" from the list will match the "sbss2" from the linkerscript                 #
	# But as soon as the "sbss2" is matched, the next regex match which will exactly try to match   #
	# for the ".sbss" string. In the case of "sbss2" this will fail, and continue looking           #
	# through the file.                                                                             #
	# After it finds the "sbss" section, it will go through the                                     #
	# section line by line until it finds the closing brackets of the section.                      #
	# These are important, as this is the line we want to change, so this line will be marked       #
	# with a line counter                                                                           #
	# After the line is marked, a simple sed will replace the line with the before declared string  #
	# "} > ram" and the script will print out a success                                             #
	# This is done for the RAM, ROM and RAM AT ROM lists.                                           #
	#################################################################################################


	###########################################
	# Replace all list elemt sections for RAM #
	###########################################

	find_ram_counter=0
	find_ram_flag=0
	find_ram_line=0
	block_ram_read=0
	change_ram_flag=0

	printf "Changing sections to ram memory input:\n"
	echo   "--------------------------------------"

	for i in $ram_list; do 
		while IFS= read -r line 
		do 
			((find_ram_counter++)) 
			if [[ $block_ram_read -eq 0 ]]; then
				if [[ $line =~ ^${i}\s* ]]; then
					IFS=' ' read -ra line_array <<< "$line"
					if [[ ${line_array[0]} =~ ^${i}$ ]]; then
						echo -e "Success, changed \t $i   \t to ram memory"
						find_ram_flag=1
						change_ram_flag=1
					fi
				fi
			fi

			if [[ find_ram_flag -eq 1 ]]; then
				if [[ $line =~ ^}+.* ]]; then
					find_ram_line=$find_ram_counter
					find_ram_flag=0
					block_ram_read=1
				fi
			fi
		done < $input_file
		
		
		if [[ $change_ram_flag -eq 1 ]]; then
			sed -i "${find_ram_line}s/.*/${ram}/" $input_file
		fi
		
		find_ram_counter=0
		find_ram_flag=0
		find_ram_line=0
		block_ram_read=0
		change_ram_flag=0
	done

	printf "\n"

	############################################
	#Replace all list element sections for ROM #
	############################################

	find_rom_counter=0
	find_rom_flag=0
	find_rom_line=0
	block_rom_read=0
	change_rom_flag=0

	printf "Changing sections to rom memory input:\n"
	echo   "--------------------------------------"

	for j in $rom_list; do 
		while IFS= read -r line 
		do 
			((find_rom_counter++))
			if [[ $block_rom_read -eq 0 ]]; then
				if [[ $line =~ ^${j}\s* ]]; then
					IFS=' ' read -ra line_rom_array <<< "$line"
					if [[ ${line_rom_array[0]} =~ ^${j}$ ]]; then
						echo -e "Success, changed \t $j   \t to rom memory"
						change_rom_flag=1
						find_rom_flag=1
					fi
				fi
			fi
			
			if [[ find_rom_flag -eq 1 ]]; then
				if [[ $line =~ ^}+.* ]]; then
					find_rom_line=$find_rom_counter
					find_rom_flag=0
					block_rom_read=1
				fi
			fi
		done < $input_file
		
		if [[ $change_rom_flag -eq 1 ]]; then
			sed -i "${find_rom_line}s/.*/${rom}/" $input_file
		fi

		find_rom_counter=0
		find_rom_flag=0
		find_rom_line=0
		block_rom_read=0
		change_rom_flag=0
	done

	printf "\n"

	##################################
	# Set ram AT rom in section list #
	##################################

	find_ram_rom_counter=0
	find_ram_rom_flag=0
	find_ram_rom_line=0
	block_ram_rom_read=0

	printf "Changing sections to ram at rom memory:\n"
	echo   "---------------------------------------"

	for n in $ram_rom_list; do 
		while IFS= read -r line
		do 
			((find_ram_rom_counter++))
			if [[ $block_ram_rom_read -eq 0 ]]; then	
				if [[ $line =~ ^${n}\s* ]]; then
					IFS=' ' read -ra line_ram_rom_array <<< "$line"
					if [[ ${line_ram_rom_array[0]} =~ ^${n}$ ]]; then 
						echo -e "Success, changed \t $n  \t to ram at rom memory"
						find_ram_rom_flag=1
					fi 
				fi
			fi 

			if [[ find_ram_rom_flag -eq 1 ]]; then
				if [[ $line =~ ^}+.* ]]; then
					find_ram_rom_line=$find_ram_rom_counter
					find_ram_rom_flag=0
					block_ram_rom_read=1
				fi
			fi
		done < $input_file

		sed -i "${find_ram_rom_line}s/.*/${ram_rom}/" $input_file

		find_ram_rom_counter=0
		find_ram_rom_flag=0
		find_ram_rom_line=0
		block_ram_rom_read=0
	done

	printf "\n"

	# Replace all other instances of the old memory name to ram
	sed -i "s/${memory_variable_name}/${ram_name}/g" $input_file

	#######################################################
	# Insert load_data_start line to data sdata and tdata #
	#######################################################

	load_data_line_counter=0
	block_load_data_read=0
	load_data_flag=0
	load_data_line=0

	printf "Inserting load_data_start at data sdata and tdata sections:\n"
	echo   "-----------------------------------------------------------"

	for c in $ram_rom_list; do
		c="${c:1}" 
		while IFS= read -r line 
		do
			((load_data_line_counter++))
			if [[ $block_load_data_read -eq 0 ]]; then	
				if [[ $line =~ ^\.${c}\s* ]]; then
					IFS=' ' read -ra load_line_array <<< "$line"
					if [[ ${load_line_array[0]} =~ ^\.${c}$ ]]; then
						load_data_flag=1
					fi 
				fi
			fi 
			
			if [[ load_data_flag -eq 1 ]]; then
				if [[ $line =~ ^.*__.*_start ]]; then
					load_data_line=$load_data_line_counter
					#echo "Line where __*_end ist: $find_line"
					load_data_flag=0
					block_load_data_read=1
				fi
			fi
		done < $input_file
		
		load_data_string="\ \ \ __load_${c}_start = LOADADDR(.${c});"
		
		sed -i "${load_data_line}i ${load_data_string}" $input_file
		echo -e "Success, inserted new line to \t\t $c section"
		load_data_flag=0
		block_load_data_read=0
		load_data_line_counter=0
	done
		
fi
