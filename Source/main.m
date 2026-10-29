#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <InputMethodKit/InputMethodKit.h>

@interface HYInputController : IMKInputController
@property(strong) NSData *layoutData;
@property UInt32 deadKeyState;
@end

@implementation HYInputController
- (void)activateServer:(id)sender {
    [super activateServer:sender];
    self.deadKeyState = 0;
    self.layoutData = [NSData dataWithContentsOfURL:
        [NSBundle.mainBundle URLForResource:@"Armenian" withExtension:@"uchr"]];
}
- (BOOL)handleEvent:(NSEvent *)event client:(id)sender {
    if (!event || event.type != NSEventTypeKeyDown || !self.layoutData) return NO;
    NSEventModifierFlags flags = event.modifierFlags;
    if (flags & (NSEventModifierFlagCommand | NSEventModifierFlagControl)) return NO;
    UInt32 modifiers = 0;
    if (flags & NSEventModifierFlagShift) modifiers |= shiftKey;
    if (flags & NSEventModifierFlagCapsLock) modifiers |= alphaLock;
    if (flags & NSEventModifierFlagOption) modifiers |= optionKey;
    UniChar characters[16];
    UniCharCount count = 0;
    UInt32 state = self.deadKeyState;
    OSStatus status = UCKeyTranslate((const UCKeyboardLayout *)self.layoutData.bytes,
        event.keyCode, kUCKeyActionDown, modifiers >> 8, LMGetKbdType(), 0,
        &state, 16, &count, characters);
    if (status != noErr) return NO;
    if (!count) { self.deadKeyState = state; return state != 0; }
    if (characters[0] < 0x20 || characters[0] == 0x7f ||
        (characters[0] >= 0xf700 && characters[0] <= 0xf8ff)) return NO;
    self.deadKeyState = state;
    [(id<IMKTextInput>)sender insertText:[NSString stringWithCharacters:characters length:count]
        replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    return YES;
}
@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        [NSApplication sharedApplication];
        NSBundle *bundle = NSBundle.mainBundle;
        __attribute__((objc_precise_lifetime)) IMKServer *server = [[IMKServer alloc]
            initWithName:bundle.infoDictionary[@"InputMethodConnectionName"]
            bundleIdentifier:bundle.bundleIdentifier];
        if (!server) return 1;
        [NSApp run];
        (void)server;
    }
    return 0;
}
