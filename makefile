XBUILD=/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
XBUILD_OUTPUT=Xamarin.Nordic.DFU.iOS.Source/Example/build/Release-
BUILD_OUTPUT=Xamarin.Nordic.DFU.iOS.Source.BuildOutput
NUGET_FOLDER=../Xamarin.Nordic.DFU.iOS.Nuget
SHARPIE_OUTPUT=Xamarin.Nordic.DFU.iOS
SHARPIE_NAMESPACE=Xamarin.Nordic.DFU.iOS
SHARPIE_PREFIX=Generated_

all: sharpie

$(BUILD_OUTPUT):
	mkdir $(BUILD_OUTPUT)

$(XBUILD_OUTPUT)iphonesimulator: $(BUILD_OUTPUT)
	$(XBUILD) ONLY_ACTIVE_ARCH=NO -project Xamarin.Nordic.DFU.iOS.Source/_Pods.xcodeproj -sdk iphonesimulator -configuration Release clean build
	mv $(XBUILD_OUTPUT)iphonesimulator/iOSDFULibrary-iOS/iOSDFULibrary.framework $(BUILD_OUTPUT)/iOSDFULibrary-simulator.framework
	mv $(XBUILD_OUTPUT)iphonesimulator/iOSDFULibrary-iOS/iOSDFULibrary.framework.dSYM $(BUILD_OUTPUT)/iOSDFULibrary-simulator.framework.dSYM
	mv $(XBUILD_OUTPUT)iphonesimulator/ZIPFoundation-iOS/ZIPFoundation.framework $(BUILD_OUTPUT)/ZIPFoundation-simulator.framework
	mv $(XBUILD_OUTPUT)iphonesimulator/ZIPFoundation-iOS/ZIPFoundation.framework.dSYM $(BUILD_OUTPUT)/ZIPFoundation-simulator.framework.dSYM

$(XBUILD_OUTPUT)iphoneos: $(BUILD_OUTPUT)
	$(XBUILD) ONLY_ACTIVE_ARCH=NO -project Xamarin.Nordic.DFU.iOS.Source/_Pods.xcodeproj -sdk iphoneos -configuration Release clean build
	mv $(XBUILD_OUTPUT)iphoneos/iOSDFULibrary-iOS/iOSDFULibrary.framework $(BUILD_OUTPUT)/iOSDFULibrary-iphone.framework
	mv $(XBUILD_OUTPUT)iphoneos/iOSDFULibrary-iOS/iOSDFULibrary.framework.dSYM $(BUILD_OUTPUT)/iOSDFULibrary-iphone.framework.dSYM
	mv $(XBUILD_OUTPUT)iphoneos/ZIPFoundation-iOS/ZIPFoundation.framework $(BUILD_OUTPUT)/ZIPFoundation-iphone.framework
	mv $(XBUILD_OUTPUT)iphoneos/ZIPFoundation-iOS/ZIPFoundation.framework.dSYM $(BUILD_OUTPUT)/ZIPFoundation-iphone.framework.dSYM

$(BUILD_OUTPUT)/iOSDFULibrary.framework: $(XBUILD_OUTPUT)iphonesimulator $(XBUILD_OUTPUT)iphoneos
	cp -R $(BUILD_OUTPUT)/iOSDFULibrary-iphone.framework $(BUILD_OUTPUT)/iOSDFULibrary.framework
	rm $(BUILD_OUTPUT)/iOSDFULibrary.framework/iOSDFULibrary
	lipo -create -output $(BUILD_OUTPUT)/iOSDFULibrary.framework/iOSDFULibrary $(BUILD_OUTPUT)/iOSDFULibrary-iphone.framework/iOSDFULibrary $(BUILD_OUTPUT)/iOSDFULibrary-simulator.framework/iOSDFULibrary

$(BUILD_OUTPUT)/ZIPFoundation.framework: $(XBUILD_OUTPUT)iphonesimulator $(XBUILD_OUTPUT)iphoneos
	cp -R $(BUILD_OUTPUT)/ZIPFoundation-iphone.framework $(BUILD_OUTPUT)/ZIPFoundation.framework
	rm $(BUILD_OUTPUT)/ZIPFoundation.framework/ZIPFoundation
	lipo -create -output $(BUILD_OUTPUT)/ZIPFoundation.framework/ZIPFoundation $(BUILD_OUTPUT)/ZIPFoundation-iphone.framework/ZIPFoundation $(BUILD_OUTPUT)/ZIPFoundation-simulator.framework/ZIPFoundation

sharpie: $(BUILD_OUTPUT)/iOSDFULibrary.framework $(BUILD_OUTPUT)/ZIPFoundation.framework
	sharpie bind -p $(SHARPIE_PREFIX) -n $(SHARPIE_NAMESPACE) -o $(SHARPIE_OUTPUT) -framework $(BUILD_OUTPUT)/iOSDFULibrary.framework

msbuild:
	MSBuild $(SHARPIE_OUTPUT)/*.sln -p:Configuration=Release -p:Platform=iPhone -restore:True -p:PackageOutputPath=$(NUGET_FOLDER) -t:rebuild

clean:
	git clean -dfx
	cd Xamarin.Nordic.DFU.iOS.Source
	git clean -dfx
	cd ..
	rm -rf $(BUILD_OUTPUT)/*
	rm $(SHARPIE_OUTPUT)/$(SHARPIE_PREFIX)ApiDefinitions.cs ||:
	rm $(SHARPIE_OUTPUT)/$(SHARPIE_PREFIX)StructsAndEnums.cs ||:
	MSBuild $(SHARPIE_OUTPUT)/*.sln -t:clean