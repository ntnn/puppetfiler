require 'puppet_forge'
require 'semantic_puppet'

module Puppetfiler
    class Mod
        def self.newest(name)
            mod = PuppetForge::Module.find(name.gsub('/', '-'))
            version = mod.current_release.version
            return SemanticPuppet::Version.parse(version)
        end
    end
end
