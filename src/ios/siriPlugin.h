#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface siriPlugin : CDVPlugin

- (void)registerForSiriCommands:(CDVInvokedUrlCommand *)command;

@end