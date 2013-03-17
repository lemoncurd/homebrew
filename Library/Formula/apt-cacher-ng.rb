require 'formula'

class AptCacherNg < Formula
  homepage 'http://www.unix-ag.uni-kl.de/~bloch/acng/'
  url 'http://ftp.debian.org/debian/pool/main/a/apt-cacher-ng/apt-cacher-ng_0.7.12.orig.tar.xz'
  sha1 '5a31062a67aea1a40e9034cd453fcf8cb8abd59d'

  depends_on 'xz' => :build
  depends_on 'cmake' => :build
  depends_on 'fuse4x' => :build

  def patches
    {
      # fixes the build to recognise osxfuse correctly
      :p0 => DATA
	 }
  end

  def install
    system 'make apt-cacher-ng'

    inreplace 'conf/acng.conf' do |s|
      s.gsub! /^CacheDir: .*/, "CacheDir: #{var}/spool/apt-cacher-ng"
      s.gsub! /^LogDir: .*/, "LogDir: #{var}/log"
    end

    # copy default config over
    etc.install_p 'conf', 'apt-cacher-ng'

    # create the cache directory
    (var/'spool/apt-cacher-ng').mkpath

    sbin.install 'build/apt-cacher-ng'
    man8.install 'doc/man/apt-cacher-ng.8'
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>OnDemand</key>
      <false/>
      <key>RunAtLoad</key>
      <true/>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/sbin/apt-cacher-ng</string>
        <string>-c</string>
        <string>#{etc}/apt-cacher-ng</string>
        <string>foreground=1</string>
      </array>
      <key>ServiceIPC</key>
      <false/>
    </dict>
    </plist>
    EOS
  end
end


__END__
--- CMakeLists.txt	2013-05-26 19:33:22.000000000 +1000
+++ CMakeLists.txt	2013-05-26 19:34:37.000000000 +1000
@@ -314,7 +314,7 @@
 #include <fuse.h>
 int main() { return 0; }
 ")
-SET(CMAKE_REQUIRED_FLAGS ${fuse_CFLAGS})
+SET(CMAKE_REQUIRED_FLAGS ${acngfs_cflags})
 CHECK_CXX_SOURCE_COMPILES("${TESTSRC}" HAVE_FUSE_25)
 
 if(fuse_FOUND AND HAVE_FUSE_25)

