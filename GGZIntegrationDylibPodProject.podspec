#
# Be sure to run `pod lib lint GGZIntegrationDylibPodProject.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'GGZIntegrationDylibPodProject'
    s.version          = '3.0.0'
    s.summary          = 'A short description of GGZIntegrationDylibPodProject.'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    TODO: Add long description of the pod here.
    DESC
    
    s.homepage         = 'https://github.com/GE-GAO-ZHAO/GGZPencilSDKDemo'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'gegaozhao' => 'gegaozhao1126@gmail.com' }
    s.source           = { :git => 'https://github.com/GE-GAO-ZHAO/GGZPencilSDKDemo.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '10.0'

    s.source_files  = "GGZIntegrationDylibPodProject/Classes/RobotPenSDKHeader/*.h","GGZIntegrationDylibPodProject/Classes/Core/*.{h,m}"

    # system tbd
    s.libraries = 'sqlite3.0'
    
    # .a 不需要再使用 s.source_files 引入啦
    s.vendored_libraries = 'GGZIntegrationDylibPodProject/Classes/libRobotPenSDK.a'
    
    # arc
    s.requires_arc = true
    
end
