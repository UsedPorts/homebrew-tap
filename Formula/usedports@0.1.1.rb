class UsedportsAT011 < Formula
  desc "View and manage active TCP/UDP ports on macOS"
  homepage "https://github.com/UsedPorts/UsedPorts"
  url "https://github.com/UsedPorts/UsedPorts/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "1cd53fc507a7cdcbcb9da32c52957207f389c1f01ee81ef33919501ea7b96923"
  license "MIT"

  bottle do
    root_url "https://github.com/UsedPorts/UsedPorts/releases/download/v0.1.1"
    # Built on the lowest supported macOS (Sequoia); Homebrew pours this same
    # arm64 bottle on newer macOS (Tahoe) too.
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "50941053eea75893e18cde97f11b7e06e111a868a8c7de502f144f2c90c0ce07"
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
