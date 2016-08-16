# Ruby Gem: BioTCM

[![Gem Version](https://badge.fury.io/rb/biotcm.svg)](https://rubygems.org/gems/biotcm)
[![Dependency Status](https://gemnasium.com/badges/github.com/aidistan/ruby-biotcm.svg)](https://gemnasium.com/github.com/aidistan/ruby-biotcm)
[![Build Status](https://travis-ci.org/aidistan/ruby-biotcm.svg?branch=master)](https://travis-ci.org/aidistan/ruby-biotcm)
[![Docs Status](http://inch-ci.org/github/aidistan/ruby-biotcm.svg?branch=master)](http://www.rubydoc.info/gems/biotcm)

BioTCM is designed as a base gem to build advanced applications on Bioinformatics.

## Getting Started

Install BioTCM from the command prompt:

	$ gem install biotcm

We believe in self-documentation coding, so you could find all APIs, examples and guides you need in the [documents](http://biotcm.github.io/biotcm/doc/frames.html).

## Getting Involved

### What can I do?

Feel free to send pull requests. You could help us

- integrate your awesome application into BioTCM ecosystem
- refactor codes to improve [the code climate](https://codeclimate.com/github/biotcm/biotcm)
- write more tests to increase [the test coverage](https://codeclimate.com/github/biotcm/biotcm)
- refine [docs](http://inch-ci.org/github/biotcm/biotcm) to help more users

### How should I do?

We develop this gem under some philosophies and some styles. Please follow the style while you are making amazing things.

#### Design Philosophies

* self-explanatory coding
* Do not Repeat Yourself (DRY)
* Convention over Configuration (CoC)

#### Coding Style

Practically we follow [ruby-style-guide](https://github.com/bbatsov/ruby-style-guide), a community-driven ruby coding style guide, and use [**Rubocop**](https://github.com/bbatsov/rubocop) to check it.

For Atom users, we strongly recommend to use [linter-rubocop](https://atom.io/packages/linter-rubocop) package to lint Ruby code on the fly.

##### Documentation

We write YARD document within codes to generate API docs and example usages for users and use (part of) these sections to describe a class or module.

* Overview (default) : briefly describe the purpose and the usage
* Requirement
* Example Usage
* Other Supplementary : such as the brief introduction of the
  database (this subtitle could be changed)
* Reference

##### Class/Module Structure

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

#### Test Style

Having no explicit map of our gem, we add new Class or Module when we need it, which make the popular test suite _RSepc_ doesn't suit our need quite well. In such case, we choose to write our tests with __minitest__ gem.

It's hard to decide when to test but better to write some tests for you module/class to make others understand the design purpose more easily.

## License

Copyright (c) 2014-2016 BioTCM group under [the MIT license](https://github.com/biotcm/biotcm/blob/master/LICENSE).
