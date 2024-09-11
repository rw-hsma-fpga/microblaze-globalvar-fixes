#!/bin/bash

FPLAIN="\033[0m"   # ${FPLAIN}
FBOLD="\033[1m"    # ${FBOLD}
FITALIC="\033[3m"  # ${FITALIC}

. clean_build.sh

if [ -f "init_mb_globals_lib.c" ]
then
	RISCV_GCC_PATH=$(which riscv64-unknown-elf-gcc)
	RISCV_GCC_SUCCESS=$?

	if [ $RISCV_GCC_SUCCESS -eq 0 ]
	then
		echo -e "Microblaze-V compiler (${FBOLD}riscv64-unknown-elf-gcc${FPLAIN}) found."
        echo

		riscv64-unknown-elf-gcc -c -march=rv32i -mabi=ilp32 init_mb_globals_lib.c -o init_mbv_globals_lib.o
		if [ $? -eq 0 ]
		then
			echo -e "${FBOLD}riscv64-unknown-elf-gcc${FPLAIN}: Compilation succeeded."
			echo -e "${FITALIC}$(ls -l init_mbv_globals_lib.o)${FPLAIN}"
			echo

			riscv64-unknown-elf-ar  rcs libinitmbvglobals.a init_mbv_globals_lib.o
			if [ $? -eq 0 ]
			then
				echo -e "${FBOLD}riscv64-unknown-elf-ar${FPLAIN}: Library creation succeeded."
				echo -e "${FITALIC}$(ls -l libinitmbvglobals.a)${FPLAIN}"
				echo

                echo -e "If you are using the classic ${FBOLD}Vitis IDE${FPLAIN} (Eclipse-based):"
                echo -e "-------------------------------------------------------"
                echo -e "* Right-click on your application project"
                echo -e "* Choose ${FBOLD}C/C++ build settings${FPLAIN}"
                echo -e "* Go to ${FBOLD}RISC-V gcc linker${FPLAIN} > ${FBOLD}Miscellaneous${FPLAIN}"
				echo -e "* Paste the following line into ${FBOLD}Linker Flags${FPLAIN}:"
   				THISPATH=$(pwd)
				echo
				echo -e "   -Wl,-whole-archive  ${THISPATH}/libinitmbvglobals.a  -Wl,-no-whole-archive "
				echo
                echo -e "If you are using the ${FBOLD}Vitis Unified IDE${FPLAIN} (VS Code / Theia-based):"
                echo -e "---------------------------------------------------------------"
                echo -e "* Open the ${FBOLD}Settings${FPLAIN} branch in the tree view of your application project"
                echo -e "* Click on ${FBOLD}UserConfig.cmake${FPLAIN}"
                echo -e "* In the form view of ${FBOLD}UserConfig.cmake${FPLAIN}, go to ${FBOLD}Linker Settings${FPLAIN} > ${FBOLD}Miscellaneous${FPLAIN}"
				echo -e "* Paste the following line (${FITALIC}with quotes!${FPLAIN}) into the field ${FBOLD}Linker Flags${FPLAIN}:"
   				THISPATH=$(pwd)
				echo
				echo -e "   \"-Wl,-whole-archive  ${THISPATH}/libinitmbvglobals.a  -Wl,-no-whole-archive\" "
				echo
				echo -e "* If you are using the source view of ${FBOLD}UserConfig.cmake${FPLAIN}, paste the line above"
				echo -e "  (${FITALIC}with quotes!${FPLAIN}) into the parameter ${FBOLD}set(USER_LINK_OTHER_FLAGS   )${FPLAIN}"
                echo

			else
				echo -e "${FBOLD}riscv64-unknown-elf-ar${FPLAIN} ERROR: Static library creation failed."
			fi

		else
			echo -e "${FBOLD}riscv64-unknown-elf-gcc${FPLAIN} ERROR: Compilation failed."
		fi

	else
		echo -e "${FBOLD}ERROR${FPLAIN}: Could not find Microblaze-V compiler (riscv64-unknown-elf-gcc)."
		echo -e "       Please set environment variables for the AMD Microblaze toolchain."
	fi

else
	echo -e "${FBOLD}ERROR${FPLAIN}: Source file  init_mb_globals_lib.c  not found in working path."
fi


