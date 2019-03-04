# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils user

if [[ ${PV} == "9999" ]] ; then
    EGIT_REPO_URI="git://github.com/antonsviridenko/pica-pica.git"
    inherit git-2 eutils autotools
    SRC_URI=""
else
	SRC_URI="http://picapica.im/pica-pica-${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Pica Pica Messenger and Node in single ebuild"
HOMEPAGE="http://picapica.im/"

LICENSE="BSD-2"
SLOT="0"

IUSE="+client server qt4 +qt5"

DEPEND=">=dev-libs/openssl-1.0.1i

	!net-im/pica-node
	!net-im/pica-client
	
	server? ( >=dev-db/sqlite-3.7.0 )

	client? (
		qt4? (
			>dev-qt/qtgui-4.0.0
			>dev-qt/qtcore-4.0.0
			>dev-qt/qtnetwork-4.0.0
			>dev-qt/qtsql-4.0.0[sqlite]
		)
		qt5? (
			>dev-qt/qtcore-5.10.0
			>dev-qt/qtwidgets-5.10.0
			>dev-qt/qtgui-5.10.0
			>dev-qt/qtnetwork-5.10.0
			>dev-qt/qtsql-5.10.0[sqlite]
		)
		virtual/pkgconfig
		x11-misc/xdg-utils
		media-sound/alsa-utils
	)"

RDEPEND="${DEPEND}"

S="${WORKDIR}/pica-pica-${PV}"

if [[ ${PV} == "9999" ]] ; then
src_prepare() {
    eautoreconf -i
}
fi

src_configure() {
    if use client && use server; then
		econf --disable-menuitem --localstatedir="/var" $(use_with qt4 qt qt4) $(use_with qt5 qt qt5)
	elif use client ;then
		econf --disable-node --disable-menuitem $(use_with qt4 qt qt4) $(use_with qt5 qt qt5)
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


