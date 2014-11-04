/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0xfbc00daa */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif



static void unisim_a_3426277850_2209748606_p_0(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    unsigned char t5;

LAB0:    t1 = (t0 + 2624U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    t4 = ((unsigned char)1 != (unsigned char)1);
    if (t4 == 1)
        goto LAB7;

LAB8:    t3 = (unsigned char)0;

LAB9:    if (t3 != 0)
        goto LAB4;

LAB6:
LAB5:
LAB14:    *((char **)t1) = &&LAB15;

LAB1:    return;
LAB4:    if ((unsigned char)0 == 0)
        goto LAB10;

LAB11:    goto LAB5;

LAB7:    t5 = ((unsigned char)1 != (unsigned char)0);
    t3 = t5;
    goto LAB9;

LAB10:    t2 = (t0 + 5155);
    xsi_report(t2, 76U, (unsigned char)3);
    goto LAB11;

LAB12:    goto LAB2;

LAB13:    goto LAB12;

LAB15:    goto LAB13;

}

static void unisim_a_3426277850_2209748606_p_1(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;

LAB0:
LAB3:    t1 = (t0 + 1192U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t1 = (t0 + 3272);
    t4 = (t1 + 56U);
    t5 = *((char **)t4);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = t3;
    xsi_driver_first_trans_fast_port(t1);

LAB2:    t8 = (t0 + 3192);
    *((int *)t8) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}


extern void unisim_a_3426277850_2209748606_init()
{
	static char *pe[] = {(void *)unisim_a_3426277850_2209748606_p_0,(void *)unisim_a_3426277850_2209748606_p_1};
	xsi_register_didat("unisim_a_3426277850_2209748606", "isim/start_of_packet_tb_isim_beh.exe.sim/unisim/a_3426277850_2209748606.didat");
	xsi_register_executes(pe);
}
