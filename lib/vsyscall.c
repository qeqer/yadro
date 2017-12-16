#include <inc/vsyscall.h>
#include <inc/lib.h>

static inline int32_t
vsyscall(int num)
{
	// LAB 12: Your code here.
	if (num >= NVSYSCALLS || num < 0) {
		panic("invalid vsyscall number %d", num);
	}
	return vsys[num];
}

int vsys_gettime(void)
{
	return vsyscall(VSYS_gettime);
}