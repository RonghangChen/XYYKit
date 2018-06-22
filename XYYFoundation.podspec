#
#  Be sure to run `pod spec lint XYYKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "XYYFoundation"
  s.version      = "0.0.5"
  s.summary      = "私人框架库"

  s.author       =  { "LeslieChen" => "102731887@qq.com" }
  s.homepage     = "https://coding.net/u/crh/p/XYYKit/git"
  s.social_media_url  = "https://github.com/RonghangChen"

  s.license       = { :type => "MIT", :file => "LICENSE" }

  s.requires_arc = true
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://git.coding.net/crh/XYYKit.git", :tag => "#{s.version}" }

  s.source_files = "#{s.name}/**/*.{h,m}"
  s.resources    = "#{s.name}/Resources/*"
  s.public_header_files = "#{s.name}/**/*.h"   

  s.frameworks = "UIKit", "Foundation", "Accelerate", "CoreFoundation"

  s.dependency 'MBProgressHUD' , '~> 0.9.1'
  s.dependency 'TTTAttributedLabel'

end
