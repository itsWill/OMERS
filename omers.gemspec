Gem::Specification.new do |s|
  s.name         = 'omers'
  s.version      = '0.0.0'
  s.date         = '2015-12-09'
  s.summary      = "One More Evented Ruby Server"
  s.description  = "A evented HTTP server"
  s.authors      = ["Guilherme Mansur"]
  s.email        = "guilhermerpmansur@gmail.com"
  s.files        = Dir.glob('{lib/test}/**/*') + ['README.md']
  s.require_path = "lib"
end
