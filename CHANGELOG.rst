v0.1.6
------

Bugfixes
~~~~~~~~
- ``Puppetfiler::Mod`` now correctly checks for the symbolized member
  'version_requirement' of metadata.json entries.

v0.1.5
------

Breaking changes
~~~~~~~~~~~~~~~~
- Puppetfile/metadata.json are now specified via flags instead of
  passing them in.
  If neither are passed puppetfiler checks for a Puppetfile first, then
  for a metadata.json.
  If neither are found puppetfiler fails.

Changes
~~~~~~~
- The fixture method is now a module function with the following
  signature ``fixture(forge_modules, repos, modifier)``, with
  forge_modules being instances of ``Puppetfiler::Mod``

  ``Puppetfiler::Puppetfile#fixture`` is still available.

- Fixtures can now also be generated from metadata.json files


v0.1.4
------
Bugfix release

The output of the fixture() method did not include the top-level
'fixtures' key.

v0.1.3
------

Changes
~~~~~~~

- A hash can now be passed into the fixture() method, allowing to
  modify the resulting hashes.
  Primarily useful to pass additional proxy flags or to target in-house
  mirrors

v0.1.2
------

Changes
~~~~~~~

- Set mimimum ruby version to latest stable 2.1

v0.1.1
------

Initial release
