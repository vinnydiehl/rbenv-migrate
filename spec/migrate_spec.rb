require "spec_helper"

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
      let(:install_command_double) { instance_double Gem::Commands::InstallCommand, execute: true }

      before :each do
        allow(cli).to receive(:gemspecs_for).with(OLD_VERSION).and_return(old_gems)
        allow(cli).to receive(:gemspecs_for).with(RUBY_VERSION).and_return(current_gems)
        allow(Gem::Commands::InstallCommand).to receive(:new).and_return(install_command_double)
      end

      context "when some gems are already installed on the target version" do
        let(:old_gems_names)     { %w[gem1 gem2 gem3 gem4] }
        let(:current_gems_names) { %w[gem1      gem3     ] }
        let(:result)             { %w[     gem2      gem4] }

        %i[old_gems current_gems].each do |var|
          let var do
            send(:"#{var}_names").map do |name|
              Gem::Specification.new do |gem|
                gem.name = name
                gem.version = "0.1"
                gem.required_ruby_version = ">= #{OLD_VERSION}"
              end
            end
          end
        end

        it "passes the correct gems to RubyGems" do
          expect(install_command_double).to receive(:handle_options).with(result)
          expect { cli.run }.not_to output(/skipping/).to_stdout
        end
      end

      context "when an old gem is incompatible" do
        let(:current_gems) { [] }
        let :old_gems do
          %w[gem1 gem2 gem3].each_with_index.map do |name, i|
            Gem::Specification.new do |gem|
              gem.name = name
              gem.version = "0.1"
              # First one will be skipped
              gem.required_ruby_version = "#{i == 0 ? '~>' : '>='} #{OLD_VERSION}"
            end
          end
        end

        let(:result) { %w[gem2 gem3] }

        it "passes the correct gems to RubyGems" do
          expect(install_command_double).to receive(:handle_options).with(result)
          cli.run
        end

        it "outputs that it is skipping that gem" do
          allow(install_command_double).to receive(:handle_options).with(result)
          expect { cli.run }.to output(/skipping/).to_stderr
        end
      end
    end
  end

  describe "#gemspecs_for" do
    it "returns the gemspecs for the specified version" do
      expect(cli.send(:gemspecs_for, OLD_VERSION)).to eq(%w[spec1 spec2])
    end
  end
end
