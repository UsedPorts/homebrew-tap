class Usedports < Formula
  desc "View and manage active TCP/UDP ports on macOS"
  homepage "https://github.com/UsedPorts/UsedPorts"
  url "https://github.com/UsedPorts/UsedPorts/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "9ebb446d443afcf4d81adb130bc364ae89b03f50edce94a91eada6b3cd28f64d"
  license "MIT"

  bottle do
    root_url "https://github.com/UsedPorts/UsedPorts/releases/download/v0.1.4"
    # Built on the lowest supported macOS (Sequoia); Homebrew pours this same
    # arm64 bottle on newer macOS (Tahoe) too.
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a6bdac2d3939496d0ee754b277d51020610c07a931eb2da4a0529aa1882b052e"
  end

  depends_on xcode: ["16.0", :build]

  depends_on "xcodegen" => :build
  depends_on arch: :arm64
  depends_on macos: :sequoia

  def install
    system "xcodegen", "generate"
    xcodebuild "-project", "UsedPorts.xcodeproj",
               "-scheme", "UsedPorts",
               "-configuration", "Release",
               "-derivedDataPath", "build",
               "CODE_SIGN_IDENTITY=-",
               "CODE_SIGNING_REQUIRED=NO",
               "CODE_SIGNING_ALLOWED=NO",
               "build"
    prefix.install "build/Build/Products/Release/UsedPorts.app"
    (bin/"usedports").write <<~EOS
      #!/bin/bash
      APP="#{prefix}/UsedPorts.app"
      DEST="$HOME/Applications/UsedPorts.app"
      rm -rf "$DEST" 2>/dev/null
      cp -R "$APP" "$DEST" 2>/dev/null
      open "${DEST:-$APP}"
    EOS
  end

  def caveats
    <<~EOS
      UsedPorts.app is installed into the Homebrew prefix. Run `usedports` to
      copy it into ~/Applications and launch it. Because Homebrew installs are
      not quarantined, there is no Gatekeeper "Open Anyway" prompt.
    EOS
  end

  test do
    assert_path_exists prefix/"UsedPorts.app"
  end
end
