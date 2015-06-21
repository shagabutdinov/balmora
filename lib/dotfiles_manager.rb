require 'fileutils'
require 'shellwords'

class DotfilesManager

  PATH = File.expand_path('~/.config/dotfiles-manager')

  attr_reader :config

  def initialize(config, options = {})
    @config = config
    @options = options
  end

  def run(command, *arguments)
    shell_command =
      ([command] + arguments).
      collect() { |arg| Shellwords.escape(arg) }.
      join(' ')

    if @options[:verbose]
      puts(shell_command)
    end

    result = `#{shell_command}`
    if $?.exitstatus != 0
      raise "Failed to execute command #{shell_command}"
    end

    return result
  end

  def pull(options = [])
    _run(:pull, options)
  end

  def push(options = [])
    _run(:push, options)
  end

  class Retry < StandardError; end

  def _run(action, options)
    entries = @config.get(:synchronize)
    entries.each() { |entry|
      entry = entry.clone()
      if !entry[:on].nil?() && entry[:on] != action.to_s()
        next
      end

      if entry[:type] == 'reload'
        if entry.keys().length > 1
          raise "Unknown keys #{(entry.keys() - [:type]).inspect()} for " +
            "entry #{entry.inspect()}"
        end

        @config.reload()
        if @config.get(:synchronize) != entries
          raise Retry.new()
        end

        next
      end

      command = DotfilesManager::Utility.get_command_instance(self, entry)
      command.method(action).call(options)
    }
  rescue Retry
    retry
  end

end

require 'dotfiles_manager/config.rb'
require 'dotfiles_manager/utility.rb'

require 'dotfiles_manager/file.rb'
require 'dotfiles_manager/storage_git.rb'
require 'dotfiles_manager/package_pacman.rb'
require 'dotfiles_manager/package_yaourt.rb'