# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "custom-liquid-inheritance"
  s.version = "0.0.1"
  s.authors = ["Dylan Mao"]
  s.email = "maverickpuss@gmail.com"
  s.date = "2016-12-09"
  s.summary = "Adds Django style template inheritance to Liquid"
  s.description = "Adds Django style template inheritance to Liquid, including 'extends' tag, 'block' tag and 'block.super' varible which will be used to render a block's parent's content."
  s.files = ["lib/custom-liquid-inheritance.rb", "LICENSE", "custom-liquid-inheritance.gemspec", "README.md"]
  s.homepage = "http://github.com/maogongzi/custom-liquid-inheritance/"
  s.license = "GPL-3.0"
end
