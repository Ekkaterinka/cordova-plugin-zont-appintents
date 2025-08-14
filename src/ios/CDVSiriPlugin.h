#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface CDVSiriPlugin : CDVPlugin

- (void)registerForSiriCommands:(CDVInvokedUrlCommand *)command;

@end