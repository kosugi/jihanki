# -*- coding: utf-8 -*-

require 'rake/testtask'
Rake::TestTask.new {|t|
  t.pattern = '**/test_*.rb'
}

task :default => [:test]
