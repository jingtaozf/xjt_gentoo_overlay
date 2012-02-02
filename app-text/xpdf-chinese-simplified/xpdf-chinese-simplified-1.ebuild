# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/xpdf-chinese-simplified/Attic/xpdf-chinese-simplified-1.ebuild,v 1.9 2004/11/06 14:33:50 lanius dead $

DESCRIPTION="Chinese (simplified) support for xpdf"
SRC_URI="ftp://ftp.foolabs.com/pub/xpdf/${PN}.tar.gz"
HOMEPAGE="http://www.foolabs.com/xpdf"
LICENSE="GPL-2"
KEYWORDS="x86 ppc amd64"
IUSE=""
SLOT="0"

# DEPEND="app-text/xpdf"
DEPEND=""

S=${WORKDIR}/${PN}

src_compile() {
	cat /etc/xpdfrc > ${S}/xpdfrc
	sed 's,/usr/local/share/xpdf/,/usr/share/xpdf/,g' ${S}/add-to-xpdfrc >> ${S}/xpdfrc
}

src_install() {
	into /usr
	dodoc README
	insinto /etc
	doins xpdfrc
	insinto /usr/share/xpdf/chinese-simplified
	doins *.unicodeMap *.cid*
	insinto /usr/share/xpdf/chinese-simplified/CMap
	doins CMap/*
}
