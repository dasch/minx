require 'rubygems'
require 'test/unit'
require 'shoulda'

FIXTURE_PATH = File.join(File.dirname(__FILE__), 'fixtures/data')

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'minx'
