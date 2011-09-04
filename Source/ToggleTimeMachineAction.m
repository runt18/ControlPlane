//
//  ToggleTimeMachine.m
//  ControlPlane
//
//  Created by Dustin Rue on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ToggleTimeMachineAction.h"

@implementation ToggleTimeMachineAction

- (NSString *)description
{
	if (turnOn)
		return NSLocalizedString(@"Enabling Time Machine.", @"Act of turning on or enabling Time Machine backup system is being performed");
	else
		return NSLocalizedString(@"Disabling Time Machine.", @"Act of turning off or disabling Time Machine backup system is being performed");
}

- (OSStatus)doEnableTM
// Called when the user clicks the "GetUIDs" button.  This is a typical BetterAuthorizationSample 
// privileged operation implemented in Objective-C.
{
    OSStatus        err;
    BASFailCode     failCode;
    NSString *      bundleID;
    NSDictionary *  request;
    CFDictionaryRef response;
    
    response = NULL;
    
    // Create our request.  Note that NSDictionary is toll-free bridged to CFDictionary, so 
    // we can use an NSDictionary as our request.
    
    request = [NSDictionary dictionaryWithObjectsAndKeys:@kCPHelperToolEnableTMLionCommand, @kBASCommandKey, nil];
    assert(request != NULL);
    
    bundleID = [[NSBundle mainBundle] bundleIdentifier];
    assert(bundleID != NULL);
    
    // Execute it.
    
	err = BASExecuteRequestInHelperTool(
                                        gAuth, 
                                        kCPHelperToolCommandSet, 
                                        (CFStringRef) bundleID, 
                                        (CFDictionaryRef) request, 
                                        &response
                                        );
    
    // If it failed, try to recover.
    
    if ( (err != noErr) && (err != userCanceledErr) ) {
        int alertResult;
        
        failCode = BASDiagnoseFailure(gAuth, (CFStringRef) bundleID);
        
        // At this point we tell the user that something has gone wrong and that we need 
        // to authorize in order to fix it.  Ideally we'd use failCode to describe the type of 
        // error to the user.
        
        alertResult = NSRunAlertPanel(@"ControlPlane Helper Needed", @"ControlPlane needs to install a helper app to enable and disable Time Machine", @"Install", @"Cancel", NULL);
        
        if ( alertResult == NSAlertDefaultReturn ) {
            // Try to fix things.
            
            err = BASFixFailure(gAuth, (CFStringRef) bundleID, CFSTR("CPHelperInstallTool"), CFSTR("CPHelperTool"), failCode);
            
            // If the fix went OK, retry the request.
            
            if (err == noErr) {
                err = BASExecuteRequestInHelperTool(
                                                    gAuth, 
                                                    kCPHelperToolCommandSet, 
                                                    (CFStringRef) bundleID, 
                                                    (CFDictionaryRef) request, 
                                                    &response
                                                    );
            }
        } else {
            err = userCanceledErr;
        }
    }
    
    // If all of the above went OK, it means that the IPC to the helper tool worked.  We 
    // now have to check the response dictionary to see if the command's execution within 
    // the helper tool was successful.
    
    if (err == noErr) {
        err = BASGetErrorFromResponse(response);
    }
    
    // Log our results.
    
    if (err == noErr) {
        NSLog(@"successfully enabled time machine");
    } else {
         NSLog(@"Failed with error %ld.\n", (long) err);
    }
    
    if (response != NULL) {
        CFRelease(response);
    }
}

