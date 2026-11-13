# Run a formula's fetch/install/test methods without a Homebrew installation.
# This deliberately small DSL is not a substitute for brew audit/style/install.
#
# Usage: ruby test/formula_harness.rb FORMULA ROOT EXPECTED_VERSION
# Run from the plugin source directory; see test/check-formula.
require "fileutils"
require "json"
require "open3"
require "pathname"

class Formula
  class << self
    attr_reader :metadata, :dependencies, :network_denied

    def inherited(formula)
      formula.instance_variable_set(:@metadata, {})
      formula.instance_variable_set(:@dependencies, [])
    end

    %i[desc homepage url version sha256 license].each do |name|
      define_method(name) { |value| @metadata[name] = value }
    end

    def depends_on(value)
      @dependencies << value
    end

    def deny_network_access!
      @network_denied = true
    end

    def test(&block)
      define_method(:run_formula_test, &block)
    end
  end

  attr_reader :prefix, :testpath, :commands

  def initialize(root)
    @prefix = root/"prefix"
    @testpath = root/"formula-test"
    @commands = []
    testpath.mkpath
  end

  def bin
    prefix/"bin"
  end

  # Equivalent locked/offline/root arguments to the Homebrew helpers. Cargo is
  # real and all provider paths are disposable; no dependency resolution changes.
  def std_cargo_fetch_args
    ["--locked"]
  end

  def std_cargo_args
    ["--locked", "--root=#{prefix}", "--path=.", "--offline"]
  end

  def system(*arguments)
    commands << arguments
    raise "failed: #{arguments.inspect}" unless Kernel.system(*arguments)
  end

  def assert_equal(expected, actual)
    raise "expected #{expected.inspect}, got #{actual.inspect}" unless expected == actual
  end

  def shell_output(command)
    output(command, "", 0)
  end

  def pipe_output(command, input, expected_status)
    output(command, input, expected_status)
  end

  def output(command, input, expected_status)
    stdout, stderr, status = Open3.capture3(command, :stdin_data => input)
    assert_equal(expected_status, status.exitstatus)
    raise "unexpected stderr: #{stderr}" unless stderr.empty?

    stdout
  end
end

load ARGV.fetch(0)
root = Pathname.new(ARGV.fetch(1))
formula = TmuxAgentUsage.new(root)
formula.fetch
formula.install
Dir.chdir(formula.testpath) do
  ENV["HOME"] = formula.testpath.to_s
  formula.run_formula_test
end
def check(condition, message)
  raise message unless condition
end

expected_version = ARGV.fetch(2)
check(TmuxAgentUsage.metadata[:version] == expected_version,
      "formula version #{TmuxAgentUsage.metadata[:version]} != #{expected_version}")
check(TmuxAgentUsage.metadata[:license] == "MIT", "license must be MIT")
check(TmuxAgentUsage.dependencies == [{ "rust" => :build }, "tmux"],
      "unexpected dependencies: #{TmuxAgentUsage.dependencies.inspect}")
check(TmuxAgentUsage.network_denied, "the formula must deny network access")
methods = TmuxAgentUsage.instance_methods(false).map(&:to_s).sort
check(methods == %w[fetch install run_formula_test],
      "the formula must not add post_install or an updater: #{methods.inspect}")
check(formula.commands == [
  ["cargo", "fetch", "--locked"],
  ["cargo", "install", "--locked", "--root=#{formula.prefix}", "--path=.", "--offline"],
], "unexpected commands: #{formula.commands.inspect}")
check((formula.bin/"tmux-agent-usage").file?, "no installed executable")
puts "formula ok: #{formula.bin/"tmux-agent-usage"}"
