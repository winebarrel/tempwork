require 'formula'

class Tempwork < Formula
  VERSION = '0.1.7'

  homepage 'https://github.com/winebarrel/tempwork'
  url "https://github.com/winebarrel/tempwork/releases/download/v#{VERSION}/tempwork-v#{VERSION}-darwin-amd64.gz"
  sha256 'ccb9392b4958408c908ec0786be88a1a1e336f5aa105abff5b7c39dba99c7ac9'
  version VERSION
  head 'https://github.com/winebarrel/tempwork.git', :branch => 'master'

  def install
    bin.install 'tempwork'
  end
end
