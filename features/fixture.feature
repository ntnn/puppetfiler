Feature: fixture

    Background:
        Given a file named "Puppetfile" with:
        """
        moduledir 'external_modules'

        mod 'puppetlabs/stdlib', '4.13.0'
        """

    Scenario: No puppetfile in pwd and none passed
        Given a file named "Puppetfile" does not exist
        When I run `puppetfiler fixture`
        Then the output should contain "Puppetfile not found at path 'Puppetfile'"

    Scenario: Puppetfile in pwd and none passed printing to output
        When I run `puppetfiler fixture -o`
        Then the output should contain "stdlib:"
        Then the output should contain "repo: puppetlabs/stdlib"

    Scenario: Puppetfile in pwd and none passed
        Given a file named "Puppetfile" with:
        """
        moduledir 'external_modules'

        mod 'puppetlabs/stdlib', '4.13.1'

        mod 'goscript', :git => 'https://github.com/ntnn/puppet-goscript'

        mod 'inifile',
            :git => 'https://github.com/puppetlabs/puppetlabs-inifile',
            :tag => '1.6.0'
        """
        When I run `puppetfiler fixture`
        Then a file named ".fixtures.yml" should contain:
        """
        ---
        fixtures:
          forge_modules:
            stdlib:
              repo: puppetlabs/stdlib
              ref: 4.13.1
          repositories:
            goscript: https://github.com/ntnn/puppet-goscript
            inifile:
              repo: https://github.com/puppetlabs/puppetlabs-inifile
              ref: 1.6.0
        """
