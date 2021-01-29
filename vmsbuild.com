$! Build app for OpenVMS.

$ COPY config_vms.h config.h
$ CC/FLOAT=IEEE/IEEE_MODE=DENORM/ARCH=HOST cmatrix.c
$ LINK cmatrix.obj
