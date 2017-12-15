/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>

#ifdef CONFIG_KSPACE
.comm intr_ret_eip, 4
.comm intr_ebp_reg, 4
.comm intr_esp_reg, 4
.comm intr_cs, 4
.comm intr_eflags, 4
#endif


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps


.text

.globl _alltraps
.type _alltraps, @function;
.align 2
_alltraps:
	pushl %ds
	pushl %es
	pushal
	movl $GD_KD, %eax
	movw %ax, %ds
	movw %ax, %es
	pushl %esp 
	call trap
    jmp .

.globl clock_thdlr
.type clock_thdlr, @function;
.align 2;
#ifdef CONFIG_KSPACE
clock_thdlr:
	popl intr_ret_eip
	popl intr_cs
	popl intr_eflags
	movl %ebp, intr_ebp_reg
	movl %esp, intr_esp_reg
	movl $0x0,%ebp
	movl $(bootstacktop),%esp
	pushl $GD_KD
	pushl intr_esp_reg
	pushl intr_eflags
	pushl intr_cs
	pushl intr_ret_eip
	pushl $0
	pushl $(IRQ_OFFSET + IRQ_CLOCK)
	pushl %ds
	pushl %es

	pushl %eax
	pushl %ecx
	pushl %edx
	pushl %ebx
	pushl intr_esp_reg
	pushl intr_ebp_reg
	pushl %esi
	pushl %edi

	pushl %esp  /* trap(%esp) */
	call trap
	jmp .
#else
TRAPHANDLER_NOEC(clock_thdlr, IRQ_OFFSET + IRQ_CLOCK);
// LAB 8: Your code here.
TRAPHANDLER_NOEC(idt_handler0, T_DIVIDE);
TRAPHANDLER_NOEC(idt_handler1, T_DEBUG );
TRAPHANDLER_NOEC(idt_handler2, T_NMI);
TRAPHANDLER_NOEC(idt_handler3, T_BRKPT);
TRAPHANDLER_NOEC(idt_handler4, T_OFLOW);
TRAPHANDLER_NOEC(idt_handler5, T_BOUND);
TRAPHANDLER_NOEC(idt_handler6, T_ILLOP);
TRAPHANDLER_NOEC(idt_handler7, T_DEVICE);
TRAPHANDLER(idt_handler8, T_DBLFLT);

TRAPHANDLER(idt_handler10, T_TSS);
TRAPHANDLER(idt_handler11, T_SEGNP);
TRAPHANDLER(idt_handler12, T_STACK);
TRAPHANDLER(idt_handler13, T_GPFLT);
TRAPHANDLER(idt_handler14, T_PGFLT);

TRAPHANDLER_NOEC(idt_handler16, T_FPERR);
TRAPHANDLER(idt_handler17, T_ALIGN);
TRAPHANDLER_NOEC(idt_handler18, T_MCHK);
TRAPHANDLER_NOEC(idt_handler19, T_SIMDERR);
TRAPHANDLER_NOEC(idt_handler33, IRQ_OFFSET + IRQ_KBD);
TRAPHANDLER_NOEC(idt_handler36, IRQ_OFFSET + IRQ_SERIAL);

TRAPHANDLER_NOEC(idt_handler48, T_SYSCALL);

#endif
