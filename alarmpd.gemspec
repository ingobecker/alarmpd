Gem::Specification.new do |s|
  s.name        = 'alarmpd'
  s.version     = '0.0.2'
  s.date        = '2016-02-25'
  s.summary     = 'Turns your MPD into a playlist-based alarm clock.'
  s.description = 'This daemon takes control over your MPD in order to wake you up with your favourite playlist. Schedule as much alarms as you like by creating playlists named after the wake up time.'
  s.authors     = ['Ingo Becker']
  s.email       = 'ingo@orgizm.net'
  s.files       = Dir.glob('{bin,lib,spec}/**/*') + %w(README.md LICENSE)
  s.executables = ['alarmpd']
  s.homepage    = 'http://rubygems.org/gems/alarmpd'
  s.license     = 'GPL-3.0'

  s.add_runtime_dependency 'ruby-mpd', ['>= 0.3.3', '< 1.0']
  s.add_runtime_dependency 'rufus-scheduler', ['>= 3.2.0', '< 4.0']
  s.add_development_dependency 'rspec', '~> 3.4', '>= 3.4.0'
end
