

BUILD_FOLDER=Xamarin.Nordic.DFU.iOS
SOURCE_FOLDER=Xamarin.Nordic.DFU.iOS.Source
NUGET_FOLDER=Xamarin.Nordic.DFU.iOS.Nuget

XBUILD=/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild


all: sharpie

$(BUILD_FOLDER)/NativeFrameworks/iOSDFULibrary.framework:
	$(XBUILD) ONLY_ACTIVE_ARCH=NO -project $(SOURCE_FOLDER)/_Pods.xcodeproj -sdk iphoneos -configuration Release clean build
	cp -a $(SOURCE_FOLDER)/Example/build/Release-iphoneos/iOSDFULibrary-iOS/. $(BUILD_FOLDER)/NativeFrameworks/
	cp -a $(SOURCE_FOLDER)/Example/build/Release-iphoneos/ZIPFoundation-iOS/. $(BUILD_FOLDER)/NativeFrameworks/

sharpie: $(BUILD_FOLDER)/NativeFrameworks/iOSDFULibrary.framework
	sharpie bind -p Generated_ -n $(BUILD_FOLDER) -o $(BUILD_FOLDER) -framework $(BUILD_FOLDER)/NativeFrameworks/iOSDFULibrary.framework

msbuild:
	MSBuild $(BUILD_FOLDER)/*.sln -p:Configuration=Release -p:Platform=iPhone -restore:True -p:PackageOutputPath=../$(NUGET_FOLDER) -t:rebuild

clean:
	# Cleaning repo
	git clean -dfx
	# Cleaning submodule repo
	cd $(SOURCE_FOLDER)
	git clean -dfx
	cd ..
	# Cleaning outputs
	rm -rf $(BUILD_FOLDER)/NativeFrameworks/*
	# Cleaning nuget output
	rm -rf $(NUGET_FOLDER)/*
	# Cleaning nuget cache
	rm -rf ~/.nuget/packages/xamarin.nordic.dfu.ios
	# Cleaning sharpie output
	rm $(BUILD_FOLDER)/Generated_ApiDefinitions.cs ||:
	rm $(BUILD_FOLDER)/Generated_StructsAndEnums.cs ||:
	# Cleaning MSBuild output
	MSBuild $(BUILD_FOLDER)/*.sln -t:clean