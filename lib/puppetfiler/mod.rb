require 'puppet_forge'
require 'semantic_puppet'

module Puppetfiler
    class Mod
        attr :name
        attr :slug
        attr :range

        def initialize(*args)
            require 'hashie'
            args = Hashie.symbolize_keys(args[0])

            raise "Names with dashes are disallowed: #{args[:name]}" if /-/.match(args[:name])

            @name = args[:name]
            @slug = @name.gsub('/', '-')

            @forge = nil

            @range = nil
            %i{range version_requirement}.each do |v|
                if args.has_key?(v)
                    if not args[v].is_a?(SemanticPuppet::VersionRange)
                        args[v] = SemanticPuppet::VersionRange.parse(args[v])
                    end

                    @range = args[v]
                end
            end

            @version = nil
            %i{version}.each do |v|
                @version = SemanticPuppet::Version.parse(args[v]) if args.has_key?(v)
            end
            @version = latest_valid if not @version
        end

        def forge
            return @forge ||= PuppetForge::Module.find(@slug)
        end

        def eql?(other)
            return false if not @name.eql?(other.name)

            # range has to be checked first, sine version is a method
            # returning at least latest
            if @range
                return false if not other.range
                return true if @range.eql?(other.range)
            end

            return true if version.eql?(other.version)

            return false
        end

        def version
            return latest_valid if not @version

            return @version
        end

        def latest
            return SemanticPuppet::Version.parse(forge.current_release.version)
        end

        def valid_versions
            return [] if not @range

            versions = []

            forge.releases.each do |release|
                version = SemanticPuppet::Version.parse(release.version)
                versions << version if @range.cover?(version)
            end

            return versions
        end

        def latest_valid
            if not @range
                return latest
            end

            return valid_versions[0]
        end

        def version_valid(version = @version)
            return false if not @range

            version = SemanticPuppet::Version.parse(version) if not version.is_a?(SemanticPuppet::Version)
            return range.cover?(version)
        end
    end
end
