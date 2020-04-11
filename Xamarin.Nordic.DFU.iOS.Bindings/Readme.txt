This is a binding library for 
https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/

We have branch with objc-annotiations here:
https://github.com/tompi/IOS-Pods-DFU-Library

Which makes life easier when binding(clang doesnt autogenerate nasty names for methods, it uses what our annotations says)
So when you want to update to latest nordic lib, get the above lib, add a git remote for the nordic repo,
pull from that and resolve merge conflicts. Then compile with xcode and follow steps below.

NB: If the API has not changed(or if changes will not be used(e.g. new methods)) then you can
skip step 3,4,5,6 and 7.

More or less these steps were followed to get this working:
https://medium.com/@Flash3001/binding-swift-libraries-xamarin-ios-ff32adbc7c76

1. Changed all public classes in nordic lib to have "objc(Classname) public class" instead of "objc public class"
   To make clang output real classnames, not generate new ones

2. Compiled nordic lib in release mode in XCode

3. Use sharpie to generate bindings 
   (Current sharpie is NOT compatible with latest Xcode, you will need to download an older version...
    Check this post if sharpie gives you some strange errors: https://stackoverflow.com/questions/50725608/unsupported-clang-availability-platform-bridgeos/50741521#50741521 )

4. Create this project in visual studio

5. Copy ApiDefinition.cs and Structs.cs from 3.

6. Edit them to remove 99%(just keep nordic stuff)
   You want the stuff at the end of both files, delete about 39k lines from structs and 25k lines from apidef
   Use git diff to see what you need to do!

7. Remember to use baseclass for models/protocols, check compiler output when tuning (sometimes warnings causes errors...)

8. Add iOSDFULibrary and ZIPFoundation as native dependencies to binding project

9. Add a nuget dependencies for "Xamarin.Swift"(at least v 1.0.4) to the APPs using the binding library.
   (This nuget will make sure swift deps are pulled in during debug, and that the final IPA has the
    needed libswift*.dylib files in Payload/<appname>/Frameworks/ and SwiftSupport/ )

10. call "start" on the initiator ;-)

When Nordic updates the lib and you want to pull in latest changes:
Repeat the steps. Please copy "raw" generated files into "Generated" folder, so we can track actual api diffs easily
