# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

AUTOTOOLS_IN_SOURCE_BUILD=1
inherit autotools-utils

DESCRIPTION="Fedora bootstrap scripts"
HOMEPAGE="http://people.redhat.com/~rjones/febootstrap/"
SRC_URI="http://people.redhat.com/~rjones/febootstrap/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-lang/ocaml[ocamlopt]
	dev-ml/findlib
	dev-lang/perl
	=app-arch/rpm-4*
	>=sys-apps/yum-3.2.21
	sys-fs/e2fsprogs
	sys-libs/e2fsprogs-libs
	=sys-apps/module-init-tools-3.5"
# Spanki bug

DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
}
