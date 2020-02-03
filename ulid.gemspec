lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ulid/version'

Gem::Specification.new do |spec|
  spec.name          = 'ulid'
  spec.version       = ULID::VERSION
  spec.authors       = ['Rafael Sales']
  spec.email         = ['rafaelcds@gmail.com']
  spec.summary       = 'Universally Unique Lexicographically Sortable Identifier implementation for Ruby'
  spec.homepage      = 'https://github.com/rafaelsales/ulid'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.post_install_message = '
ulid gem needs to install sysrandom gem if you use Ruby 2.4 or older.
Execute `gem install sysrandom` or add `gem "sysrandom"` to Gemfile.
'
end
