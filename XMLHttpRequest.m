#import "XMLHttpRequest.h"


@implementation XMLHttpRequest

WebScriptObject* webScriptFunctionCall(WebScriptObject* func, id arg)
{
    // NSLog(@"func = %@", func);
    WebScriptObject* jsThis = [func evaluateWebScript: @"this"];
    return [func callWebScriptMethod: @"call"
                       withArguments: [NSArray arrayWithObjects: jsThis, arg, nil]];
}

NSArray* webScriptObjectKeys(WebScriptObject* obj)
{
    WebScriptObject* func = [obj evaluateWebScript: @"function(obj){var result=[];for(var k in obj)result.push(k);return result;}"];
    WebScriptObject* keys = webScriptFunctionCall(func, obj);
    
    size_t i;
    NSMutableArray* result = [NSMutableArray array];
    WebScriptObject* jsUndefined = [obj evaluateWebScript: @"undefined"];
    for (i = 0; [keys webScriptValueAtIndex: i] != jsUndefined; i++) {
        [result addObject: [keys webScriptValueAtIndex: i]];
    }
    return result;
}

- (id) initWithDetails: (WebScriptObject*) details
              delegate: (id) delegate
{
    NSLog(@"%@ - init", self);

    self = [super init];
    if (! self)
        return nil;
    
    // url
    NSURL* url = [NSURL URLWithString: [details valueForKey: @"url"]];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL: url];
    
    // method
    [req setHTTPMethod: [details valueForKey: @"method"]];
    
    // headers
    if ([details valueForKey: @"headers"]) {
        WebScriptObject* headers = [details valueForKey: @"headers"];
        NSArray* keys = webScriptObjectKeys(headers);
        
        size_t i;
        for (i = 0; i < [keys count]; i++) {
            NSString* key = [keys objectAtIndex: i];
            [req setValue: [headers valueForKey: key] forHTTPHeaderField: key];
        }
    }
    
    // onload
    onLoad_ = [[details valueForKey: @"onload"] retain];
    // onerror
    onError_ = [[details valueForKey: @"onerror"] retain];
    // onreadystatechange
    onReadyStateChange_ = [[details valueForKey: @"onreadystatechange"] retain];
    
    data_ = [[NSMutableData alloc] init];
    response_ = [[NSMutableDictionary alloc] init];
    
    // call onreadystate 1
    [response_ setObject: [NSNumber numberWithInt: 1]
                  forKey: @"readyState"];
    webScriptFunctionCall(onReadyStateChange_, response_);

    // send
    [[NSURLConnection alloc] initWithRequest: req
                                    delegate: self];
    
    // call onreadystate 2
    [response_ setObject: [NSNumber numberWithInt: 2]
                  forKey: @"readyState"];
    webScriptFunctionCall(onReadyStateChange_, response_);    

    return self;
}

- (void) connection: (NSURLConnection*) connection 
 didReceiveResponse: (NSURLResponse*) resp
{    
    NSHTTPURLResponse* http = (NSHTTPURLResponse*) resp;
    [response_ setObject: [NSNumber numberWithInt: [http statusCode]] 
                  forKey: @"status"];
    [response_ setObject: [NSHTTPURLResponse localizedStringForStatusCode: [http statusCode]] 
                  forKey: @"statusText"];
    [response_ setObject: [http allHeaderFields]
                  forKey: @"responseHeaders"];
    
    [data_ setLength: 0];
}

- (void) connection: (NSURLConnection*) connection
     didReceiveData: (NSData*) data
{
    [data_ appendData:data];

    [response_ setObject: [NSNumber numberWithInt: 3]
                  forKey: @"readyState"];
    webScriptFunctionCall(onReadyStateChange_, response_);    
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection
{
    NSString* s = [[NSString alloc] initWithData: data_ encoding: NSUTF8StringEncoding];
    [response_ setObject: s
                  forKey: @"responseText"];
    [s release];
    
    [response_ setObject: [NSNumber numberWithInt: 4]
                  forKey: @"readyState"];
    webScriptFunctionCall(onReadyStateChange_, response_);
    webScriptFunctionCall(onLoad_, response_);
    
    [connection release];
    
    [self release]; // FIXME
}

- (void) dealloc
{
    [response_ release];
    [data_ release];

    [onLoad_ release];
    [onError_ release];
    [onReadyStateChange_ release];
    
    NSLog(@"%@ - dealloc", self);
    [super dealloc];
}

@end