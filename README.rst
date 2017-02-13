Puppetfiler
===========
.. image:: https://travis-ci.org/ntnn/puppetfiler.svg?branch=master
    :target: https://travis-ci.org/ntnn/puppetfiler
    :alt: Travis CI
.. image:: https://codeclimate.com/github/ntnn/puppetfiler/badges/gpa.svg
    :target: https://codeclimate.com/github/ntnn/puppetfiler
    :alt: Code Climate
.. image:: https://codeclimate.com/github/ntnn/puppetfiler/badges/coverage.svg
   :target: https://codeclimate.com/github/ntnn/puppetfiler/coverage
   :alt: Test Coverage

Gem for miscellaneous actions based on Puppetfiles.

Installation
------------

.. code:: sh

    gem install puppetfiler

.. code:: ruby

    gem 'puppetfiler'


Usage
=====

A puppetfile can be specified via ``-p path/to/pf`` or ``--puppetfile path/to/pf``,
a metadata file via ``-m path/to/metadata.json`` or ``--metadata
path/to/metadata.json``.

If neither are specified ``puppetfiler`` will check for a file named
``Puppetfile`` in the current working directory first, then for a file
named ``metadata.json``.

check
-----
Check puppet forge for newer versions of used forge modules.

.. code:: sh

    $ puppetfiler check
    module               current  newest
    puppetlabs/stdlib    4.13.1   4.15.0
    puppetlabs/firewall  1.8.1    1.8.2

Be aware that the check command may take a while, since each module has
to be queried from the forge.

fixture
-------
Create puppetlabs_spec_helper_ compatible ``.fixtures.yml``.

.. code:: sh

    $ puppetfiler fixture
    $ cat .fixtures.yml
    ---
    fixtures:
      forge_modules:
	stdlib:
	  repo: puppetlabs/stdlib
	  ref: 4.13.1
	firewall:
	  repo: puppetlabs/firewall
	  ref: 1.8.1

.. _puppetlabs_spec_helper: https://github.com/puppetlabs/puppetlabs_spec_helper

Gerating .fixture.yml when executing rake tasks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Without modifying the result:

.. code:: ruby

    require 'puppetfiler/rake_tasks'

Which adds the task ``fixture``, which is equivalent to runnning
``puppetfiler fixture``.

With modifying the result:

.. code:: ruby

    require 'puppetfiler'

    desc 'Generate .fixtures.yml'
    task :fixture do
        modifier = {
            'forge_modules' => {
                /.*/ => {
                    'flags' => '--module_repository https://inhouse.forge.lan/',
                },
            },
        }

        Puppetfiler.fixture(modifier)
    end

    task :spec => [:fixtures]
    task :test do
        [:metadata_lint, :lint, :validate, :spec].each do |test|
            Rake::Task[test].invoke
        end
    end

Allowed keys in the passed modifiers are 'forge_modules' and
'repositories', which are hashes with strings or regular expressions as
keys and hashes or strings as values.

Also see the rspec test ``takes a hash with pattern matches and returns
fixtures as a hash`` in ``spec/puppetfiler/puppetfile_spec.rb``.
