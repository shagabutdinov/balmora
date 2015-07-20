require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'balmora/command/file'

class Balmora::Command::FileTest < MiniTest::Test

  def setup()
    @shell = stub(run!: '', home: '~/')
    def @shell.expression(expr)
      return 'E:' + expr
    end

    def @shell.expand(path)
      return path
    end

    @config = stub(get: {path: 'STORAGE'})

    @state = stub(
      shell: @shell,
      config: @config,
      logger: stub(),
      balmora: stub()
    )
  end

  def _object(options = {})
    defaults = {
      file: '~/FILE',
      storage: 'STORAGE',
      action: 'push',
      check_equal: false,
      options: '-o',
    }

    file = Balmora::Command::File.new(@state, defaults.merge(options))
    file.init()

    return file
  end

  def test_run_copies_file_from_storage()
    @shell.expects(:run!).with(['cp', '-o', '~/FILE', 'STORAGE/FILE'])
    _object().run()
  end

  def test_run_copies_file_to_storage()
    @shell.expects(:run!).with(['cp', '-o', 'STORAGE/FILE', '~/FILE'])
    _object(action: 'pull').run()
  end

  def test_run_raises_if_file_starts_with_root()
    assert_raises(Balmora::Command::File::Error) {
      _object(file: '~/.root/FILE').run()
    }
  end

  def test_run_raises_if_file_starts_with_unknown_symbol()
    assert_raises(Balmora::Command::File::Error) {
      _object(file: 'FILE').run()
    }
  end

  def test_run_copies_file_to_root()
    @shell.expects(:run!).with(['cp', '-o', '/FILE', 'STORAGE/.root/FILE'])
    _object(file: '/FILE').run()
  end

  def test_run_copies_file_from_root()
    @shell.expects(:run!).with(['cp', '-o', 'STORAGE/.root/FILE', '/FILE'])
    _object(file: '/FILE', action: 'pull').run()
  end

  def test_run_compares_md5_sums()
    command = [
      'test', '-e', '~/FILE', 'E:&&',
      'test', '-e', 'STORAGE/FILE', 'E:&&',
      'E:[ "$(', 'cat', '~/FILE', 'E:| md5sum', 'E:)" != ',
      'E:"$(', 'cat', 'STORAGE/FILE', 'E:| md5sum)" ]',
    ]

    @shell.expects(:run).with(command, {verbose: false}).returns([0, ''])
    _object(check_equal: true).run()
  end

  def test_run_copies_if_md5_sum_not_equal()
    @shell.stubs(:run).returns([1, ''])
    @shell.expects(:run!).with(['cp', '-o', '~/FILE', 'STORAGE/FILE'])
    _object(check_equal: true).run()
  end

  def test_run_not_copies_if_md5_sum_not_equal()
    @shell.stubs(:run).returns([0, ''])
    @shell.expects(:run!).with(['cp', '-o', '~/FILE', 'STORAGE/FILE']).never()
    _object(check_equal: true).run()
  end

end