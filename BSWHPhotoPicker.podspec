#
# Be sure to run `pod lib lint BSWHPhotoPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BSWHPhotoPicker'
  s.version          = '1.0.0'
  s.summary          = '图片编辑库'
  s.description      = '基于 ZLImageEditor 封装的图片编辑库'

  s.homepage         = 'https://github.com/kiwiszhang/BSWHPhotoPicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'caoguangming' => 'zhangzhiqiang.mail@qq.com' }
  s.source           = {
    :git => 'https://github.com/kiwiszhang/BSWHPhotoPicker.git',
    :tag => s.version.to_s
  }

  s.ios.deployment_target = '15.0'
  s.swift_versions        = ['5.0', '5.1', '5.2']

  s.dependency 'SnapKit', '~> 5.7.1'

  # 只包含代码
  s.source_files = 'BSWHPhotoPicker/Classes/**/*.{swift,h,m}'

  # 排除任何资源目录 & 指定文件
  s.exclude_files = [
    'BSWHPhotoPicker/Classes/General/ZLWeakProxy.swift',
    'BSWHPhotoPicker/Resources/**'
  ]

  # 所有资源只走 bundle
  s.resource_bundles = {
    'BSWHPhotoPicker' => ['BSWHPhotoPicker/Resources/**/*']
  }
end

