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

  s.name         = "XYYKit"
  s.version      = "0.9.2"
  s.summary      = "框架库"

  s.author       =  { "LeslieChen" => "102731887@qq.com" }
  s.homepage     = "https://coding.net/u/crh/p/XYYKit/git"
  s.social_media_url  = "https://github.com/RonghangChen"

  s.license      = "MIT"

  s.requires_arc = true
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://git.coding.net/crh/XYYKit.git", :tag => "#{s.version}" }
  s.source_files = "XYYKit/*.{h,m}"



  # 基础框架
  s.subspec 'XYYFoundation' do |foundation|

    foundation.source_files = "XYYFoundation/**/*.{h,m}"
    foundation.resources    = "XYYFoundation/Resources/*","XYYFoundation/**/*.{xib,nib,storyboard}" 

    foundation.frameworks = "UIKit", "Foundation", "Accelerate", "CoreFoundation"

    foundation.dependency 'MBProgressHUD' , '~> 0.9.1'
    foundation.dependency 'TTTAttributedLabel'

  end

  s.subspec 'XYYAppComponent' do |appComponent|

    appComponent.source_files = "XYYAppComponent/**/*.{h,m}"

    appComponent.frameworks = "UIKit", "Foundation", "UserNotifications"

    appComponent.dependency 'XYYKit/XYYModel'
    appComponent.dependency 'XYYKit/XYYFoundation'

  end

  s.subspec 'XYYCache' do |cache|

    cache.source_files = "XYYCache/**/*.{h,m}"

    cache.frameworks = "UIKit", "Foundation"
    cache.dependency 'XYYKit/XYYFoundation'

  end

  s.subspec 'XYYNetConnection' do |netConnection|

    netConnection.source_files = "XYYNetConnection/**/*.{h,m}"

    netConnection.frameworks = "UIKit", "Foundation"
    netConnection.dependency 'XYYKit/XYYFoundation'

  end

  s.subspec 'XYYNetImage' do |netImage|

    netImage.source_files = "XYYNetImage/**/*.{h,m}"

    netImage.frameworks = "UIKit", "Foundation"

    netImage.dependency 'XYYKit/XYYFoundation'
    netImage.dependency 'XYYKit/XYYNetConnection'
    netImage.dependency 'XYYKit/XYYCache'
  end

  s.subspec 'XYYPageView' do |pageView|

    pageView.source_files = "XYYPageView/**/*.{h,m}"

    pageView.frameworks = "UIKit", "Foundation"

    pageView.dependency 'XYYKit/XYYFoundation'
    pageView.dependency 'XYYKit/XYYCache'
  end

  s.subspec 'XYYScanImage' do |scanImage|

    scanImage.source_files = "XYYScanImage/**/*.{h,m}"

    scanImage.frameworks = "UIKit", "Foundation"

    scanImage.dependency 'XYYKit/XYYFoundation'
    scanImage.dependency 'XYYKit/XYYPageView'
    scanImage.dependency 'XYYKit/XYYNetImage'
  end

  s.subspec 'XYYImagePicker' do |imagePicker|

    imagePicker.source_files = "XYYImagePicker/**/*.{h,m}"
    imagePicker.resources    = "XYYImagePicker/Resources/*","XYYImagePicker/**/*.{xib,nib,storyboard}"   

    imagePicker.frameworks = "UIKit", "Foundation"

    imagePicker.dependency 'XYYKit/XYYFoundation'

  end

  s.subspec 'XYYCodeScan' do |codeScan|

    codeScan.source_files = "XYYCodeScan/**/*.{h,m}"
    codeScan.resources    = "XYYCodeScan/Resources/*"  

    codeScan.frameworks = "UIKit", "Foundation","AVFoundation", "CoreImage"

    codeScan.dependency 'XYYKit/XYYFoundation'
  end

  #s.subspec 'XYYSocialSNS' do |socialSNS|

    #socialSNS.source_files = "XYYSocialSNS/**/*.{h,m}"
    #socialSNS.resources    = "XYYSocialSNS/Resources/*"  

    #socialSNS.frameworks = "UIKit", "Foundation"

    #socialSNS.dependency 'XYYKit/XYYFoundation'
  #end

  s.subspec 'XYYUserGuidePage' do |userGuidePage|

    userGuidePage.source_files = "XYYUserGuidePage/**/*.{h,m}"

    userGuidePage.frameworks = "UIKit", "Foundation"

    userGuidePage.dependency 'XYYKit/XYYFoundation'
  end

  s.subspec 'XYYDeclineMenu' do |declineMenu|

    declineMenu.source_files = "XYYDeclineMenu/**/*.{h,m}"
    declineMenu.resources    = "XYYDeclineMenu/Resources/*"  

    declineMenu.frameworks = "UIKit", "Foundation"

    declineMenu.dependency 'XYYKit/XYYFoundation'
  end

  s.subspec 'XYYPageLoad' do |pageLoad|

    pageLoad.source_files = "XYYPageLoad/**/*.{h,m}"

    pageLoad.frameworks = "UIKit", "Foundation"

    pageLoad.dependency 'XYYKit/XYYFoundation'
    pageLoad.dependency 'XYYKit/XYYPageView'
  end


  s.subspec 'XYYModel' do |model|

    model.source_files = "XYYModel/**/*.{h,m}" 
    model.frameworks = "UIKit", "Foundation"

  end



end
