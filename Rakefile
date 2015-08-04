require 'rake/testtask'

desc "Run tests"
Rake::TestTask.new('run-unit-tests') do |t|
  t.libs << 'test'
  t.test_files = FileList['test/balmora_test.rb', 'test/balmora/**/*.rb']
  t.warning = true
  t.verbose = true
end

desc "Run system tests"
Rake::TestTask.new('run-system-tests') do |t|
  t.libs << 'test'
  t.test_files = FileList['test/system/*.rb']
  t.warning = true
  t.verbose = true
end

task('test') {
  Rake::Task['run-unit-tests'].invoke()
  Rake::Task['run-system-tests'].invoke()
}

task :default => 'test'