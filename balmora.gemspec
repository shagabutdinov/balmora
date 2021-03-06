Gem::Specification.new do |s|
  s.name        = 'balmora'
  s.version     = '0.0.3'
  s.summary     = 'Balmora'
  s.description = 'Balmora - linux task runner'
  s.authors     = ['Leonid Shagabutdinov']
  s.email       = 'leonid@shagabutdinov.com'
  s.files       = [
      'lib/balmora/variables/config.rb',
      'lib/balmora/variables/variables.rb',
      'lib/balmora/variables/options.rb',
      'lib/balmora/command/link.rb',
      'lib/balmora/command/files.rb',
      'lib/balmora/command/restart.rb',
      'lib/balmora/command/yaourt.rb',
      'lib/balmora/command/exec.rb',
      'lib/balmora/command/commands.rb',
      'lib/balmora/command/pacman.rb',
      'lib/balmora/command/stop.rb',
      'lib/balmora/command/reload_config.rb',
      'lib/balmora/command/file.rb',
      'lib/balmora/command/links.rb',
      'lib/balmora/command/set_variable.rb',
      'lib/balmora/require.rb',
      'lib/balmora/shell.rb',
      'lib/balmora/extension.rb',
      'lib/balmora/contexts.rb',
      'lib/balmora/context/config_changed.rb',
      'lib/balmora/context/exec.rb',
      'lib/balmora/context/value.rb',
      'lib/balmora/context/exec_result.rb',
      'lib/balmora/cli.rb',
      'lib/balmora/context.rb',
      'lib/balmora/arguments.rb',
      'lib/balmora/state.rb',
      'lib/balmora/config.rb',
      'lib/balmora/command.rb',
      'lib/balmora/extension/file_secret.rb',
      'lib/balmora/variables.rb',
      'lib/balmora/logger.rb',
      'lib/balmora.rb',
  ]

  s.executables << 'balmora'
  s.homepage    = 'http://github.com/shagabutdinov/balmora'
  s.license     = 'MIT'

  s.add_runtime_dependency "term-ansicolor", ["~> 1.3"]
end