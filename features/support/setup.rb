require 'simplecov'

SimpleCov.command_name 'cucumber'

Before do
    set_environment_variable('COVERAGE', 'true')
end

require 'aruba/cucumber'
