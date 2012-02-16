Gem::Specification.new do |s|
  s.name = 'cachet'
  s.version = '0.0.0'
  s.date = '2012-02-07'
  s.summary = "Caches method responses to have a better performance!"
  s.description = "Provides a way to cache and invalidate return values of your time consuming methods."
  s.authors = ["Meltem Atesalp", "Umut Utkan"]
  s.homepage = 'https://github.com/meltem/cachet'
  s.email = 'meltem.atesalp@gmail.com'
  s.files = Dir.glob("{bin,lib,tasks}/**/*") + %w(README)
  s.test_files = Dir.glob("{features,spec,test}/**/*")
  s.add_runtime_dependency('rails', [">= 3.0.0"])
  s.add_development_dependency('fakefs')

end
