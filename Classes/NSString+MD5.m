//
//  NSString+MD5.m
//  

// Copyright (C) 2011 by Markus Hutzler, spiderware gmbh
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSString+MD5.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

const char * lookup = "0123456789abcdef";

- (NSString *) md5
{
    
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    char ret[33];
    CC_MD5( cStr, strlen(cStr), result );
    
    for (int i = 0 ; i<16;i++)
    {
        ret[2*i] = lookup[result[i]/16];
        ret[2*i+1] = lookup[result[i]%16];
    }
    ret[32] = '\0';
    return [NSString stringWithUTF8String:ret];	
    
}

@end
