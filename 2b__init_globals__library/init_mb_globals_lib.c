/* Weak symbols: if no __load* symbols are found, no copies will be attempted. */
/* This will still compile and link without a modified linker script.          */
extern int __attribute__((weak)) __data_start;
extern int __attribute__((weak)) __data_end;
extern int __attribute__((weak)) _edata;
extern int __attribute__((weak)) __load_data_start;

extern int __attribute__((weak)) __sdata_start;
extern int __attribute__((weak)) __sdata_end;
extern int __attribute__((weak)) __load_sdata_start;

extern int __attribute__((weak)) __tdata_start;
extern int __attribute__((weak)) __tdata_end;
extern int __attribute__((weak)) __load_tdata_start;

extern int __attribute__((weak)) __sbss_start;
extern int __attribute__((weak)) __sbss_end;


static void mb_globals_load_lib(int *load, int *start, int *end) {
	while(start < end)
			*start++ = *load++;
}


void __attribute__ ((constructor)) init_mb_globals_lib(void)
{
	if (&__load_data_start) {
		if (&__data_end)
			mb_globals_load_lib((int*)&__load_data_start,
							(int*)&__data_start,
							(int*)&__data_end);
		else // MB-V scripts in 2024.1 use _edata instead of __data_end :(
			mb_globals_load_lib((int*)&__load_data_start,
							(int*)&__data_start,
							(int*)&_edata);
	}

	if (&__load_sdata_start)
		mb_globals_load_lib((int*)&__load_sdata_start,
		                (int*)&__sdata_start,
		                (int*)&__sdata_end);

	if (&__load_tdata_start)
		mb_globals_load_lib((int*)&__load_tdata_start,
		                (int*)&__tdata_start,
		                (int*)&__tdata_end);

	#ifdef __riscv
		// because AMD doesn't zero .sbss in Microblaze-V startup :(
		int* sb_ptr_ = (int*)&__sbss_start;
		int* sb_end_ = (int*)&__sbss_end;
		while(sb_ptr_ < sb_end_)
					*sb_ptr_++ = 0;
	#endif
}
