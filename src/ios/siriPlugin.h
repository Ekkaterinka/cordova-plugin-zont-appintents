#import <Cordova/CDV.h>

@interface siriPlugin : CDVPlugin

- (void)registerForSiriCommands:(CDVInvokedUrlCommand*)command;

@end