# Xamarin binding library for Nordic iOS DFU

This is an Xamarin binding library for the Nordic Semiconductors iOS library for updating the firmware of their devices over the air via Bluetooth Low Energy. The native iOS Pod library is located here: https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library

## Folder structure

- Xamarin.Nordic.DFU.iOS.Source/ = Submodule containing [Nordic's code](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library)
- Xamarin.Nordic.DFU.iOS.Source.BuildOutput/ = Build output from building *Xamarin.Nordic.DFU.iOS.Source/*
- Xamarin.Nordic.DFU.iOS.Bindings/ = Xamarin ObjectiveC Binding Library project and nuget files
- Xamarin.Nordic.DFU.iOS.Nuget/ = Nuget pack output, files to upload, output artifact of the pipeline ...

## Requirements

You'll need :

- **MacOS**
  - with **XCode**
  - with **Xamarin.iOS** (obviously)
  - with **ObjectiveSharpie** :

```bash
brew cask install objectivesharpie
```

[More about Objective Sharpie](https://docs.microsoft.com/en-us/xamarin/cross-platform/macios/binding/objective-sharpie/get-started)

## Steps to build

### 1) Checkout with submodule

```bash
git clone --recurse-submodules https://github.com/framinosona/Xamarin.Nordic.DFU.iOS.git
```

Feel free to update the submodule reference / Pull to the latest release from Nordic.

The submodule is located in  **"Xamarin.Nordic.DFU.iOS.Source/"**

### 2) Run **make**

There is a *makefile* included, here is what it does :

- Create output directory **"Xamarin.Nordic.DFU.iOS.Source.BuildOutput/"**
- Build the native pod project for Release/iphonesimulator
- Build the native pod project for Release/iphone
- Move generated files to output folder
  - iphonesimulator - iOSDFULibrary.framework
  - iphonesimulator - iOSDFULibrary.framework.dSYM
  - iphonesimulator - ZIPFoundation.framework
  - iphonesimulator - ZIPFoundation.framework.dSYM
  - iphone - iOSDFULibrary.framework
  - iphone - iOSDFULibrary.framework.dSYM
  - iphone - ZIPFoundation.framework
  - iphone - ZIPFoundation.framework.dSYM
- Creating "Fat libraries" with the correct architectures (see explanation below)
- Generating CSharp binding files by passing those "Fat libraries" to Sharpie


> A fat library is simply a library with multiple architectures. In our case it will contain x86 and arm architectures. The proper name is ‘Universal Static Library’. But we will stick with ‘fat library’ since its smaller to write and that is exactly what our resultant library would be. Fat!!! with multiple architectures in it.
>
> -- <cite>[@hassanahmedkhan](https://medium.com/@hassanahmedkhan/a-noobs-guide-to-creating-a-fat-library-for-ios-bafe8452b84b)</cite>

To use it simply run :

```bash
make
```

### 3) Review generated files

If you observe your Git changes you might see that files prefixed with "Generated_" have been modified.
These files were generated by Sharpie and Sharpie wasn't sure what to do.
You need to review the few `[Verify]` tags manually and remove them to move to the next step.

See [this documentation](https://docs.microsoft.com/en-us/xamarin/cross-platform/macios/binding/objective-sharpie/platform/verify?context=xamarin/ios) explaining the potential `[Verify]` tags.

### 4) Build wrapper project

To build the Xamarin ObjectiveC Binding Library project, simply run :

```bash
MSBuild -p:Configuration=Release -restore:True
```

### 5) Create nuget package

To create a nuget package from the built Binding Library, simply run :

```bash
nuget pack -Symbols -Verbosity Detailed -OutputDirectory "Xamarin.Nordic.DFU.iOS.Nuget"
```
