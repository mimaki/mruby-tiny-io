MRuby::Gem::Specification.new('mruby-tiny-io') do |spec|
  spec.license = 'MIT'
  spec.author  = 'Hiroshi Mimaki'
  spec.summary = 'Tiny IO library for mruby'
  spec.version = '0.1.0'

  spec.add_test_dependency('mruby-string-ext', :core => 'mruby-string-ext')
end
