# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

PYTHON_DEPEND="2:2.4"

inherit distutils eutils

DESCRIPTION="A cross-platform Enterprise Messaging system which implements the Advanced Message Queuing Protocol"
HOMEPAGE="http://qpid.apache.org"
SRC_URI="http://mirror.bjtu.edu.cn/apache/qpid/${PV}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""
KEYWORDS="amd64 x86"

RDEPEND="net-misc/qpid-cpp"

S="${WORKDIR}/qpid-${PV}/python"

src_prepare() {
	epatch "${FILESDIR}/qpid-python-${PV}-specs.patch"
}
