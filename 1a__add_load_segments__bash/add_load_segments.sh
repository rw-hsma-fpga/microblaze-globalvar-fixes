#!/bin/bash

#################################
# Checking the input Parameters #
#################################

if [[ -z "$1" ]]; then
	echo "Input File is missing!" 
	echo "Usage ./add_load_segments.sh <inputfile>"
	exit 1
fi

if ! [[ -f "$1" ]]; then
	echo "Input File doesn't exist!"
	exit 1
fi 

input_file=$1

echo "File to change: $input_file"
echo "------------------------------------"
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
					#echo "First section Line: $first_section_line"
					flag=1
				fi
			fi
		fi
		
		# Find the line where the __*_end pointer is
		if [[ flag -eq 1 ]]; then
			if [[ $line =~ ^.*__.*_end ]]; then
				find_line=$line_counter
				#echo "Line where __*_end ist: $find_line"
				flag=0
				block_read=1
				end_flag=1
			fi
		fi
		
		# Find the last line of the section
		if [[ end_flag -eq 1 ]]; then
			if [[ $line =~ ^}+.* ]]; then
				end_line=$line_counter
				#echo "End line is at: $end_line"
				#echo " "
				end_flag=0
			fi
		fi
		
	done < $input_file
	
	# Construct Strings that are being inserted into the input file
	section_start_string=".$i : AT ( __${i}_end) {"
	align_string="\ \ \ . = ALIGN(4);"
	provide_string="PROVIDE (__load_${i}_start = LOADADDR(.${i}));"
	
	# Input the Strings
	sed -i "${end_line}a ${provide_string}" $input_file
	sed -i "${first_section_line}s/.*/${section_start_string}/" $input_file
	sed -i "${find_line}i ${align_string}" $input_file
	
	# Some logical outputs for the user
	echo "For ${i}:"
	echo "-------------"
	echo "Line of first section: ${first_section_line}"
	echo "First section line changed to: ${section_start_string}"
	echo "Line with __${i}_end found: ${find_line}"
	echo "Line insert above: ${align_string}"
	echo "Last line of ${i} section found: ${end_line}"
	echo "Line insert below: ${provide_string}"
	echo " "
	
	# Reset counter and flag variables
	line_counter=0
	flag=0
	find_line=0
	block_read=0
done
	



