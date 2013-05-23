require 'formula'

class Libstemmer < Formula
  # upstream is constantly changing the tarball,
  # so doing checksum verification here would require
  # constant, rapid updates to this formula.
  head 'http://snowball.tartarus.org/dist/libstemmer_c.tgz'
  homepage 'http://snowball.tartarus.org/'
end

class Sphinx < Formula
  url 'https://s3-eu-west-1.amazonaws.com/rnaveiras-software/sphinx-0.9.9.tar.gz'
  homepage 'http://www.sphinxsearch.com'
  sha1 '8c739b96d756a50972c27c7004488b55d7458015'

  depends_on 'apple-gcc42'

  def install
    lstem = Pathname.pwd+'libstemmer_c'
    lstem.mkpath
    Libstemmer.new.brew { mv Dir['*'], lstem }

    args = ["--prefix=#{prefix}",
            "--disable-debug",
            "--disable-dependency-tracking",
            "--localstatedir=#{var}"]

    # always build with libstemmer support
    args << "--with-libstemmer"
    args << "--with-mysql"

    # configure script won't auto-select PostgreSQL
    args << "--with-pgsql" if `/usr/bin/which pg_config`.size > 0

    ENV['CC'] = '/usr/local/bin/gcc-4.2'
    ENV['CXX'] = '/usr/local/bin/g++-4.2'

    system "./configure", *args
    system "make install"
  end

  def caveats
    <<-EOS.undent
    Sphinx has been compiled with libstemmer support.

    Sphinx depends on either MySQL or PostreSQL as a datasource.

    You can install these with Homebrew with:
      brew install mysql
        For MySQL server.

      brew install mysql-connector-c
        For MySQL client libraries only.

      brew install postgresql
        For PostgreSQL server.

    We don't install these for you when you install this formula, as
    we don't know which datasource you intend to use.
    EOS
  end
end
