require 'formula'

class Mutt < Formula
  homepage 'http://www.mutt.org/'
  url 'ftp://ftp.mutt.org/pub/mutt/mutt-1.5.23.tar.gz'
  mirror 'http://fossies.org/linux/misc/mutt-1.5.23.tar.gz'
  sha1 '8ac821d8b1e25504a31bf5fda9c08d93a4acc862'

  head do
    url 'http://dev.mutt.org/hg/mutt#default', :using => :hg

    resource 'html' do
      url 'http://dev.mutt.org/doc/manual.html', :using => :nounzip
    end

    depends_on :autoconf
    depends_on :automake
  end

  unless Tab.for_name('signing-party').used_options.include? 'with-rename-pgpring'
    conflicts_with 'signing-party',
      :because => 'mutt installs a private copy of pgpring'
  end

  conflicts_with 'tin',
    :because => 'both install mmdf.5 and mbox.5 man pages'

  option "with-debug", "Build with debug option enabled"
  option "with-trash-patch", "Apply trash folder patch"
  option "with-s-lang", "Build against slang instead of ncurses"
  option "with-ignore-thread-patch", "Apply ignore-thread patch"
  option "with-pgp-verbose-mime-patch", "Apply PGP verbose mime patch"
  option "with-confirm-attachment-patch", "Apply confirm attachment patch"
  option "with-sidebar-patch", "Apply sidebar patch"
  option "with-gmail-server-search-patch", "Apply gmail server search patch"
  option "with-gmail-labels-patch", "Apply gmail labels patch"

  depends_on 'openssl'
  depends_on 'tokyo-cabinet'
  depends_on 's-lang' => :optional
  depends_on 'gpgme' => :optional

  patch do
    url "http://patch-tracker.debian.org/patch/series/dl/mutt/1.5.21-6.2+deb7u1/features/trash-folder"
    sha1 "6c8ce66021d89a063e67975a3730215c20cf2859"
  end if build.with? "trash-patch"

  # original source for this went missing, patch sourced from Arch at
  # https://aur.archlinux.org/packages/mutt-ignore-thread/
  patch do
    url "https://gist.github.com/mistydemeo/5522742/raw/1439cc157ab673dc8061784829eea267cd736624/ignore-thread-1.5.21.patch"
    sha1 "dbcf5de46a559bca425028a18da0a63d34f722d3"
  end if build.with? "ignore-thread-patch"

  patch do
    url "http://patch-tracker.debian.org/patch/series/dl/mutt/1.5.21-6.2+deb7u1/features-old/patch-1.5.4.vk.pgp_verbose_mime"
    sha1 "a436f967aa46663cfc9b8933a6499ca165ec0a21"
  end if build.with? "pgp-verbose-mime-patch"

  patch do
    url "https://gist.github.com/tlvince/5741641/raw/c926ca307dc97727c2bd88a84dcb0d7ac3bb4bf5/mutt-attach.patch"
    sha1 "94da52d50508d8951aa78ca4b073023414866be1"
  end if build.with? "confirm-attachment-patch"

  patch do
    url "https://github.com/sgeb/homebrew-mutt/raw/c68c72bf2824b571b56c63aee597a43fb12b7705/patches/mutt-sidebar.patch"
    sha1 "1e151d4ff3ce83d635cf794acf0c781e1b748ff1"
  end if build.with? "sidebar-patch"

  patch :p0 do
    url "https://github.com/sgeb/homebrew-mutt/raw/c68c72bf2824b571b56c63aee597a43fb12b7705/patches/patch-mutt-gmailcustomsearch.v1.patch"
    sha1 "851051cd37778d71a86510a888d4572475ed269d"
  end if build.with? "gmail-server-search-patch"

  patch do
    url "https://github.com/sgeb/homebrew-mutt/raw/231547c95422db3aa834383fd01f1464f99db228/patches/mutt-1.5.23-gmail-labels.sgeb.v1.patch"
    sha1 "93a26c66ebd602775f879278c283ee524f477195"
  end if build.with? "gmail-labels-patch"

  def install
    args = ["--disable-dependency-tracking",
            "--disable-warnings",
            "--prefix=#{prefix}",
            "--with-ssl=#{Formula['openssl'].opt_prefix}",
            "--with-sasl",
            "--with-gss",
            "--enable-imap",
            "--enable-smtp",
            "--enable-pop",
            "--enable-hcache",
            "--with-tokyocabinet",
            # This is just a trick to keep 'make install' from trying to chgrp
            # the mutt_dotlock file (which we can't do if we're running as an
            # unpriviledged user)
            "--with-homespool=.mbox"]
    args << "--with-slang" if build.with? 's-lang'
    args << "--enable-gpgme" if build.with? 'gpgme'

    if build.with? 'debug'
      args << "--enable-debug"
    else
      args << "--disable-debug"
    end

    if build.head?
      system "./prepare", *args
    else
      system "./configure", *args
    end
    system "make"
    system "make", "install"

    (share/'doc/mutt').install resource('html') if build.head?
  end
end
