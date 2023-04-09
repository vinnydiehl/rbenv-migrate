Gem::Specification.new do |gem|
  gem.name = "rbenv-migrate"
  gem.version = File.read(File.expand_path("../VERSION", __FILE__)).strip

  gem.author = "Vinny Diehl"
  gem.email = "vinny.diehl@gmail.com"
  gem.homepage = "https://github.com/vinnydiehl/rbenv-migrate"

  gem.license = "MIT"

  gem.summary = "Transfer your gems from old rbenv installs."
  gem.description = "Installs all of your gems from an old version of Ruby so that you may uninstall it."

  gem.bindir = "bin"
  gem.executables = %w[rbenv-migrate]
  gem.require_paths = %w[lib]
  gem.test_files = Dir["spec/**/*"]
  gem.files = `git ls-files -z`.split "\x0"

  gem.required_ruby_version = "~> 3.0"

  gem.add_dependency "optimist", "~> 3.0"
  gem.add_development_dependency "rake", "~> 13.0"
  gem.add_development_dependency "rspec", "~> 3.12"
  gem.add_development_dependency "fuubar", "~> 2.5"
end
