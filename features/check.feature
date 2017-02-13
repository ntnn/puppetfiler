Feature: check

    Scenario: No puppetfile/metadata.json in pwd and none passed
        Given a file named "Puppetfile" does not exist
        Given a file named "metadata.json" does not exist
        When I run `puppetfiler check`
        Then the output should contain "No Puppetfile or metadata.json found, aborting"

    Scenario: Puppetfile in pwd and none passed
        Given a file named "Puppetfile" with:
        """
        moduledir 'external_modules'

        mod 'puppetlabs/stdlib', '4.13.0'
        """
        When I run `puppetfiler check`
        Then the output should contain "module"
        Then the output should contain "current"
        Then the output should contain "newest"
        Then the output should contain "puppetlabs/stdlib"

    Scenario: metadata.json in pwd and none passed
        Given a file named "metadata.json" with:
        """
        {
            "dependencies": [
                {
                    "name": "puppetlabs/stdlib",
                    "version_requirement": ">= 4.13.0 < 5.0.0"
                }
            ]
        }
        """
        When I run `puppetfiler check`
        Then the output should contain "Checking metadata.json for version range updates is not implemented yet"

    Scenario: Specified Puppetfile that does not exist
        Given a file named "path/Puppetfile" does not exist
        When I run `puppetfiler check -p path/Puppetfile`
        Then the output should contain "Puppetfile not found at path 'path/Puppetfile'"

    Scenario: Specified metadata.json that does not exist
        Given a file named "path/metadata.json" does not exist
        When I run `puppetfiler check -m path/metadata.json`
        Then the output should contain "Checking metadata.json for version range updates is not implemented yet"

    Scenario: Specified Puppetfile that exists
        Given a file named "path/Puppetfile" with:
        """
        moduledir 'external_modules'
        """
        When I run `puppetfiler check -p path/Puppetfile`
        Then the output should contain "module"
        Then the output should contain "current"
        Then the output should contain "newest"

    Scenario: Specified metadata.json that exists
        Given a file named "path/metadata.json" with:
        """
        {
            "dependencies": []
        }
        """
        When I run `puppetfiler check -m path/metadata.json`
        Then the output should contain "Checking metadata.json for version range updates is not implemented yet"

    Scenario: Puppetfile that is malformed
        Given a file named "Puppetfile" with:
        """
        moduledir 'external_modules'

        mod 'module'
            :git => 'git@some.git.provider:namespace/module'
        """
        When I run `puppetfiler check`
        Then the output should contain "Puppetfile at path 'Puppetfile' is invalid"

    Scenario: Metadata.json that is malformed
        Given a file named "metadata.json" with:
        """
        {
            "dependencies": [
        }
        """
        When I run `puppetfiler check -m path/metadata.json`
        Then the output should contain "Checking metadata.json for version range updates is not implemented yet"
