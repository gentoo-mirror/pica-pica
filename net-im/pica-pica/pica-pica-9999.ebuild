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

LICENSE="GPL-3+"
SLOT="0"

IUSE="+client node qt4 +qt5 upnp"

DEPEND=">=dev-libs/openssl-1.0.2r
	upnp? ( >=net-libs/miniupnpc-2.0 )
	!net-im/pica-node
	!net-im/pica-client

	node? (
			>=dev-db/sqlite-3.7.0
			>=dev-libs/libevent-2.1.6
		)

	client? (
		qt4? (
			>dev-qt/qtgui-4.0.0
			>dev-qt/qtcore-4.0.0
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
	qtflags="--with-qt=qt5"
	if use qt5; then
		qtflags=$(use_with qt5 qt qt5)
	elif use qt4; then
		qtflags=$(use_with qt4 qt qt4)
	fi

	econf $(use_with upnp miniupnpc)  $(use_enable client) $(use_enable node) $qtflags
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	use node && newinitd "${FILESDIR}/pica-node-initd" pica-node
	use node && newconfd "${FILESDIR}/pica-node-confd" pica-node
}

pkg_preinst() {

	if use node; then
		enewuser pica-node
		fowners -R pica-node:pica-node "/var/lib/pica-node"

		dodir "/var/log/pica-node"
		fowners -R pica-node:pica-node "/var/log/pica-node"
	fi
}

pkg_postinst() {

	if use client; then
		xdg-icon-resource install --size 48 "${S}/pica-client/icons/icon_48x48.png" pica-client
		xdg-icon-resource install --size 32 "${S}/pica-client/icons/icon_32x32.png" pica-client
		xdg-icon-resource install --size 16 "${S}/pica-client/icons/icon_16x16.png" pica-client
		xdg-icon-resource install --size 256 "${S}/pica-client/picapica-icon-fly.png" pica-client

		xdg-desktop-menu install "${S}/pica-client/pica-client.desktop"
	fi

	use node && elog "Set announced_addr value to your IP address in config file before running pica-node"
}

pkg_postrm() {
	if use client; then
		xdg-icon-resource uninstall --size 32 pica-client
		xdg-icon-resource uninstall --size 22 pica-client
		xdg-icon-resource uninstall --size 64 pica-client

		xdg-icon-resource uninstall --size 16 pica-client
		xdg-icon-resource uninstall --size 48 pica-client
		xdg-icon-resource uninstall --size 256 pica-client
		xdg-desktop-menu uninstall pica-client.desktop
	fi
}


