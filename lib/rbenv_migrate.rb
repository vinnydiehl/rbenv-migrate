require "optimist"
require "rubygems/commands/install_command"

module RBEMigrate
  class CLI
    def initialize
      @options = Optimist::options do
        version "rbenv-migrate #{File.read(File.expand_path("../../VERSION", __FILE__)).strip}"
        banner self.version
        banner "Usage:"
        banner "  rbenv-migrate OLD_VERSION"
        banner "\nOptions:"
        opt :version, "display version number"
        opt :help, "display this message"
        educate_on_error
      end

      Optimist::educate if ARGV.empty?

      @old_version = ARGV.first
    end

    def run
      old_gems = gemspecs_for @old_version
      current_gems = gemspecs_for RUBY_VERSION

      if (gems_to_install = old_gems - current_gems).any?
        command = Gem::Commands::InstallCommand.new.tap { |c| c.handle_options gems_to_install }
      else
        puts "Your gems in #{RUBY_VERSION} appear to be up-to-date with #{@old_version}."
        exit
      end

      begin
        command.execute
      rescue Gem::SystemExitException
        # Done
        nil
      end
    end

    private

    def gemspecs_for(version)
      gemspecs = "#{ENV['RBENV_ROOT']}/versions/#{version}/lib/ruby/gems/*/specifications/*.gemspec"
      Dir.glob(File.join gemspecs).map { |s| Gem::Specification.load(s).name }
    end
  end
end
