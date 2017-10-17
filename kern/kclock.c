/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <kern/kclock.h>

void
rtc_init(void)
{
	nmi_disable();
	// LAB 4: your code here
	outb(IO_RTC_CMND, RTC_BREG); //переключение на регистр B (в defin'ax)
	uint8_t B = inb(IO_RTC_DATA);
	B = B | RTC_PIE;
	outb(IO_RTC_CMND, RTC_BREG);
	outb(IO_RTC_CMND, B);
	//Изменение частоты
	outb(IO_RTC_CMND, RTC_AREG);
	uint8_t A = inb(IO_RTC_DATA);
	A = A & 0xF0;
	A = A | 0x0F;
	outb(IO_RTC_CMND, RTC_AREG);
	outb(IO_RTC_DATA, A);

	nmi_enable();
}

uint8_t
rtc_check_status(void)
{
	uint8_t status = 0;
	// LAB 4: your code here
	outb(IO_RTC_CMND, RTC_CREG);
	status = inb(IO_RTC_DATA);
	return status;
}

