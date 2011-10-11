//
//  NSData+Base64.m
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

#import "NSData+Base64.h"
#import <Foundation/Foundation.h>

static char encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

static char reverseEncodingTable[80] = {    // 0xff => invalid, 0xf0 => '='
    62,     // '+'
    0xff, 0xff, 0xff,
    63,     // '/' 
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, // 0..9
    0xff, 0xff, 0xff, 
    0xf0 ,  // '='
    0xff, 0xff, 0xff, 
    00,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, //A..Z
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51 // a..z
};

@implementation NSData (Base64)

- (NSString *) base64
{
    return [self base64WithLineLength:64];
}

-(NSString *)base64WithLineLength:(unsigned int) lineLength
{
    unsigned long length = [self length];
    const unsigned char *	temp = [self bytes];
    unsigned char * bytes = (unsigned char*)malloc(length+3);
    unsigned long resultLengthWoNl = length*4/3;
    unsigned long resultLength = resultLengthWoNl/lineLength + resultLengthWoNl;
    char *result =  (char*)malloc(resultLength);
    long i = 0;
    long n = 0;
    int blocks = lineLength*3/4;
    uint32_t buffer;
    memcpy(bytes, temp, length);
    
    bytes[length] = 0;
    bytes[length+1] = 0;
    bytes[length+2] = 0;
    
    for (; n<resultLength; ) 
    {
        buffer = (uint8_t)bytes[i]*0x10000 + (uint8_t)bytes[i+1]*0x100 + (uint8_t)bytes[i+2];
        i+=3;
        
        result[n] = encodingTable[(buffer>>18)&0x3F];
        n++;
        
        if (n>resultLength)
            break;
        
        result[n] = encodingTable[(buffer>>12)&0x3F];
        n++;
        
        if (n>resultLength)
            result[n] = '=';
        else
            result[n] = encodingTable[(buffer>>6)&0x3F];
        n++;
        
        if (n>resultLength)
            result[n] = '=';
        else
            result[n] = encodingTable[buffer&0x3F];
        n++;
        if (n>resultLength)
            break;
        
        if (i%blocks == 0) 
        {
            result[n] = '\n';
            n++;
        }
        
        
    }
    result[n] = '\0';
    return [NSString stringWithUTF8String:result];
}

+ (NSData *) dataWithBase64:(NSString *) string {
	NSData *result = [[NSData alloc] initWithBase64:string];
	return [result autorelease];
}

- (id) initWithBase64:(NSString *) string {
	
    unsigned long inpointer = 0;
    unsigned long outpointer = 0;
    unsigned long length = 0;
    unsigned long output_length = 0;
    unsigned char ch = 0;
    unsigned char temp_buffer[4];
    short in_buffer_pointer = 0;
    NSData *base64Data = nil;
    const unsigned char *base64Bytes = nil;
    
    // ===== This part is derived from http://colloquy.info/project
    // Convert the string to ASCII data.    
    base64Data = [string dataUsingEncoding:NSASCIIStringEncoding];
    base64Bytes = [base64Data bytes];
    // =====
    length = [base64Data length];
    unsigned char *result =  (unsigned char*)malloc(length/4*3);
    
    for ( inpointer = 0 ; inpointer < length ; inpointer++ ) {
        ch = base64Bytes[inpointer];
        // check for whitespaces
        if(ch >= 43) 
        {
            ch = reverseEncodingTable[ch-43];
            if (ch == 0xf0 && !output_length) {
                // detecting '='
                output_length = outpointer + 1;
                ch = 0; // fill 0 into data... data output_length already set
            }
            
            // 4 x 6bit => 3 * 8 bit
            temp_buffer [in_buffer_pointer++] = ch;
            
            // we use another buffer because of the whitespaces
            if( in_buffer_pointer == 4 ) {
                in_buffer_pointer = 0;
                // ===== This part is derived from http://colloquy.info/project
                result [outpointer++] = ( temp_buffer[0] << 2 ) | ( ( temp_buffer[1] & 0x30) >> 4 );
                result [outpointer++] = ( ( temp_buffer[1] & 0x0F ) << 4 ) | ( ( temp_buffer[2] & 0x3C ) >> 2 );
                result [outpointer++] = ( ( temp_buffer[2] & 0x03 ) << 6 ) | ( temp_buffer[3] & 0x3F );
                // =====
            }
        }
    }
    output_length = outpointer + 1;
	
    self = [self initWithBytes:result length:output_length];
	return self;
}


@end
