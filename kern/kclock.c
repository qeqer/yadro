/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <kern/kclock.h>

int gettime(void)
{
	nmi_disable();
	// LAB 12: your code here

	nmi_enable();
	return 0;
}

void
rtc_init(void)
{
	nmi_disable();
	// LAB 4: your code here
	outb(IO_RTC_CMND, RTC_BREG); // switch to B register of RTC IO port
	uint8_t pinb = inb(IO_RTC_DATA); // pinb as avr mc style :)
	outb(IO_RTC_DATA, pinb | RTC_PIE);

	/*
		Datasheet for 8259A

		The lower four bits (0-3) of status register A select a divider for the
		32768 Hz frequency. The resulting frequency is used for the periodic interrupt
		(IRQ 8). The system initializes these bits to 0110 binary (or 6 decimal). This
		selects a 1024 Hz frequency (and interrupt rate). Setting the lowest four bits
		to a different value changes the interrupt rate *without* interfering with the
		time keeping of the RTC/CMOS chip.

		The formula to calculate the interrupt rate is:

		freq. = 32768 >> (rate-1)
		freq. = 2 Hz => 32768 >> (15 - 1) => rate = 15 => pina | 0b1111
	*/

	outb(IO_RTC_CMND, RTC_AREG); // switch to A register of RTC IO port
	uint8_t pina = inb(IO_RTC_DATA) & 0xf0; // save only high 4 bits
	outb(IO_RTC_DATA, pina | 0b1111);

	nmi_enable();
}

uint8_t
rtc_check_status(void)
{
	// LAB 4: your code here
	outb(IO_RTC_CMND, RTC_CREG);

	return inb(IO_RTC_DATA);
}

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC_CMND, reg);
	return inb(IO_RTC_DATA);
}

void
mc146818_write(unsigned reg, unsigned datum)
{
	outb(IO_RTC_CMND, reg);
	outb(IO_RTC_DATA, datum);
}

