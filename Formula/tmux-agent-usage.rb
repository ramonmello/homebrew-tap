class TmuxAgentUsage < Formula
  desc "AI coding agent subscription usage for the tmux status line"
  homepage "https://github.com/ramonmello/tmux-agent-usage"
  url "https://github.com/ramonmello/tmux-agent-usage/archive/f567a75c6a1e969cb1a58cbe659a36e30c1733f3.tar.gz"
  version "0.1.0"
  sha256 "c5b5dd238336850c70f4e1fabe2f6b845c218d04cb082ef0988af1cc50ff88cc"
  license "MIT"

  depends_on "rust" => :build
  depends_on "tmux"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    ENV["XDG_CACHE_HOME"] = (testpath/"cache").to_s
    ENV["XDG_CONFIG_HOME"] = (testpath/"config").to_s
    ENV["XDG_DATA_HOME"] = (testpath/"data").to_s
    ENV["CLAUDE_CONFIG_DIR"] = (testpath/"claude").to_s
    ENV["CODEX_HOME"] = (testpath/"codex").to_s
    ENV["TZ"] = "UTC0"

    assert_equal "–", shell_output("#{bin}/tmux-agent-usage status claude")
    assert_equal "–", shell_output("#{bin}/tmux-agent-usage status codex")
    payload = '{"session_id":"homebrew-test","rate_limits":{}}'
    assert_equal payload, pipe_output("#{bin}/tmux-agent-usage claude-tap --no-record -- cat", payload, 0)
  end
end
