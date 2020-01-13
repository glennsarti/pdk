Gem::Specification.new do |spec|
  spec.name    = 'pdk-plugin-powershell'
  spec.version = '0.0.1' # This doesn't make much sense?!
  spec.authors = ['Puppet, Inc.']
  spec.email   = ['pdk-maintainers@puppet.com']

  spec.summary     = 'TBA'
  spec.description = 'Plugin to make life using PDK easier in PowerShell'
  spec.homepage    = 'https://github.com/puppetlabs/pdk'

  spec.files         = Dir['plugins/**/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.required_ruby_version = '>= 2.1.9'

  spec.add_runtime_dependency 'pdk', '>= 0.0'
end