- (OSStatus)doDisableTM
// Called when the user clicks the "GetUIDs" button.  This is a typical BetterAuthorizationSample 
// privileged operation implemented in Objective-C.
{
    OSStatus        err;
    BASFailCode     failCode;
    NSString *      bundleID;
    NSDictionary *  request;
    CFDictionaryRef response;
    
    response = NULL;
    
    // Create our request.  Note that NSDictionary is toll-free bridged to CFDictionary, so 
    // we can use an NSDictionary as our request.
    
    request = [NSDictionary dictionaryWithObjectsAndKeys:@kCPHelperToolDisableTMLionCommand, @kBASCommandKey, nil];
    assert(request != NULL);
    
    bundleID = [[NSBundle mainBundle] bundleIdentifier];
    assert(bundleID != NULL);
    
    // Execute it.
    
	err = BASExecuteRequestInHelperTool(
                                        gAuth, 
                                        kCPHelperToolCommandSet, 
                                        (CFStringRef) bundleID, 
                                        (CFDictionaryRef) request, 
                                        &response
                                        );
    
    // If it failed, try to recover.
    
    if ( (err != noErr) && (err != userCanceledErr) ) {
        int alertResult;
        
        failCode = BASDiagnoseFailure(gAuth, (CFStringRef) bundleID);
        
        // At this point we tell the user that something has gone wrong and that we need 
        // to authorize in order to fix it.  Ideally we'd use failCode to describe the type of 
        // error to the user.
        
        alertResult = NSRunAlertPanel(@"ControlPlane Helper Needed", @"ControlPlane needs to install a helper app to enable and disable Time Machine", @"Install", @"Cancel", NULL);
        
        if ( alertResult == NSAlertDefaultReturn ) {
            // Try to fix things.
            
            err = BASFixFailure(gAuth, (CFStringRef) bundleID, CFSTR("CPHelperInstallTool"), CFSTR("CPHelperTool"), failCode);
            
            // If the fix went OK, retry the request.
            
            if (err == noErr) {
                err = BASExecuteRequestInHelperTool(
                                                    gAuth, 
                                                    kCPHelperToolCommandSet, 
                                                    (CFStringRef) bundleID, 
                                                    (CFDictionaryRef) request, 
                                                    &response
                                                    );
            }
        } else {
            err = userCanceledErr;
        }
    }
    
    // If all of the above went OK, it means that the IPC to the helper tool worked.  We 
    // now have to check the response dictionary to see if the command's execution within 
    // the helper tool was successful.
    
    if (err == noErr) {
        err = BASGetErrorFromResponse(response);
    }
    
    // Log our results.
    
    if (err == noErr) {
        NSLog(@"successfully disabled time machine");
    } else {
        NSLog(@"Failed with error %ld.\n", (long) err);
    }
    
    if (response != NULL) {
        CFRelease(response);
    }
}

- (BOOL)execute:(NSString **)errorString
{
    
    OSStatus    junk;
    
    // Create the AuthorizationRef that we'll use through this application.  We ignore 
    // any error from this.  A failure from AuthorizationCreate is very unusual, and if it 
    // happens there's no way to recover; Authorization Services just won't work.
    
    junk = AuthorizationCreate(NULL, NULL, kAuthorizationFlagDefaults, &gAuth);
    assert(junk == noErr);
    assert( (junk == noErr) == (gAuth != NULL) );
    
	// For each of our commands, check to see if a right specification exists and, if not,
    // create it.
    //
    // The last parameter is the name of a ".strings" file that contains the localised prompts 
    // for any custom rights that we use.
    
	BASSetDefaultRules(
                       gAuth, 
                       kCPHelperToolCommandSet, 
                       CFBundleGetIdentifier(CFBundleGetMainBundle()), 
                       CFSTR("CPHelperToolAuthorizationPrompts")
                       );

	int state = (turnOn ? 1 : 0);
    OSStatus error;
    
    
    // If the helper tool isn't installed the user will be asked to install it. 
    // This is done using an NSAlert which must run on the main thread
	if (state) {
        [self performSelectorOnMainThread:@selector(doEnableTM) withObject:NULL waitUntilDone:YES];
    }
    else {
        [self performSelectorOnMainThread:@selector(doDisableTM) withObject:NULL waitUntilDone:YES];
    }
    

    error = 0;
	if (error) {
		if (turnOn)
			*errorString = NSLocalizedString(@"Failed enabling Time Machine.", @"");
		else
			*errorString = NSLocalizedString(@"Failed disabling Time Machine.", @"");
		return NO;
	}
    
    
	return YES;
}

+ (NSString *)helpText
{
	return NSLocalizedString(@"The parameter for ToggleTimeMachine actions is either \"1\" "
                             "or \"0\", depending on whether you want to enable or disable Time Machine "
                             "turned on or off.", @"");
}

+ (NSString *)creationHelpText
{
	return NSLocalizedString(@"Set Time Machine", @"Will be followed by 'on' or 'off'");
}

@end
