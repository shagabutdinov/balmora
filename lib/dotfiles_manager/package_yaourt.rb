class DotfilesManager::PackageYaourt

  attr_accessor :entry
  attr_accessor :packages

  def self.install()
    `
      command -v yaourt >/dev/null 2>&1 || {
        dir = \`pwd\`
        mkdir /tmp/yaourt-build
        cd /tmp/yaourt-build

        wget https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
        tar -xf package-query.tar.gz
        cd package-query
        makepkg
        sudo pacman -U *.xz

        wget https://aur.archlinux.org/packages/pa/package-query/yaourt.tar.gz
        tar -xf yaourt.tar.gz
        cd package-query
        makepkg
        sudo pacman -U *.xz

        rm -rf ~/.tmp-yaourt-build
        cd $dir
      }
    `
  end

  def initialize(manager)
    @manager = manager
  end

  def pull(options)
    _install()
  end

  def push(options)
    _install()
  end

  def _install()
    @manager.run('yaourt', '--noconfirm', '-S', '--needed', *@packages)
  end

end