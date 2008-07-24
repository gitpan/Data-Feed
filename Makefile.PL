use strict;
use inc::Module::Install;

name('Data-Feed');

all_from('lib/Data/Feed.pm');

requires 'DateTime::Format::Mail';
requires 'DateTime::Format::W3CDTF';
requires 'List::Util';
requires 'Moose', '0.54';
requires 'XML::Atom';
requires 'XML::RSS';
recommends 'XML::RSS::LibXML';

test_requires('Test::More');
test_requires('Test::Compile');

auto_install;
WriteAll;