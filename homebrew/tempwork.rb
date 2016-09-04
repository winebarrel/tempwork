require 'formula'

class Tempwork < Formula
  VERSION = '0.1.2'

  homepage 'https://github.com/winebarrel/tempwork'
  url "https://github.com/winebarrel/tempwork/releases/download/v#{VERSION}/tempwork-v#{VERSION}-darwin-amd64.gz"
  sha256 '984c040a23b0fccecbb3639edb07c03698532d99dc7e0db6c4f934dda3eb73ba'
  version VERSION
  head 'https://github.com/winebarrel/tempwork.git', :branch => 'master'

  def install
    system "mv tempwork-v#{VERSION}-darwin-amd64 tempwork"
    bin.install 'tempwork'
  end
end
