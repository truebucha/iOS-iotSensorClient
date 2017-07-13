source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

platform :ios, '9.0'

workspace 'iotSensorClient.xcworkspace'

development_pods = false

post_install do |installer|
    puts("Update debug pod settings to speed up build time")
    Dir.glob(File.join("Pods", "**", "Pods*{debug,Private}.xcconfig")).each do |file|
        File.open(file, 'a') { |f| f.puts "\nDEBUG_INFORMATION_FORMAT = dwarf" }
    end

    next if development_pods

    puts("Update copy pod resources only once to speed up build time")

    Dir.glob(installer.sandbox.target_support_files_root + "Pods-*/*.sh").each do |script|
        flag_name = File.basename(script, ".sh") + "-Installation-Flag"
        folder = "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
        file = File.join(folder, flag_name)
        content = File.read(script)
        content.gsub!(/set -e/, "set -e\nKG_FILE=\"#{file}\"\nif [ -f \"$KG_FILE\" ]; then exit 0; fi\nmkdir -p \"#{folder}\"\ntouch \"$KG_FILE\"")
        File.write(script, content)
    end

    puts("Please clean project after pod install/update = CMD+SHIFT+K in xCode")
end

abstract_target 'iotSensorClientPod' do
    pod 'Charts', '~> 3.0'
    pod 'TinyDropbox', '~> 1.0'
    #pod 'RealmSwift', '~> 2.8'
    #pod 'ObjectMapper', '~> 2.2'

    target :'iotSensorClient' do
        project 'iotSensorClient.xcodeproj'
    end
end
