Pod::Spec.new do |s|
  s.name             = 'NovaDateRangeKit'
  s.version          = '1.0.0'
  s.summary          = 'A fully programmatic UIKit calendar date range picker for iOS.'
  s.description      = <<-DESC
NovaDateRangeKit is a production-ready UIKit date range picker component with
month navigation, weekday header, custom date cell rendering, range highlights,
and min-date constraints.
  DESC

  s.homepage         = 'https://github.com/sigit485/NovaDateRangeKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sigit485' => 'sigit485@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/sigit485/NovaDateRangeKit.git', :tag => s.version.to_s }

  s.platform         = :ios, '12.0'
  s.swift_version    = '5.9'
  s.requires_arc     = true

  s.source_files     = 'Sources/NovaDateRangeKit/**/*.swift'
end
