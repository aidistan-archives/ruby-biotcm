# BioTCM

[![Gem Version](https://badge.fury.io/rb/biotcm.svg)](http://badge.fury.io/rb/biotcm)
[![Roadmap](https://img.shields.io/badge/roadmap-0.2.0-blue.svg?style=flat)](http://libreboard.com/boards/k7ojKM7FNXM9MBk3M/biotcm-roadmap)
[![Build Status](https://travis-ci.org/biotcm/biotcm.svg?branch=master)](https://travis-ci.org/biotcm/biotcm)
[![Code Climate](https://codeclimate.com/github/biotcm/biotcm/badges/gpa.svg)](https://codeclimate.com/github/biotcm/biotcm)
[![Coverage Status](https://coveralls.io/repos/biotcm/biotcm/badge.svg?branch=master)](https://coveralls.io/r/biotcm/biotcm?branch=master)
[![Docs Status](http://inch-ci.org/github/biotcm/biotcm.svg?branch=master)](http://inch-ci.org/github/biotcm/biotcm)

BioTCM is designed as a base gem to build advanced applications on Bioinformatics.

* Release version on RubyGems:
	[Homepage](http://rubygems.org/gems/biotcm) | [Documents](http://rubydoc.info/gems/biotcm/frames)
* Development version on Github:
	[Homepage](http://biotcm.github.io/biotcm) | [Documents](http://biotcm.github.io/biotcm/doc/frames.html)


## Getting Started

Install BioTCM from the command prompt:

	$ gem install biotcm

We believe in self-documentation coding, so you could find all APIs, examples and guides you need in [documents](http://biotcm.github.io/biotcm/doc/frames.html).


## Getting Involved

We develop this gem under some philosophies and some styles. Please follow the style and feel free to send pull requests.

### Design Philosophies

* self-explanatory coding
* Do not Repeat Yourself (DRY)
* Convention over Configuration (CoC)

### Coding Style

Practically we follow [ruby-style-guide](https://github.com/bbatsov/ruby-style-guide), a community-driven ruby coding style guide, and use [**Rubocop**](https://github.com/bbatsov/rubocop) to check it.

#### Documentation

We write YARD document within codes to generate API docs and example usages for users and use (part of) these sections to describe a class or module.

* Overview (default) : briefly describe the purpose and the usage
* Requirement
* Example Usage
* Other Supplementary : such as the brief introduction of the
  database (this subtitle could be changed)
* Reference

#### Class/Module Structure

For classes & modules, we

* define VERSION for each script or database class
* write the changes in the commit message and _HISTORY.md_
* use following structure in module/class definitions
	* Special handling, such as autoloader
	* Extends and includes
	* Constants
	* Attribute macros and other macros
	* Public class methods
	* Public instance methods
	* Protected and private methods
	* Special handling, such as overwriting (to escape YARD documenting)

### Test Style

Having no explicit map of our gem, we add new Class or Module when we need it, which make the popular test suite _RSepc_ doesn't suit our need quite well. In such case, we choose to write our tests with __minitest__ gem.

It's hard to decide when to test but better to write some tests for you module/class to make others understand the design purpose more easily.


## License

Copyright (c) 2014-2015 BioTCM group under [the MIT license](https://github.com/biotcm/biotcm/blob/master/LICENSE).
