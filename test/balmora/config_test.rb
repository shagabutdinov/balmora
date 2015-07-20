require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'balmora/config'

class Balmora::ConfigTest < MiniTest::Test

  def setup()
    @files = {
      'PATH' => '{"key1":{"key2":"value"}}',
      'EXT' => '{"require":["file1","file2"]}',
      'FILE' => '{"key":"value"}',
    }

    @variables = stub()
    def @variables.inject(value)
      return value
    end

    @state = stub(
      options: {config: 'PATH'},
      variables: @variables
    )

    @object = Balmora::Config.factory(@state)

    @object.require = stub(call: true)
    @object.file = _create_file()
    @object.load()

    @dir = stub()
    @object.dir = @dir
    def @dir.glob(file); return [file]; end
  end

  def _create_file()
    file = stub()
    file.instance_variable_set(:@files, @files)
    def file.read(path)
      return @files[path]
    end

    def file.expand_path(path)
      return path
    end

    return file
  end

  # load_extensions

  def test_load_requires_first_extension()
    @state.options[:config].clear()
    @state.options[:config].concat('EXT')
    @object.require.expects(:call).with('file1')
    @object.load()
  end

  def test_load_requires_second_extension()
    @state.options[:config].clear()
    @state.options[:config].concat('EXT')
    @object.require.expects(:call).with('file2')
    @object.load()
  end

  # load

  def test_load_expands_path()
    @object.file.expects(:expand_path).with('PATH').returns('PATH')
    @object.load()
  end

  def test_load_reads_expanded_path()
    @object.file.stubs(:expand_path).returns('EXPANDED')
    @object.file.expects(:read).with('EXPANDED').returns(@files['PATH'])
    @object.load()
  end

  def test_get_include_file()
    @files['PATH'] = '{"include-file": "FILE"}'
    @object.load()
    assert_equal({key: 'value'}, @object.get())
  end

  def test_get_include_file_by_query()
    @dir.stubs(:glob).with('FILE/*').returns(['FILE', 'FILE2'])
    @files['PATH'] = '{"include-file": "FILE/*"}'
    @files['FILE2'] = '{"key2":"value2"}'
    @object.load()
    assert_equal({key: 'value', key2: 'value2'}, @object.get())
  end

  def test_get_include_file_on_bottom()
    @files['PATH'] = '{"include-file": "FILE", "key": "REDEFINED"}'
    @object.load()
    assert_equal({key: 'value'}, @object.get())
  end

  def test_get_include_file_with_nesting()
    @files['PATH'] = '{"key": {"include-file": "FILE"}}'
    @object.load()
    assert_equal({key: {key: 'value'}}, @object.get())
  end

  def test_get_extends_file()
    @files['PATH'] = '{"key": [{"extend-file": "FILE"}]}'
    @files['FILE'] = '[1,2,3]'
    @object.load()
    assert_equal([1, 2, 3], @object.get(:key))
  end

  def test_get_extends_file_with_nesting()
    @files['PATH'] = '{"key": [{"extend-file": "FILE"}]}'
    @files['FILE'] = '[1,2,3]'
    @object.load()
    assert_equal({key: [1, 2, 3]}, @object.get())
  end

  def test_get_extends_file_with_array_nesting()
    @files['PATH'] = '{"key": [{"key": [{"extend-file": "FILE"}]}]}'
    @files['FILE'] = '[1,2,3]'
    @object.load()
    assert_equal([{key: [1, 2, 3]}], @object.get(:key))
  end

  # get

  def test_get_returns_one_key()
    assert_equal({key2: 'value'}, @object.get(:key1))
  end

  def test_get_returns_nesting()
    assert_equal('value', @object.get([:key1, :key2]))
  end

  def test_get_raises_on_unknown_key()
    assert_raises(RuntimeError) { @object.get(:UNKNOWN) }
  end

  def test_get_returns_deep_clone_of_config_part()
    config = @object.get()
    config[:key2] = 'value'
    refute_equal(@object.get(), config)
  end

  def test_get_sets_variables()
    @variables.stubs(:inject).returns('RESULT')
    assert_equal('RESULT', @object.get([:key1, :key2]))
  end

  def test_get_not_sets_variables()
    @variables.stubs(:inject).returns('RESULT')
    assert_equal('value', @object.get([:key1, :key2], variables: false))
  end

  def test_get_returns_default()
    assert_equal('DEFAULT', @object.get([:UNKNOWN1, :UNKNOWN2],
      default: 'DEFAULT'))
  end

end