require 'json'
require 'puppetfiler/mod'
require 'semantic_puppet'

module Puppetfiler
    class Metadata
        attr :dependencies
        attr :path
        def initialize(target)
            @dependencies = {}

            parse target
        end

        def fixture(modifiers = {})
            Puppetfiler.fixture(@dependencies, {}, modifiers)
        end

        def eql?(other)
            @dependencies.eql?(other.dependencies)
        end

        private
        def parse(target)
            json = JSON.load(target)

            if not json.has_key?('dependencies') or json['dependencies'].eql?([])
                STDERR.puts "No dependencies in file '#{@path}' found"
                return nil
            end

            json['dependencies'].each do |hash|
                @dependencies[hash['name']] = Puppetfiler::Mod.new(hash)
            end
        end
    end
end
