require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |task|
        task.rspec_opts = ['--color', '--format', 'doc', 'test/mbox_spec.rb']
end

task :default => :spec
