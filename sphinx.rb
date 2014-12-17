require 'formula'

class Sphinx < Formula
  url 'https://s3-eu-west-1.amazonaws.com/rnaveiras-software/sphinx-0.9.9.tar.gz'
  homepage 'http://www.sphinxsearch.com'
  sha1 '8c739b96d756a50972c27c7004488b55d7458015'

  depends_on 'homebrew/dupes/apple-gcc42'

  resource 'stemmer' do
    url 'https://s3-eu-west-1.amazonaws.com/rnaveiras-software/libstemmer_c.tgz'
    sha1 '6645992e5a5023dfd7eecf99fbcc58ec8b41facf'
    # homepage 'http://snowball.tartarus.org/'
  end

  fails_with :llvm do
    build 2334
    cause "ld: rel32 out of range in _GetPrivateProfileString from /usr/lib/libodbc.a(SQLGetPrivateProfileString.o)"
  end

  fails_with :clang do
    build 421
    cause "sphinxexpr.cpp:1802:11: error: use of undeclared identifier 'ExprEval'"
  end

  def install
    # setting ad-hoc GCC from apple-gcc42
    ENV['CC'] = '/usr/local/bin/gcc-4.2'
    ENV['CXX'] = '/usr/local/bin/g++-4.2'
    ENV['MACOSX_DEPLOYMENT_TARGET'] = '10.9'

    ENV['CFLAGS']   = '-arch x86_64'
    ENV['CCFLAGS']  = '-arch x87_64'
    ENV['CXXFLAGS'] = '-arch x86_64'

    resource('stemmer').stage do
      system "cp -r . #{buildpath}/libstemmer_c/ "
    end

    args = ["--prefix=#{prefix}",
            "--disable-debug",
            "--disable-dependency-tracking",
            "--localstatedir=#{var}"]

    # always build with libstemmer support
    args << "--with-libstemmer"
    args << "--with-mysql"

    # configure script won't auto-select PostgreSQL
    args << "--with-pgsql" if `/usr/bin/which pg_config`.size > 0

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
