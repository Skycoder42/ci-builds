android {
	isEmpty(QT_OPENSSL_LIBDIR): QT_OPENSSL_LIBDIR = "$$QPMX_INSTALL_DIR/lib"
	LIBS += "-L$$QT_OPENSSL_LIBDIR" -lcrypto -lssl
	ANDROID_EXTRA_LIBS += \
		"$$QT_OPENSSL_LIBDIR/libcrypto.so" \
		"$$QT_OPENSSL_LIBDIR/libssl.so"
}

