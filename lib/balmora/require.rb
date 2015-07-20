require 'balmora/logger'
require 'balmora/extension'
require 'balmora/config'
require 'balmora/shell'
require 'balmora/variables'
require 'balmora/command'
require 'balmora/contexts'
require 'balmora/context'

require 'balmora/state'

globs = [
  'extension/**/*.rb',
  'command/**/*.rb',
  'variables/**/*.rb',
  'context/**/*.rb'
]

Dir.chdir(File.dirname(__FILE__)) {
  globs.each() { |glob|
    Dir.glob(glob).each() { |file|
      require ::File.join('balmora', file)
    }
  }
}
