require 'rake/testtask'

desc "Run tests"
Rake::TestTask.new('test-unit') do |t|
  t.libs << 'test'
  t.test_files = FileList['test/balmora_test.rb', 'test/balmora/**/*.rb']
  t.warning = true
  t.verbose = true
end

desc "Run system tests"
Rake::TestTask.new('test-system') do |t|
  t.libs << 'test'
  t.test_files = FileList['test/system/*.rb']
  t.warning = true
  t.verbose = true
end

task('test') {
  Rake::Task["test-unit"].invoke()
  Rake::Task["test-system"].invoke()
}

task :default => 'test'