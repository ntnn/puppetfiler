Feature: check

    Background:
        Given a file named "Puppetfile" with:
        """
        moduledir 'external_modules'

        mod 'puppetlabs/stdlib', '4.13.0'
        """

    Scenario: No puppetfile in pwd and none passed
        Given a file named "Puppetfile" does not exist
        When I run `puppetfiler check`
        Then the output should contain "Puppetfile not found at path 'Puppetfile'"

    Scenario: Puppetfile in pwd and none passed
        When I run `puppetfiler check`
        Then the output should contain "module"
        Then the output should contain "current"
        Then the output should contain "newest"

    Scenario: Specified Puppetfile that does not exist
        When I run `puppetfiler check non/existing/puppetfile`
        Then the output should contain "Puppetfile not found at path 'non/existing/puppetfile'"

    Scenario: Specified Puppetfile that exists
        Given a file named "path/Puppetfile" with:
        """
        moduledir 'external_modules'
        """
        When I run `puppetfiler check path/Puppetfile`
        Then the output should contain "module"
        Then the output should contain "current"
        Then the output should contain "newest"

    Scenario: Puppetfile that is malformed
        Given a file named "Puppetfile" with:
        """
        moduledir 'external_modules'

        mod 'module'
            :git => 'git@some.git.provider:namespace/module'
        """
        When I run `puppetfiler check`
        Then the output should contain "Puppetfile at path 'Puppetfile' is invalid"
