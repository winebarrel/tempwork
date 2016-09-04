require 'formula'

class Tempwork < Formula
  VERSION = '0.1.2'

  homepage 'https://github.com/winebarrel/tempwork'
  url "https://github.com/winebarrel/tempwork/releases/download/v#{VERSION}/tempwork-v#{VERSION}-darwin-amd64.gz"
  sha256 '3361ea3653ebe4e003e6a13dd4a944c0c035be8634a6fc405f60cb3312b0284e'
  version VERSION
  head 'https://github.com/winebarrel/tempwork.git', :branch => 'master'

  def install
    system "mv tempwork-v#{VERSION}-darwin-amd64 tempwork"
    bin.install 'tempwork'
  end
end
