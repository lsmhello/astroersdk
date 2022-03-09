#import "AstroerPlugin.h"
#if __has_include(<astroer/astroer-Swift.h>)
#import <astroer/astroer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "astroer-Swift.h"
#endif

@implementation AstroerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAstroerPlugin registerWithRegistrar:registrar];
}
@end
