Feature: version

    Scenario: Request version
        When I run `puppetfiler version`
        Then the output should contain "puppetfiler"
