#!/bin/bash

FPLAIN="\033[0m"   # ${FPLAIN}
FBOLD="\033[1m"    # ${FBOLD}
FITALIC="\033[3m"  # ${FITALIC}

. clean_build.sh

if [ -f "init_mb_globals_lib.c" ]
then
	MB_GCC_PATH=$(which mb-gcc)
	MB_GCC_SUCCESS=$?

	if [ $MB_GCC_SUCCESS -eq 0 ]
	then
		echo -e "Microblaze Classic compiler (${FBOLD}mb-gcc${FPLAIN}) found."
        echo

		mb-gcc -c -mlittle-endian init_mb_globals_lib.c
		if [ $? -eq 0 ]
		then
			echo -e "${FBOLD}mb-gcc${FPLAIN}: Compilation succeeded."
			echo -e "${FITALIC}$(ls -l init_mb_globals_lib.o)${FPLAIN}"
			echo

			mb-ar  rcs libinitmbglobals.a init_mb_globals_lib.o
			if [ $? -eq 0 ]
			then
				echo -e "${FBOLD}mb-ar${FPLAIN}: Library creation succeeded."
				echo -e "${FITALIC}$(ls -l libinitmbglobals.a)${FPLAIN}"
				echo

                echo -e "If you are using the classic ${FBOLD}Vitis IDE${FPLAIN} (Eclipse-based):"
                echo -e "-------------------------------------------------------"
                echo -e "* Right-click on your application project"
                echo -e "* Choose ${FBOLD}C/C++ build settings${FPLAIN}"
                echo -e "* Go to ${FBOLD}MicroBlaze gcc linker${FPLAIN} > ${FBOLD}Miscellaneous${FPLAIN}"
				echo -e "* Paste the following line into ${FBOLD}Linker Flags${FPLAIN}:"
   				THISPATH=$(pwd)
				echo
				echo -e "   -Wl,-whole-archive  ${THISPATH}/libinitmbglobals.a  -Wl,-no-whole-archive "
				echo
                echo -e "If you are using the ${FBOLD}Vitis Unified IDE${FPLAIN} (VS Code / Theia-based):"
                echo -e "---------------------------------------------------------------"
                echo -e "* Open the ${FBOLD}Settings${FPLAIN} branch in the tree view of your application project"
                echo -e "* Click on ${FBOLD}UserConfig.cmake${FPLAIN}"
                echo -e "* In the form view of ${FBOLD}UserConfig.cmake${FPLAIN}, go to ${FBOLD}Linker Settings${FPLAIN} > ${FBOLD}Miscellaneous${FPLAIN}"
				echo -e "* Paste the following line (${FITALIC}with quotes!${FPLAIN}) into the field ${FBOLD}Linker Flags${FPLAIN}:"
   				THISPATH=$(pwd)
				echo
				echo -e "   \"-Wl,-whole-archive  ${THISPATH}/libinitmbglobals.a  -Wl,-no-whole-archive\" "
				echo
				echo -e "* If you are using the source view of ${FBOLD}UserConfig.cmake${FPLAIN}, paste the line above"
				echo -e "  (${FITALIC}with quotes!${FPLAIN}) into the parameter ${FBOLD}set(USER_LINK_OTHER_FLAGS   )${FPLAIN}"
                echo

			else
				echo -e "${FBOLD}mb-ar${FPLAIN} ERROR: Static library creation failed."
			fi

		else
			echo -e "${FBOLD}mb-gcc${FPLAIN} ERROR: Compilation failed."
		fi

	else
		echo -e "${FBOLD}ERROR${FPLAIN}: Could not find Microblaze Classic compiler (mb-gcc)."
		echo -e "       Please set environment variables for the AMD Microblaze toolchain."
	fi

else
	echo -e "${FBOLD}ERROR${FPLAIN}: Source file  init_mb_globals_lib.c  not found in working path."
fi


