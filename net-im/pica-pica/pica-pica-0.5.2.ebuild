# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="Pica Pica Messenger"
HOMEPAGE="http://picapica.im/"
SRC_URI="http://picapica.im/pica-pica-${PV}.tar.gz"

LICENSE="BSD-2"
SLOT="0"

KEYWORDS="~amd64 ~x86"
IUSE="+client server"

DEPEND=">=dev-libs/openssl-0.9.8
	
	server? ( >=dev-db/sqlite-3.7.0 )

	client? ( >x11-libs/qt-core-4.0.0
		>x11-libs/qt-gui-4.0.0
		>x11-libs/qt-sql-4.0.0[sqlite]
		virtual/pkgconfig
		x11-misc/xdg-utils 
	)"

RDEPEND="${DEPEND}"

S="${WORKDIR}/pica-pica-${PV}"

src_configure() {
    if use client && use server; then
		econf --disable-menuitem --localstatedir="/var"
	elif use client ;then
		econf --disable-node --disable-menuitem 
	elif use server; then
		econf --disable-client --localstatedir="/var"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	use server && newinitd "${FILESDIR}/pica-node-initd" pica-node
	use server && newconfd "${FILESDIR}/pica-node-confd" pica-node
}

pkg_preinst() {
	
	if use server; then
		enewuser pica-node
		fowners -R pica-node:pica-node "/var/lib/pica-node"

		dodir "/var/log/pica-node"
		fowners -R pica-node:pica-node "/var/log/pica-node"
	fi
}

pkg_postinst() {
	
	if use client; then
		xdg-icon-resource install --size 32 "${S}/pica-client/picapica-icon-sit.png" pica-client
		xdg-icon-resource install --size 22 "${S}/pica-client/picapica-icon-sit.png" pica-client
		xdg-icon-resource install --size 64 "${S}/pica-client/picapica-icon-sit.png" pica-client

		xdg-desktop-menu install "${S}/pica-client/pica-client.desktop"
	fi
	
	use server && elog "Set announced_addr value to your IP address in config file before running pica-node"
}

pkg_postrm() {
	if use client; then
		xdg-icon-resource uninstall --size 32 pica-client
		xdg-icon-resource uninstall --size 22 pica-client
		xdg-icon-resource uninstall --size 64 pica-client

		xdg-desktop-menu uninstall pica-client.desktop
	fi
}


