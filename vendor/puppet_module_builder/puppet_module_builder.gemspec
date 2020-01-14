Gem::Specification.new do |spec|
  spec.name    = 'puppet_module_builder'
  spec.version = '0.0.1' # This doesn't make much sense?!
  spec.authors = ['Puppet, Inc.']
  spec.email   = ['pdk-maintainers@puppet.com']

  spec.summary     = 'TBA'
  spec.description = 'TBA'
  spec.homepage    = 'https://github.com/puppetlabs/pdk'

  spec.files         = Dir['lib/**/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1.9'

  spec.add_runtime_dependency 'minitar', '~> 0.6'
end
