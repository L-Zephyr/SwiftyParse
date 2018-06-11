#
# Be sure to run `pod lib lint SwiftyParse.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftyParse'
  s.version          = '0.1.0'
  s.summary          = 'Parser combinator in swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A lightweight parser combinator for swift
                       DESC

  s.homepage         = 'https://github.com/L-Zephyr/SwiftyParse.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lzf.lzephyr@gmail.com' => 'lzf.lzephyr@gmail.com' }
  s.source           = { :git => 'https://github.com/L-Zephyr/SwiftyParse.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.default_subspec = 'Sources'
  
  # All subspec
  s.subspec 'Sources' do |sp|
      sp.source_files = 'Sources/SwiftyParse/**/*'
  end

  # Core parser only
  s.subspec 'Core' do |sp|
      sp.source_files = 'Sources/SwiftyParse/Core/**/*'
  end
  
  # String parser subspec
  s.subspec 'StringParser' do |sp|
      sp.source_files = 'Sources/SwiftyParse/StringParser/**/*'
  end
  
  # unit test
  s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'Tests/*'
  end
end
