BioTCM [![Gem Version](https://badge.fury.io/rb/biotcm.png)](http://badge.fury.io/rb/biotcm)
=======

Written for working in Shao lab (BioTCM).

* Release version on RubyGems:
	[Homepage](http://rubygems.org/gems/biotcm) | [Documents](http://rubydoc.info/gems/biotcm/frames)
* Development version on Github:
	[Homepage](http://biotcm.github.io/biotcm) | [Documents](http://biotcm.github.io/biotcm/doc/frames.html)


## Getting Started

Install BioTCM at the command prompt first:

	$ gem install biotcm

We believe in documenting within codes, so you could find all APIs, examples 
and guides you need on [RubyDoc](http://rubydoc.info/gems/biotcm/frames).


## Getting Involved

We develop this gem under some philosophies and some styles. Feel free to 
send pull requests, then we could communicate through comments.

### Design Philosophies

* self-explanatory coding
* convention over configuration

### Coding Style

Practically follow [ruby-style-guide](https://github.com/bbatsov/ruby-style-guide)
, a community-driven ruby coding style guide.

Following is a incomplete list of __some__ __possible__ __differences__.

* Comments
	* Write YARD document within codes to generate API docs and example usages 
	  for users.
		* Use (part of) these sections to describe a class or module
			* Overview (default) : briefly describe the purpose and the usage
			* Requirement
			* Example Usage
			* Other Supplementary : such as the brief introduction of the 
			  database (this subtitle could be changed)
			* Reference
	* Write self-documenting code for developers.			
		* Use these and only these comment annotations
			* TODO: To note missing features or functionality that should be 
			  added at a later date.
			* FIXME: To note broken code that needs to be fixed.
			* OPTIMIZE: To note slow or inefficient code that may cause 
			  performance problems.
			* HACK: To note code smells where questionable coding practices 
			  were used and should be refactored away.
			* REVIEW: To note anything that should be looked at to confirm 
			  it is working as intended. For example: REVIEW: Are we sure this 
			  is how the client does X currently?
* Classes & Modules
	* Define VERSION for each script or database class
	* Write the changes in the commit message and _HISTORY.md_
	* Use following structure in module/class definitions
		* Special handling, such as autoloader
		* Extends and includes
		* Constants
		* Attribute macros and other macros
		* Public class methods
		* Public instance methods
		* Protected and private methods
		* Special handling, such as overwriting (to escape YARD documenting)

### Test Style

Having no explicit map of our gem, we just add new Script or Module when we 
need it, which make the popular test suite _RSepc_ doesn't suit our need 
quite well. In such case, we choose to write our tests with __minitest__ gem.

Better to write some tests for you module/class to make others understand the 
design purpose more easily.


## License

Copyright 2014 BioTCM group under the MIT license.
