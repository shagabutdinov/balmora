require 'fileutils'

class DotfilesManager

  PATH = '.config/dotfiles-manager'

  attr_reader :config

  def initialize(config, options = {})
    @config = config
    @options = options
  end

  def run(command, *arguments)
    if !system(command, *arguments)
      raise "Failed to execute command #{command.inspect()} " +
        "#{arguments.inspect()}"
    end
  end

  def pull(options = [])
    @config.get(:synchronize).each() { |entry|
      entry = entry.clone()
      if entry.has_key?(:on) && !entry.delete(:on).include?('pull')
        next
      end

      command = DotfilesManager::Utility.get_command_instance(self, entry)
      command.pull(options)
    }
  end

  def push(options = [])
    @config.get(:synchronize).each() { |entry|
      entry = entry.clone()
      if entry.has_key?(:on) && !entry.delete(:on).include?('push')
        next
      end

      command = DotfilesManager::Utility.get_command_instance(self, entry)
      command.push(options)
    }
  end

end

require_relative 'dotfiles_manager/storage_git.rb'
require_relative 'dotfiles_manager/config.rb'
require_relative 'dotfiles_manager/file.rb'
require_relative 'dotfiles_manager/utility.rb'

config = DotfilesManager::Config.new()
manager = DotfilesManager.new(config)

manager.method(ARGV[0]).call(ARGV[1..-1])
# manager.push()
# manager.pull(ARGV)

# {
#   "type": "file",
#   "path": ".Xresources",
# }

# {
#   "type": "folder",
#   "path": ".Xresources",
# }

# {
#   "type": "pacman-package",
#   "name": "vim",
# }

# {
#   "type": "yaourt-package",
#   "name": "sublime-text-dev",
# }

# {
#   "type": "command",
#   "command": "vpn-up",
# }