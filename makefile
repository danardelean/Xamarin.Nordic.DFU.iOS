

BUILD_FOLDER=Xamarin.Nordic.DFU.iOS
SOURCE_FOLDER=Xamarin.Nordic.DFU.iOS.Source

XBUILD=/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild


all: sharpie

$(BUILD_FOLDER)/NativeFrameworks/iOSDFULibrary.framework:
	$(XBUILD) ONLY_ACTIVE_ARCH=NO -project $(SOURCE_FOLDER)/_Pods.xcodeproj -sdk iphoneos -configuration Release clean build
	cp -a $(SOURCE_FOLDER)/Example/build/Release-iphoneos/iOSDFULibrary-iOS/. $(BUILD_FOLDER)/NativeFrameworks/
	cp -a $(SOURCE_FOLDER)/Example/build/Release-iphoneos/ZIPFoundation-iOS/. $(BUILD_FOLDER)/NativeFrameworks/

sharpie: $(BUILD_FOLDER)/NativeFrameworks/iOSDFULibrary.framework
	sharpie bind -p Generated_ -n $(BUILD_FOLDER) -o $(BUILD_FOLDER) -framework $(BUILD_FOLDER)/NativeFrameworks/iOSDFULibrary.framework

msbuild:
ifdef NUGET_FOLDER
	MSBuild $(BUILD_FOLDER)/*.sln -t:Rebuild -restore:True -p:Configuration=Release -p:Platform=iPhone -p:PackageOutputPath=$(NUGET_FOLDER)
else
	MSBuild $(BUILD_FOLDER)/*.sln -t:Rebuild -restore:True -p:Configuration=Release -p:Platform=iPhone 
endif

clean:
	# Cleaning outputs
	rm -rf $(BUILD_FOLDER)/NativeFrameworks/*
	# Cleaning nuget cache
	rm -rf ~/.nuget/packages/xamarin.nordic.dfu.ios
	# Cleaning sharpie output
	rm $(BUILD_FOLDER)/Generated_ApiDefinitions.cs ||:
	rm $(BUILD_FOLDER)/Generated_StructsAndEnums.cs ||:
	# Cleaning MSBuild output
	MSBuild $(BUILD_FOLDER)/*.sln -t:clean