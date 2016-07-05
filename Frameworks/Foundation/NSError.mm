//******************************************************************************
//
// Copyright (c) 2015 Microsoft Corporation. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************

#include "Starboard.h"
#include "StubReturn.h"
#include "Foundation/NSError.h"
#include "NSCFError.h"
#include "BridgeHelpers.h"
#include "ForFoundationOnly.h"

/* Error Domains */
NSString* const NSOSStatusErrorDomain = @"NSOSStatusErrorDomain";
NSString* const NSWINSOCKErrorDomain = @"NSWINSOCKErrorDomain";
NSString* const NSWin32ErrorDomain = @"NSWin32ErrorDomain";
NSString* const NSCocoaErrorDomain = @"NSCocoaErrorDomain";
NSString* const NSMachErrorDomain = @"NSMachErrorDomain";

/* Error Keys */
NSString* const NSUnderlyingErrorKey = @"NSUnderlyingErrorKey";
NSString* const NSLocalizedDescriptionKey = @"NSLocalizedDescriptionKey";
NSString* const NSLocalizedFailureReasonErrorKey = @"NSLocalizedFailureReasonErrorKey";
NSString* const NSLocalizedRecoveryOptionsErrorKey = @"NSLocalizedRecoveryOptionsErrorKey";
NSString* const NSLocalizedRecoverySuggestionErrorKey = @"NSLocalizedRecoverySuggestionErrorKey";
NSString* const NSRecoveryAttempterErrorKey = @"NSRecoveryAttempterErrorKey";
NSString* const NSStringEncodingErrorKey = @"NSStringEncodingErrorKey";
NSString* const NSErrorFailingURLStringKey = @"NSErrorFailingURLStringKey";
NSString* const NSURLErrorKey = @"NSURLErrorKey";
NSString* const NSDebugDescriptionKey = @"NSDebugDescription";

NSString* const NSFilePathErrorKey = @"NSFilePathErrorKey";
NSString* const NSHelpAnchorErrorKey = @"NSHelpAnchorErrorKey";
NSString* const NSURLErrorFailingURLErrorKey = @"NSURLErrorFailingURLErrorKey";
NSString* const NSURLErrorFailingURLStringErrorKey = @"NSURLErrorFailingURLStringErrorKey";
NSString* const NSURLErrorFailingURLPeerTrustErrorKey = @"NSURLErrorFailingURLPeerTrustErrorKey";

@implementation NSError {
    uint8_t _cfinfo[4]; // Maintains same memory layout as CFRuntime
#if __LP64__ // From CFRuntimeBase
    uint32_t _rc;
#endif
    NSInteger _code;
    StrongId<NSString> _domain;
    StrongId<NSDictionary> _userInfo;
}

+ (void)initialize {
    [NSCFError class];
}

- (CFTypeID)_cfTypeID {
    return CFErrorGetTypeID();
}

/**
 @Status Interoperable
*/
+ (instancetype)errorWithDomain:(NSString*)domain code:(NSInteger)code userInfo:(NSDictionary*)dict {
    return [[[self alloc] initWithDomain:domain code:code userInfo:dict] autorelease];
}

/**
 @Status Interoperable
*/
- (instancetype)initWithDomain:(NSString*)domain code:(NSInteger)code userInfo:(NSDictionary*)dict {
    if (self = [super init]) {
        _code = code;
        _domain.attach([domain copy]);
        _userInfo.attach([dict copy]);
    }

    return self;
}

/**
 @Status Interoperable
*/
- (NSString*)description {
    return [(__bridge NSString*)_CFErrorCreateLocalizedDescription((__bridge CFErrorRef)self) autorelease];
}

- (NSString*)debugDescription {
    return [(__bridge NSString*)_CFErrorCreateDebugDescription((__bridge CFErrorRef)self) autorelease];
}

/**
 @Status Interoperable
*/
- (NSString*)domain {
    return [[_domain retain] autorelease];
}

/**
 @Status Interoperable
*/
- (NSInteger)code {
    return _code;
}

/**
 @Status Interoperable
*/
- (NSDictionary*)userInfo {
    return [[_userInfo retain] autorelease];
}

/**
 @Status Interoperable
*/
- (NSString*)localizedDescription {
    NSString* description = [_userInfo objectForKey:NSLocalizedDescriptionKey];
    if (nil != description) {
        return description;
    }

    return [NSString stringWithFormat:@"Error Domain=%@ Code=%ld \"%@\"", (id)_domain, (long)_code, (id)_userInfo];
}

/**
 @Status Interoperable
*/
- (NSString*)localizedFailureReason {
    return [_userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
}

/**
 @Status Stub
 @Notes
*/
+ (BOOL)supportsSecureCoding {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (id)initWithCoder:(NSCoder*)decoder {
    UNIMPLEMENTED();
    return StubReturn();
}

/**
 @Status Stub
 @Notes
*/
- (void)encodeWithCoder:(NSCoder*)coder {
    UNIMPLEMENTED();
}

/**
 @Status Interoperable
*/
- (instancetype)copyWithZone:(NSZone*)zone {
    return [self retain];
}

/**
 @Status Interoperable
*/
- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }

    if (![other isKindOfClass:[NSError class]]) {
        return NO;
    }

    return ([[self domain] isEqual:[other domain]] && [self code] == [other code] && [[self userInfo] isEqual:[other userInfo]]);
}

/**
 @Status Interoperable
*/
- (unsigned int)hash {
    return [self code] + [[self domain] hash];
}

@end