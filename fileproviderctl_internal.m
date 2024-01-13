#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <IOKit/IOKitLib.h>
#import "TSUtil.h"
#import "SBFApplication.h"

BOOL isJailbroken(void);
char* getBootArgs(void);

int main (int __unused argc, char* argv[]) {
    char* bootArgs = getBootArgs();
    if (bootArgs) {
        if (strstr(bootArgs, "no_untether") != NULL) {
            printf("no_untether boot arg found");
            return -1;
        }
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* TaurinePath = [NSString stringWithFormat:@"%@/Taurine", [[SBFApplication alloc] initWithApplicationBundleIdentifier: @"org.coolstar.taurine"].bundleURL.path];
    if (!isJailbroken() && [fileManager fileExistsAtPath: @"/var/mobile/.untether"]) {
        sleep(45);
        spawnRoot(TaurinePath, @[@"jailbreak"]);
        [UIPasteboard generalPasteboard].string = @"Untethered code execution!!";
    }
}

BOOL isJailbroken(void) {
    for (int i = 0; i <= _dyld_image_count(); i++) {
        char* name = (char*)_dyld_get_image_name(i);
        if (name) {
            if (strcmp(name, "/usr/lib/pspawn_payload-stg2.dylib") == 0) {
                return true;
            }
        }
    }
    return false;
}

char* getBootArgs(void) {
    io_registry_entry_t entry = IORegistryEntryFromPath(MACH_PORT_NULL, "IODeviceTree:/options");    
    CFStringRef cfNvramVar = IORegistryEntryCreateCFProperty(entry, CFSTR("boot-args"), kCFAllocatorDefault, 0);
    char* nvramVar = (char*)CFStringGetCStringPtr(cfNvramVar, kCFStringEncodingUTF8);
    return nvramVar;
}
