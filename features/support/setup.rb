require 'simplecov'

Before do
    set_environment_variable('COVERAGE', 'true')
end

require 'aruba/cucumber'
require 'puppetfiler/version'
