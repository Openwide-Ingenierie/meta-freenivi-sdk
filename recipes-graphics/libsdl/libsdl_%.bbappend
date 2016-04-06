DEPENDS_class-nativesdk = "virtual/nativesdk-libx11 nativesdk-libxrandr nativesdk-libxrender nativesdk-libxext"

EXTRA_OECONF_class-nativesdk += " --disable-esd"
PACKAGECONFIG_class-nativesdk = "x11"
