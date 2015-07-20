require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'balmora/command/files'

class Balmora::Command::FilesTest < MiniTest::Test

  def setup()
    @shell = stub(run!: '', home: '~/')
    def @shell.expression(expr)
      return 'E:' + expr
    end

    def @shell.resolve_home(path)
      return path
    end

    @config = stub(get: {path: 'STORAGE'})
    @balmora = stub()

    @state = stub(
      shell: @shell,
      config: @config,
      logger: stub(),
      balmora: @balmora
    )
  end

  def _object(options = {})
    defaults = {
      # storage: 'STORAGE',
    }

    instance = Balmora::Command::Files.new(@state, defaults.merge(options))
    instance.init()
    return instance
  end

  def test_run_exec_balmora_run()
    @balmora.expects(:run_command)
    _object(files: ['FILE']).run()
  end

  def test_run_exec_balmora_run_with_file()
    @balmora.expects(:run_command).with(@state, {command: 'file',
      file: 'FILE'})
    _object(files: ['FILE']).run()
  end

  def test_run_exec_balmora_run_with_file_with_options()
    @balmora.expects(:run_command).with(@state, {command: 'file',
      file: 'FILE', option: 'OPTION'})
    _object(files: ['FILE'], options: {option: 'OPTION'}).run()
  end

  def test_run_exec_balmora_run_with_file_and_storage()
    @balmora.expects(:run_command).with(@state, {command: 'file',
      file: 'FILE', storage: 'STORAGE'})
    _object(files: ['FILE'], storage: 'STORAGE').run()
  end

  def test_run_exec_balmora_reads_files_from_storage_if_no_files_defined()
    @shell.expects(:run!).with(['find', 'STORAGE', '-type', 'f'],
      verbose: false).returns('')
    _object(storage: 'STORAGE').run()
  end

  def test_run_exec_balmora_uses_files_from_storage()
    @shell.stubs(:run!).with(['find', 'STORAGE', '-type', 'f'],
      verbose: false).returns('STORAGE/FILE')
    @balmora.expects(:run_command).with(@state, {command: 'file',
      file: 'FILE', storage: 'STORAGE'})
    _object(storage: 'STORAGE').run()
  end

end