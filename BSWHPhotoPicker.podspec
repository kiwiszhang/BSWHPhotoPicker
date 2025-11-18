#
# Be sure to run `pod lib lint BSWHPhotoPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BSWHPhotoPicker'
  s.version          = '0.0.1'
  s.summary          = '图片编辑库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
基于ZLImageEditor封装.
                       DESC

  s.homepage         = 'https://github.com/caoguangming/BSWHPhotoPicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'caoguangming' => '48467160+caoguangming@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/caoguangming/BSWHPhotoPicker.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_versions        = ['5.0', '5.1', '5.2']

  s.source_files = 'BSWHPhotoPicker/Classes/**/*'
  s.exclude_files = ["BSWHPhotoPicker/Classes/General/ZLWeakProxy.swift"]
  
  s.resource_bundles = {
    'BSWHPhotoPicker' => [
      'BSWHPhotoPicker/Assets/**/*',
      'BSWHPhotoPicker/Resources/**/*'
    ]
  }

#  s.resources = 'BSWHPhotoPicker/BSWHPhotoPicker.bundle'

end
