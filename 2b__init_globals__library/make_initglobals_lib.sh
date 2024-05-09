#!/bin/bash

which mb-gcc
if [ $? -eq 0 ]
then

	if [ -f "init_mb_globals_lib.c" ]
	then

		mb-gcc -c -mlittle-endian init_mb_globals_lib.c
		if [ $? -eq 0 ]
		then
			echo "Compilation succeeded."
			ls -l init_mb_globals_lib.o
			echo

			mb-ar  rcs libinitmbglobals.a init_mb_globals_lib.o
			if [ $? -eq 0 ]
			then
				echo "Library creation succeeded."
				ls -l libinitmbglobals.a
				echo

				echo "Add the following line to your Miscellaneous mb-gcc linker settings:"
				THISPATH=$(pwd)
				echo
				echo " -Wl,-whole-archive  ${THISPATH}/libinitmbglobals.a  -Wl,-no-whole-archive "
				echo

			else
				echo "ERROR: Static library creation failed."
			fi

		else
			echo "ERROR: Compilation failed."
		fi

	else
		echo "ERROR: Source file  init_mb_globals_lib.c  not found in working path."
	fi

else
	echo "ERROR: Could not find  mb-gcc ."
	echo "       Please set environment variables for the Microblaze toolchain."
fi

