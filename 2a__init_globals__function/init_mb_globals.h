#ifndef INIT_MB_GLOBALS
#define INIT_MB_GLOBALS


/*  include this in your main() source with  #include "init_mb_globals.h"  */
/*  init_mb_globals();  should be your first statement in main()           */


extern int __attribute__((weak)) __data_start;
extern int __attribute__((weak)) __data_end;
extern int __attribute__((weak)) __load_data_start;

extern int __attribute__((weak)) __sdata_start;
extern int __attribute__((weak)) __sdata_end;
extern int __attribute__((weak)) __load_sdata_start;

extern int __attribute__((weak)) __tdata_start;
extern int __attribute__((weak)) __tdata_end;
extern int __attribute__((weak)) __load_tdata_start;


static void mb_globals_load(int *load, int *start, int *end) {
	while(start < end)
			*start++ = *load++;
}


void init_mb_globals(void)
{

	if (&__load_data_start)
		mb_globals_load((int*)&__load_data_start,
		                (int*)&__data_start,
		                (int*)&__data_end);

	if (&__load_sdata_start)
		mb_globals_load((int*)&__load_sdata_start,
		                (int*)&__sdata_start,
		                (int*)&__sdata_end);

	if (&__load_tdata_start)
		mb_globals_load((int*)&__load_tdata_start,
		                (int*)&__tdata_start,
		                (int*)&__tdata_end);

}


#endif // INIT_MB_GLOBALS
