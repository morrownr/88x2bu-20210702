#include <linux/module.h>
#include <linux/export-internal.h>
#include <linux/compiler.h>

MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};


MODULE_INFO(depends, "cfg80211");

MODULE_ALIAS("usb:v0BDApB812d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v0BDApB81Ad*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v0BDApB82Cd*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v04CAp8602d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v056Ep4011d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v0846p9055d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v0B05p1841d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v0B05p184Cd*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v0B05p1870d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v0B05p1874d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v0B05p19AAd*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v0BDAp2102d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v0E66p0025d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v13B1p0043d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v13B1p0045d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v2001p331Cd*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v2001p331Ed*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v2001p331Fd*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v20F4p805Ad*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v20F4p808Ad*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v2357p0115d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v2357p0116d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v2357p0117d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v2357p012Dd*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v2357p012Ed*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v2357p0138d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v2C4Ep0107d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v7392pB822d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v7392pC822d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v7392pD822d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v7392pE822d*dc*dsc*dp*icFFiscFFipFFin*");
MODULE_ALIAS("usb:v7392pF822d*dc*dsc*dp*icFFiscFFipFFin*");

MODULE_INFO(srcversion, "AE2D0EF012190EDC3C1D247");
