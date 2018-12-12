OPENSSL_VERSION = 1.1.1a

android {
	compile_openssl.target = compile_openssl
	compile_openssl.commands = +$$PWD/openssl/qpmx.sh "$$OPENSSL_VERSION" "$$ANDROID_TARGET_ARCH" && touch compile_openssl
	QMAKE_EXTRA_TARGETS += compile_openssl
	PRE_TARGETDEPS += compile_openssl
		
	qpmx_static {
		TEMPLATE = aux
		install_openssl.path = $$QPMX_INSTALL/lib
		install_openssl.CONFIG += no_check_exist
		install_openssl.depends += compile_openssl
		install_openssl.files += "$$OUT_PWD/openssl-$${OPENSSL_VERSION}/libcrypto.a" \
			"$$OUT_PWD/openssl-$${OPENSSL_VERSION}/libcrypto.pc" \
			"$$OUT_PWD/openssl-$${OPENSSL_VERSION}/libcrypto.so" \
			"$$OUT_PWD/openssl-$${OPENSSL_VERSION}/libssl.a" \
			"$$OUT_PWD/openssl-$${OPENSSL_VERSION}/libssl.pc" \
			"$$OUT_PWD/openssl-$${OPENSSL_VERSION}/libssl.so"
		INSTALLS += install_openssl
	} else {
		QT_OPENSSL_LIBDIR = "$$OUT_PWD/openssl-$${OPENSSL_VERSION}"
		include($$PWD/qt_openssl.prc)
	}
}
