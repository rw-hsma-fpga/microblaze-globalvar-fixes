#!/bin/bash

#################################
# Checking the input Parameters #
#################################

ABORT=0

if [[ -z "$1" ]]; then
	echo "Input File is missing!" 
	echo "Usage ./add_load_sections.sh <inputfile>"
	ABORT=1
fi

if ! [[ -f "$1" ]]; then
	echo "Input File doesn't exist!"
	ABORT=1
fi 


if [[ ABORT -eq 0 ]]
then
	input_file=$1

	echo "File to change: $input_file"
	echo "------------------------------------"
	echo " "

	###################################
	# Create copy of old linkerscript #
	###################################

	cp $input_file "${input_file}.old"
	echo "$input_file saved to ${input_file}.old"
	echo " "

	##########################################
	# Declare all counter and flag variables #
	##########################################

	section_list="data sdata tdata"
	first_section_line=""
	line_counter=0
	flag=0
	find_line=0
	block_read=0
	end_flag=0
	end_memory_line=""
	empty_line="\ "
	first_line=""

	######################################################
	# Go through input file and find all lines to change #
	######################################################

	for i in $section_list; do
		while IFS= read -r line
		do	
			((line_counter++))
			
			# Find the first line of the section
			if [[ $block_read -eq 0 ]]; then
				if [[ $line =~ ^\.${i}\s* ]]; then
					IFS=' ' read -ra line_array <<< "$line"
					if [[ ${line_array[0]} =~ ^.${i}$ ]]; then
						first_section_line=$line_counter
						first_line=$line
						#echo "First section Line: $first_section_line"
						flag=1
					fi
				fi
			fi
			
			# Find the last line of the section
			if [[ flag -eq 1 ]]; then
				if [[ $line =~ ^}+.* ]]; then
					end_line=$line_counter
					end_memory_line=$line
					#echo "End line is at: $end_line"
					#echo " "
					flag=0
				fi
			fi
			
		done < $input_file
		
		# Construct Strings that are being inserted into the input file
		section_start_string=".$i : AT ( __load_${i}_start) {"

		# Construct new Section
		new_section_first_line=".load_${i} (NOLOAD) : {"
		next_line_one="\ \ \ . = ALIGN(4);"
		next_line_two="\ \ \ __load_${i}_start = .;"
		next_line_three="\ \ \ . += SIZEOF(.${i});"

		# Input the Strings
		sed -i "${first_section_line}s/.*/${section_start_string}/" $input_file
		sed -i "${end_line}s/.*/${end_memory_line}/" $input_file
		sed -i "${end_line}a ${end_memory_line}" $input_file
		sed -i "${end_line}a ${next_line_three}" $input_file
		sed -i "${end_line}a ${next_line_two}" $input_file
		sed -i "${end_line}a ${next_line_one}" $input_file
		sed -i "${end_line}a ${new_section_first_line}" $input_file
		sed -i "${end_line}a ${empty_line}" $input_file

		# Output for the User
		echo "For ${i}"
		echo "-------------"
		echo "First line at ${first_section_line} of section: ${first_line}"
		echo "Line ${first_section_line} changed to: ${section_start_string}"
		echo "New Section .load_${i} inserted below section .${i}"
		echo " "
		
		# Reset counter and flag variables
		line_counter=0
		flag=0
		find_line=0
		block_read=0
	done
		
fi
