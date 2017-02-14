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
            Puppetfiler::Fixture.fixture(@dependencies, {}, modifiers)
        end

        def eql?(other)
            @dependencies.eql?(other.dependencies)
        end

        def updates
            require 'concurrent'

            updates = {}

            deps = @dependencies.map do |name, dep|
                Concurrent::Future.execute do
                    latest = dep.latest

                    if not dep.range.cover?(latest)
                        updates[name] = {
                            :range  => dep.range,
                            :newest => latest,
                        }
                    end
                end
            end

            deps.each { |f| f.wait_or_cancel(300) }

            return updates
        end

        private
        def parse(target)
            begin
                json = JSON.load(target)
            rescue JSON::ParserError => error
                STDERR.puts 'Passed metadata is invalid:'
                STDERR.puts error
                return nil
            end

            if not json.has_key?('dependencies') or json['dependencies'].eql?([])
                warn 'No dependencies found'
                return nil
            end

            json['dependencies'].each do |hash|
                @dependencies[hash['name']] = Puppetfiler::Mod.new(hash)
            end
        end
    end
end
