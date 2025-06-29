# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8

inherit autotools desktop git-r3

if [[ ${PV} == "9999" ]] ; then
    EGIT_REPO_URI="https://github.com/antonsviridenko/pica-pica.git"
    SRC_URI=""
else
	SRC_URI="http://picapica.im/pica-pica-${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Pica Pica Messenger and Node"
HOMEPAGE="http://picapica.im/"

LICENSE="GPL-3"
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
		dev-qt/qtchooser
	)"

RDEPEND="${DEPEND}
	node? (
			acct-user/pica-node
			acct-group/pica-node
		)"

S="${WORKDIR}/pica-pica-${PV}"

if [[ ${PV} == "9999" ]] ; then
src_prepare() {
    eapply_user
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
	domenu "${S}/pica-client/pica-client.desktop"
	newicon -s 16 "${S}/pica-client/icons/icon_16x16.png" pica-client.png
	newicon -s 32 "${S}/pica-client/icons/icon_32x32.png" pica-client.png
	newicon -s 48 "${S}/pica-client/icons/icon_48x48.png" pica-client.png
	newicon -s 256 "${S}/pica-client/picapica-icon-fly.png" pica-client.png
}

pkg_preinst() {

	if use node; then
		fowners -R pica-node:pica-node "/var/lib/pica-node"

		dodir "/var/log/pica-node"
		fowners -R pica-node:pica-node "/var/log/pica-node"
	fi
}

pkg_postinst() {

	use node && elog "Set the announced_addr value to your IP address in a config file before running the pica-node"
}


