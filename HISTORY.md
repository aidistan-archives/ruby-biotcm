# History

- Update Table to v0.6.0
  - Add #get_ele, #set_ele, #get_row, #set_row, #get_col, #set_col
  - Deprecate #ele, #row, #col
- Update Apps::GeneDetector to v0.2.1
  - Refine the codes
- Update Databases::Cipher to v0.4.0
  - Refine the codes
- Update Databases::HGNC to v0.3.0
  - Change to a module instead of a class
  - Make downloading the HGNC table more robust
- Update Databases::OMIM to v0.3.0
  - Change to a module instead of a class
- Update Databases::Medline to v0.2.1
  - Refactor a little
- Add Apps::PubmedGeneMiner

### v0.8.1 2016-05-04
- Update BioTCM::Table to v0.5.1
  - Fix a bug in BioTCM::Table#to_s

### v0.8.0 2016-05-04
- Update BioTCM::Table to v0.5.0
  - Allow primary_key to be nil

### v0.7.0 2016-04-22
- Add BioTCM::Databases::OMIM back
- Use `meta.yaml` instead of `meta.json`

### v0.6.1 2016-04-21
- Update BioTCM::Table to v0.4.1
  - Fix a critical bug in Table#initialize

### v0.6.0 2016-04-11
- Change repo urls

### v0.5.0 2016-04-09
Make things clearer and easier
- Bump BioTCM::Databases::Cipher to v0.3.0

### v0.4.0 2015-11-01
- Implement `biotcm init app_name`
- Bump BioTCM::Apps::GeneDetector to v0.2.0
  - Upgrade the interface from optparser-style to gli-style

### v0.3.1 2015-09-05
- Bump BioTCM::Databases::Cipher to v0.2.0
  - Refactor the class
- Bump BioTCM::Databases::OMIM to v0.2.0
  - Refactor BioTCM::Databases::OMIM#initialize

### v0.3.0 2015-05-26
- Increase the version of ruby we depend on
- Bump BioTCM::Layer to v0.2.0
  - Change path conventions in BioTCM::Layer
- Bump BioTCM::Table to v0.4.0
  - Relocate to a place under BioTCM namesapce
  - Handle comments properly
- Remove Graph
- Bump BioTCM::Databases::HGNC to v0.2.3

### v0.2.3 2015-04-01
* Add -v option for bin/biotcm
* Add BioTCM::Interfaces
* Add BioTCM::Layer
* Deprecate Graph

### v0.2.2 2015-03-18
* Fix a bug in BioTCM::Databases::OMIM

### v0.2.1 2015-03-18
* Update the URLs of meta data
* Bump BioTCM::Databases::HGNC to v0.2.2
  * Fix the potential risk of ambiguous symbols
* Bump BioTCM::Apps::GeneDetector to v0.1.1
  * Pre-transform the text to find more genes

### v0.2.0 2015-01-25
* 2 major enhancements
  * Started to use Travis CI
  * Started to use Code Climate

### v0.2.0.pre 2014-12-13
* 3 major enhancements
  * Introduced in Rubocop for style guiding
  * Improved Table
  * Improved the app system

### v0.1.0 2014-10-03
* 3 major enhancements
  * Introduced in App System instead of BioTCM::Scripts
  * Renamed BioTCM::Network as BioTCM::Graph
  * Placed Table and Graph at top level namespace

### v0.0.7 2014-09-12
* 2 major enhancements
  * Ownership was transfered to [biotcm](http://github.com/biotcm)
  * Rewrote all tests with Minitest
* 1 minor enhancement
  * Made BioTCM::Databases::HGNC easier to use

### v0.0.6 2014-04-20
* 2 major enhancements
  * Added BioTCM::Databases::OMIM
  * Added BioTCM::Scripts::GeneDetector

### v0.0.5 2014-04-17
* 2 major enhancements
  * Improved BioTCM::Databases::Medline
  * Added BioTCM::Databases::KEGG

### v0.0.4 2014-04-01
* 3 major enhancements
  * Added BioTCM::Network
  * Added BioTCM::Scripts and BioTCM::Scripts::Script
  * Added BioTCM::Databases::Medline

### v0.0.3 2014-03-20
* 4 minor enhancements
  * Improved BioTCM::Table row insertion
  * Improved BioTCM::Databases::Cipher performance
  * Improved our benchmark suite
  * Added two setter methods for BioTCM::Table

### v0.0.2 2014-03-16
* 3 major enhancements
  * Added BioTCM::Logger
  * Added BioTCM::Databases::HGNC
  * Added BioTCM::Databases::Cipher

### v0.0.1 2014-03-14
* 2 major enhancements
  * Completed the design of architectures
  * Completed following modules and classes
    * Added BioTCM::Modules::Utility
    * Added BioTCM::Modules::WorkingDir
    * Added BioTCM::Table

### v0.0.0 2014-03-06
* 1 major enhancement
  * Built biotcm gem
