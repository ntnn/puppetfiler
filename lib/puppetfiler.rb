require 'puppetfiler/cli'
require 'puppetfiler/fixture'
require 'puppetfiler/metadata'
require 'puppetfiler/mod'
require 'puppetfiler/puppetfile'
require 'puppetfiler/version'

module Puppetfiler
    def self.detect(type = nil, target = nil)
        if (type.nil? && !target.nil?) || (!type.nil? && target.nil?)
            fail 'Type and target are required to bet both set'
        elsif !type.nil? && !target.nil?
            return type, target
        end

        {
            :puppetfile => %w{Puppetfile},
            :metadata   => %w{metadata.json},
        }.each do |type, targets|
            targets.each do |target|
                if File.exists?(target)
                    return type, target
                end
            end
        end

        fail 'No valid target found, aborting'
    end

    def self.check(type = nil, target = nil)
        type, target = detect(type, target)

        case type
        when :puppetfile
            t = Puppetfiler::Puppetfile.new(target)
        when :metadata
            # TODO see below
            fail 'Checking metadata.json for version range updates is not implemented yet'
        else fail "Unkown type: #{type}"
        end

        return t.updates
    end

    def self.fixture(type = nil, target = nil, modifier = {}, stdout = false)
        type, target = detect(type, target)

        case type
        when :puppetfile
            f = Puppetfiler::Puppetfile.new(target)
        when :metadata
            f = Puppetfiler::Metadata.new(File.new(target))
        else fail "Unkown type: #{type}"
        end

        f = f.fixture(modifier).to_yaml

        if stdout
            puts f
        else
            File.write('.fixtures.yml', f)
        end
    end
end
