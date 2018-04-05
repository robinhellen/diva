pkgname=diva
pkgver=0.1
pkgrel=1
arch=('x86_64')

pkgdesc='Dependency injection library for vala/glib'
depends=("${MINGW_PACKAGE_PREFIX}-libgee")
source=(*.vala Makefile.win)

build() {
	make -f Makefile.win
}

package() {
	make PREFIX=${pkgdir} install -f Makefile.win
}
md5sums=('235fd18da0e98bbed466d085e60983ca'
         '190f0174d8cc9e4b20cfa280838c7793'
         '4e841f1188f6b646d39dc3acc2681ead'
         '614851a2b3ad732612262baaf56c4cf9'
         'c7c0a9e7008861e664e51825b1a6af18'
         '606ce86a3c4a781c82bbe5e5ece45dbe'
         'bef707ef4078a1bfeac9125d53dd99d5'
         '636943623843f887092300e80ce6a3d5'
         '8555220ed4700bcf3d2be64b5deb7d03'
         '80299013990691e4d955c47ec5d58c42'
         '76af44b80f8faffb5c3bd2bd3436e59b'
         'c1ec3912a920c011357c1da35fa42d6d'
         '1416ff73f76e1860303f4081509be8c3')
