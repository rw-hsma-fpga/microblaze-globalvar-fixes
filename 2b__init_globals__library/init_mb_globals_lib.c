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


void __attribute__ ((constructor)) init_mb_globals(void)
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
