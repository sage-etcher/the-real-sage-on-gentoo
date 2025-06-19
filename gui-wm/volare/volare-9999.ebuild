# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit fcaps meson

DESCRIPTION="A tiling, tabbed, notion-like wayland compositor (based on Sway)"
HOMEPAGE="https://codeberg.org/raboof/volare"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://codeberg.org/raboof/volare.git"
else
	SRC_URI="https://codeberg.org/raboof/volare/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64 ~loong ~ppc64 ~riscv ~x86"
	S="${WORKDIR}/${PN}"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+man +volarebar +volarenag tray wallpapers X"
REQUIRED_USE="tray? ( volarebar )"

DEPEND="
	>=dev-libs/json-c-0.13:0=
	>=dev-libs/libinput-1.26.0:0=
	virtual/libudev
	sys-auth/seatd:=
	dev-libs/libpcre2
	>=dev-libs/wayland-1.21.0
	x11-libs/cairo
	>=x11-libs/libxkbcommon-1.5.0:0=
	x11-libs/pango
	x11-libs/pixman
	media-libs/libglvnd
	volarebar? ( x11-libs/gdk-pixbuf:2 )
	tray? ( || (
		sys-apps/systemd
		sys-auth/elogind
		sys-libs/basu
	) )
	wallpapers? ( gui-apps/swaybg[gdk-pixbuf(+)] )
	X? (
		x11-libs/libxcb:0=
		x11-libs/xcb-util-wm
	)
"
# x11-libs/xcb-util-wm needed for xcb-iccm
if [[ ${PV} == 9999 ]]; then
	DEPEND+="~gui-libs/wlroots-9999:=[X=]"
else
	DEPEND+="
		gui-libs/wlroots:0.18[X=]
	"
fi
RDEPEND="
	${DEPEND}
	x11-misc/xkeyboard-config
"
BDEPEND="
	>=dev-libs/wayland-protocols-1.24
	>=dev-build/meson-0.60.0
	virtual/pkgconfig
"
if [[ ${PV} == 9999 ]]; then
	BDEPEND+="man? ( ~app-text/scdoc-9999 )"
else
	BDEPEND+="man? ( >=app-text/scdoc-1.9.2 )"
fi

FILECAPS=(
	cap_sys_nice usr/bin/${PN} # bug 919298
)

src_configure() {
	local emesonargs=(
		$(meson_feature man man-pages)
		$(meson_feature tray)
		$(meson_feature volarebar gdk-pixbuf)
		$(meson_use volarenag swaynag)
		$(meson_use volarebar swaybar)
		$(meson_use wallpapers default-wallpaper)
		-Dfish-completions=true
		-Dzsh-completions=true
		-Dbash-completions=true
	)

	meson_src_configure
}
