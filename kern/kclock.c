/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <kern/kclock.h>

void
rtc_init(void)
{
	nmi_disable();
	// LAB 4: your code here	
	outb(IO_RTC_CMND, RTC_BREG);
	uint8_t regB = inb(IO_RTC_DATA);
	regB = regB | RTC_PIE;
	outb(IO_RTC_CMND, RTC_BREG);
	outb(IO_RTC_DATA, regB);
	//меняем частоту часов
	outb(IO_RTC_CMND, RTC_AREG);
	uint8_t regA = inb(IO_RTC_DATA);
	regA = regA & 0xF0;
	regA = regA | 0x0F;
	outb(IO_RTC_CMND, RTC_AREG);
	outb(IO_RTC_DATA, regA);
	
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

