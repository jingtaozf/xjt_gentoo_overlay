# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

WANT_AUTOMAKE="1.11"

JAVA_PKG_OPT_USE="java"
JAVA_PKG_ALLOW_VM_CHANGE="yes"
APLANCE_PV="1.7.18"
PYTHON_DEPEND="python? 2:2.6"
USE_RUBY="ruby18"
RUBY_OPTIONAL="yes"
PHP_EXT_NAME="guestfs_php"
USE_PHP="php5-2 php5-3"
PHP_EXT_OPTIONAL_USE="php"

MAIN_ECLAS="autotools bash-completion confutils versionator java-pkg-2
java-pkg-opt-2 perl-module python ruby-ng php-ext-source-r2 ghc-package"

inherit ${MAIN_ECLAS}

MY_PV_1="$(get_version_component_range 1-2)"
MY_PV_2="$(get_version_component_range 2)"

[[ $(( $(get_version_component_range 2) % 2 )) -eq 0 ]] && SD="stable" || SD="development"

DESCRIPTION="Libguestfs is a library for accessing and modifying virtual machine (VM) disk images"
HOMEPAGE="http://libguestfs.org/"
SRC_URI="http://libguestfs.org/download/${MY_PV_1}-${SD}/${P}.tar.gz
	http://rion-overlay.googlecode.com/files/${PN}-${APLANCE_PV}-x86_64.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="fuse +ocaml perl python ruby haskell readline nls php debug doc nls source javadoc"

COMMON_DEPEND="
	virtual/perl-Getopt-Long
	dev-perl/Sys-Virt
	>=app-misc/hivex-1.2.1[perl]
	dev-perl/libintl-perl
	dev-perl/String-ShellQuote
	dev-libs/libpcre
	app-arch/cpio
	dev-lang/perl
	virtual/cdrtools
	>=app-emulation/qemu-kvm-0.13
	sys-apps/fakeroot
	sys-apps/file
	app-emulation/libvirt
	dev-libs/libxml2:2
	=dev-util/febootstrap-3*
	>=sys-apps/fakechroot-2.8
	app-admin/augeas
	sys-fs/squashfs-tools
	perl? ( virtual/perl-ExtUtils-MakeMaker )
	fuse? ( sys-fs/fuse )
	readline? ( sys-libs/readline )
	doc? ( dev-libs/libxml2 )
	ocaml? ( dev-lang/ocaml
		dev-ml/xml-light
		dev-ml/findlib )
	ruby? ( dev-lang/ruby
			dev-ruby/rake )
	java? ( virtual/jre )
	haskell? ( dev-lang/ghc )"

DEPEND="${COMMON_DEPEND}
	dev-util/gperf
	java? ( >=virtual/jdk-1.6
		source? ( app-arch/zip ) )
	doc? ( app-text/po4a )"
RDEPEND="${COMMON_DEPEND}
	java? ( >=virtual/jre-1.6 )"

PHP_EXT_S="${S}/php/extension"

pkg_setup() {
	java-pkg-opt-2_pkg_setup

	python_set_active_version 2
	python_pkg_setup
	python_need_rebuild

	confutils_use_depend_all source java
	confutils_use_depend_all javadoc java

	ruby-ng_pkg_setup
	use haskell && ghc-package_pkg_setup
}

src_unpack() {
	unpack ${P}.tar.gz

	cd "${WORKDIR}"
	mkdir image
	cd image || die
	unpack libguestfs-${APLANCE_PV}-x86_64.tar.gz
	cp "${WORKDIR}"/image/usr/local/lib/guestfs/* "${S}"/appliance/ || die

	if use php; then
		local slot orig_s="${PHP_EXT_S}"
		for slot in $(php_get_slots); do
			cp -r "${orig_s}" "${WORKDIR}/${slot}"
		done
	fi
}

src_prepare() {
	epatch  "${FILESDIR}/1.8/${PV}"/*.patch
	java-pkg-opt-2_src_prepare
	eautoreconf

	if use php; then
		php-ext-source-r2_src_prepare
	fi
}

src_configure() {
	econf  \
		--with-repo=fedora-12 \
		--disable-appliance \
		--disable-daemon \
		--with-drive-if=virtio \
		--with-net-if=virtio-net-pci \
		--disable-rpath \
		$(use_enable java) \
		$(use_enable nls) \
		$(use_with readline) \
		$(use_enable ocaml-viewer) \
		$(use_enable perl) \
		$(use_enable fuse) \
		$(use_enable ocaml) \
		$(use_enable python) \
		$(use_enable ruby) \
		$(use_enable haskell) \
		$(use_with doc po4a) \
		$(use_with tools) || die

	    if use php; then
			php-ext-source-r2_src_configure
	    fi

}

src_compile() {
	emake  || die
	if use php; then
		php-ext-source-r2_src_compile
	fi
}

src_test() {
	emake -j1 check || die
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die

	dodoc BUGS HACKING README RELEASE-NOTES TODO

	if use bash-completion;then
	dobashcompletion \
	"${D}/etc"/bash_completion.d/guestfish-bash-completion.sh
	fi

	rm -fr "${D}/etc"/bash* || die

	insinto /usr/$(get_libdir)/guestfs/
	doins "${WORKDIR}/image/usr/local/lib/"guestfs/*

	find "${D}/usr"/$(get_libdir) -name \*.la -delete
	if use java; then
		java-pkg_newjar  java/${P}.jar ${PN},jar
		rm  -fr  "${D}/usr"/share/java
		rm  -fr  "${D}/usr"/share/javadoc
		if use source;then
			java-pkg_dosrc java/com/redhat/et/libguestfs/*
		fi
		if use javadoc;then
			java-pkg_dojavadoc java/api
		fi
	fi
	fixlocalpod
	python_clean_installation_image -q

	if use php; then
		php-ext-source-r2_src_install
	fi
}

pkg_preinst() {
	java-pkg-opt-2_pkg_preinst
}

pkg_postinst() {
	use hackell && ghc-package_pkg_postinst
}

pkg_prerm() {
	use hackell && ghc-package_pkg_prerm
}
