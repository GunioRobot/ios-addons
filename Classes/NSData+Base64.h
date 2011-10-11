//
//  NSData+Base64.m
//

@interface NSData (Base64)

+ (NSData *) dataWithBase64:(NSString *) string;
- (id) initWithBase64:(NSString *) string;

- (NSString *) base64WithLineLength:(unsigned int) lineLength;
- (NSString *) base64;

@end