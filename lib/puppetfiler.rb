require 'puppetfiler/cli'
require 'puppetfiler/metadata'
require 'puppetfiler/mod'
require 'puppetfiler/puppetfile'
require 'puppetfiler/version'

module Puppetfiler
    def self.fixture(modules, repos, modifiers = {})
        fixtures = {
            'forge_modules' => {},
            'repositories'  => {},
        }

        fixtures.each do |k, v|
            modifiers[k] = {} if not modifiers.has_key?(k)
        end

        modules.each do |name, version|
            short = name.split('/')[1]
            value = {
                'repo' => name,
                'ref'  => version,
            }

            modifiers['forge_modules'].each do |modifier, merger|
                # TODO use x.match?(y) on ruby 2.4
                value.merge!(merger) if name =~ /#{modifier}/
            end

            fixtures['forge_modules'][short] = value
        end

        repos.each do |name, hash|
            if hash.has_key?(:ref)
                content = {
                    'repo' => hash[:uri],
                    'ref'  => hash[:ref],
                }

                modifiers['repositories'].each do |modifier, merger|
                    content.merge!(merger) if name =~ /#{modifier}/
                end
            else
                content = hash[:uri]

                modifiers['repositories'].each do |modifier, merger|
                    if name =~ /#{modifier}/
                        if merger.is_a?(String)
                            content = merger
                        else
                            content = {
                                'repo' => hash[:uri],
                            }

                            content.merge!(merger)
                        end
                    end
                end
            end

            fixtures['repositories'][name] = content
        end

        return { 'fixtures' => fixtures }
    end
end
