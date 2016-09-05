require 'formula'

class Tempwork < Formula
  VERSION = '0.1.4'

  homepage 'https://github.com/winebarrel/tempwork'
  url "https://github.com/winebarrel/tempwork/releases/download/v#{VERSION}/tempwork-v#{VERSION}-darwin-amd64.gz"
  sha256 '6bd06b5abeb3f484c5380c7c06980f6ca7d4e3dd9301bd6baf4d968d057826d5'
  version VERSION
  head 'https://github.com/winebarrel/tempwork.git', :branch => 'master'

  def install
    system "mv tempwork-v#{VERSION}-darwin-amd64 tempwork"
    bin.install 'tempwork'
  end
end
