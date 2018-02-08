class X8664PcElfGcc < Formula
  desc "The GNU Compiler Collection for cross-compiling to x86_64-pc-elf"
  homepage "https://gcc.gnu.org"
  url "https://ftpmirror.gnu.org/gcc/gcc-7.3.0/gcc-7.3.0.tar.gz"
  mirror "https://ftp.gnu.org/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.gz"
  sha256 "fa06e455ca198ddc11ea4ddf2a394cf7cfb66aa7e0ab98cc1184189f1d405870"

  option "without-cxx", "Don't build the g++ compiler"

  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"

  depends_on "x86_64-pc-elf-binutils"

  # Build-only dependencies
  depends_on "autoconf" => :build
  depends_on "automake" => :build


  def install
    # The C compiler is always built, C++ can be disabled
    languages = %w[c]
    languages << "c++" if build.with? "cxx"
    binutils = Formula["x86_64-pc-elf-binutils"]

    ENV['PATH'] += ":#{binutils.prefix/"bin"}"

    mkdir "build" do
      system "../configure", "--target=x86_64-pc-elf",
                             "--prefix=#{prefix}",
                             "--enable-languages=#{languages.join(",")}",

                             "--disable-nls",
                             "--disable-werror",

                             "--without-headers",

                             # link as and ld from cross-compiled binutils
                             "--with-gnu-as",
                             "--with-gnu-ld",
                             "--with-ld=#{binutils.opt_bin/"x86_64-pc-elf-ld"}",
                             "--with-as=#{binutils.opt_bin/"x86_64-pc-elf-as"}",

                             "--with-gmp=#{Formula["gmp"].opt_prefix}",
                             "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
                             "--with-mpc=#{Formula["libmpc"].opt_prefix}"

      ENV.deparallelize
      system "make", "all-gcc"
      system "make", "all-target-libgcc"
      FileUtils.ln_sf binutils.prefix/"x86_64-pc-elf", prefix/"x86_64-pc-elf"
      system "make", "install-gcc"
      system "make", "install-target-libgcc"
    end
    # info and man7 files conflict with native gcc
    info.rmtree
    man7.rmtree
  end

  test do
    (testpath/"hello.c").write <<-EOS.undent
      int main()
      {
          return 0;
      }
      EOS
    system "#{bin}/x86_64-pc-elf-gcc", (testpath/"hello.c")
  end
end
