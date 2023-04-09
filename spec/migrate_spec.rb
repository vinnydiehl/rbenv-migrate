require "spec_helper"
require "stringio"

# Arbitrary valid old version
OLD_VERSION = "2.7.8"

def set_version(version=OLD_VERSION)
  ARGV.replace version.nil? ? [] : [version]
end

def args_should_trigger_help_screen(args)
  it "shows the help screen" do
    set_version args
    expect(Optimist).to receive :educate

    RBEMigrate::CLI.new
  end
end

RSpec.describe RBEMigrate::CLI do
  let(:cli) { described_class.new }
  let(:gemspecs) { "/path/to/versions/#{OLD_VERSION}/lib/ruby/gems/*/specifications/*.gemspec" }

  before(:each) do
    set_version

    allow(ENV).to receive(:[]).with("RBENV_ROOT").and_return("/path/to")

    allow(Dir).to receive(:[]).with("/path/to/versions/**").
      and_return instance_double(Dir, map: [OLD_VERSION, RUBY_VERSION])
    allow(Dir).to receive(:glob).with(gemspecs).
      and_return instance_double(Dir, map: %w[spec1 spec2])
  end

  describe "#initialize" do
    context "when no argument is provided" do
      args_should_trigger_help_screen nil
    end

    context "when an invalid argument is provided" do
      args_should_trigger_help_screen "not a version"
    end

    context "when the current version is given as an argument" do
      args_should_trigger_help_screen RUBY_VERSION
    end
  end

  describe "#run" do
    context "when there are no gems to migrate" do
      it "prints a message and exits" do
        allow(cli).to receive(:gemspecs_for).and_return([])
        expect { cli.run }.to output(/appear to be up-to-date/).
          to_stdout.and raise_error(SystemExit)
      end
    end

    context "when there are gems to migrate" do
      let(:old_gems)     { %w[gem1 gem2 gem3 gem4] }
      let(:current_gems) { %w[gem1      gem3     ] }
      let(:result)       { %w[     gem2      gem4] }

      let(:install_command_double) { instance_double Gem::Commands::InstallCommand, execute: true }

      before :each do
        allow(cli).to receive(:gemspecs_for).with(OLD_VERSION).and_return(old_gems)
        allow(cli).to receive(:gemspecs_for).with(RUBY_VERSION).and_return(current_gems)
        allow(Gem::Commands::InstallCommand).to receive(:new).and_return(install_command_double)
      end

      it "passes the correct gems to RubyGems" do
        expect(install_command_double).to receive(:handle_options).with(result)
        cli.run
      end
    end
  end

  describe "#gemspecs_for" do
    it "returns the names of the gemspecs for the specified version" do
      expect(cli.send(:gemspecs_for, OLD_VERSION)).to eq(%w[spec1 spec2])
    end
  end
end
