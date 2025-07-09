#import <Cordova/CDV.h>

@interface SiriPlugin : CDVPlugin

- (void)registerForSiriCommands:(CDVInvokedUrlCommand*)command;

@end