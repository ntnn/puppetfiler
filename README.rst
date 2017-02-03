Puppetfiler
===========

Gem for miscellaneous actions based on Puppetfiles.

Installation
------------

.. code:: sh

    gem install puppetfiler

.. code:: ruby

    gem 'puppetfiler'


Usage
=====

If no Puppetfile has been specified puppetfiler uses the Puppetfile in
the current directory.

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
Create puppetlabs_spec_helper_ compatible ``.fixtures.yml`` from
Puppetfile.

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
