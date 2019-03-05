#import "MySocketServer.h"
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface MySocketServer ()
{
    CFSocketRef  objSocketListen;
    CFSocketRef  objSocketSession;
}

@end

@implementation MySocketServer

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton* btnOpen = [[UIButton alloc] initWithFrame:CGRectMake( 10, 10, 80, 30)];
    btnOpen.backgroundColor = [UIColor grayColor];
    [btnOpen setTitle:@"Open" forState:UIControlStateNormal];
    [btnOpen addTarget:self action:@selector(btnOpenPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnOpen];
    
    UIButton* btnSend = [[UIButton alloc] initWithFrame:CGRectMake(110, 10, 80, 30)];
    btnSend.backgroundColor = [UIColor grayColor];
    [btnSend setTitle:@"Send" forState:UIControlStateNormal];
    [btnSend addTarget:self action:@selector(btnSendPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSend];
    
    UIButton* btnShut = [[UIButton alloc] initWithFrame:CGRectMake(210, 10, 80, 30)];
    btnShut.backgroundColor = [UIColor grayColor];
    [btnShut setTitle:@"Shut" forState:UIControlStateNormal];
    [btnShut addTarget:self action:@selector(btnShutPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnShut];
}

static void onSocketCallBack(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info)
{
    MySocketServer* server = (__bridge MySocketServer*)info;
    if (server)
    {
        [server socketCallBack:s callbackType:callbackType address:address data:data];
    }
}

- (void)btnOpenPressed:(UIButton*)sender
{
    CFSocketContext context = {0};
    context.info = (void*)CFBridgingRetain(self);
    objSocketListen = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, onSocketCallBack, &context);
    
    int opt = 1;
    setsockopt(CFSocketGetNative(objSocketListen), SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
    
    struct sockaddr_in addr;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(40000);
    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (const uint8_t*)&addr, sizeof(addr));
    CFSocketError e = CFSocketSetAddress(objSocketListen, address);
    CFRelease(address);
    if (e)
    {
        NSLog(@"bind error %ld", e);
    }
    
    CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, objSocketListen, 0);
    CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
    CFRelease(runLoopSource);
    
    NSLog(@"wait client ...");
}

- (void)socketCallBack:(CFSocketRef)socket callbackType:(CFSocketCallBackType)callbackType address:(CFDataRef)address data:(CFDataRef)data
{
    if (socket == objSocketListen)
    {
        if (callbackType == kCFSocketAcceptCallBack)
        {
            NSLog(@"accept ok");
            
            CFSocketNativeHandle* sock = (CFSocketNativeHandle*)data;
            
            CFSocketContext context = {0};
            context.info = (void*)CFBridgingRetain(self);
            objSocketSession = CFSocketCreateWithNative(kCFAllocatorDefault, *sock, kCFSocketDataCallBack, onSocketCallBack, &context);
            
            CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, objSocketSession, 0);
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
            CFRelease(runLoopSource);
        }
        else
        {
            NSLog(@"unexpected socket event");
        }
    }
    
    if (socket == objSocketSession)
    {
        if (callbackType == kCFSocketDataCallBack)
        {
            CFDataRef objLocateAddress = CFSocketCopyAddress(objSocketSession);
            if (objLocateAddress)
            {
                struct sockaddr_in* locate_addr = (struct sockaddr_in*) CFDataGetBytePtr(objLocateAddress);
                NSString* strLocateAddress = [NSString stringWithFormat:@"%s", inet_ntoa(locate_addr->sin_addr)];
                NSLog(@"locate=%@:%d", strLocateAddress, locate_addr->sin_port);
            }
            CFRelease(objLocateAddress);
            
            CFDataRef objRemoteAddress = CFSocketCopyPeerAddress(objSocketSession);
            if (objRemoteAddress)
            {
                struct sockaddr_in* remote_addr = (struct sockaddr_in*) CFDataGetBytePtr(objRemoteAddress);
                NSString* strRemoteAddress = [NSString stringWithFormat:@"%s", inet_ntoa(remote_addr->sin_addr)];
                NSLog(@"remote=%@:%d", strRemoteAddress, remote_addr->sin_port);
            }
            CFRelease(objRemoteAddress);
            
            NSLog(@"recv=%@", [[NSString alloc] initWithData:(__bridge NSData*)data encoding:NSUTF8StringEncoding]);
        }
        else
        {
            NSLog(@"unexpected socket event");
        }
    }
}

- (void)btnSendPressed:(UIButton*)sender
{
    NSString *sendString = [[NSDate date] description];
    NSData *sendData = [sendString dataUsingEncoding:NSUTF8StringEncoding];
    CFSocketError e = CFSocketSendData(objSocketSession, NULL, (__bridge CFDataRef)(sendData), 2.0);
    if (e)
    {
        NSLog(@"send error %ld", e);
    }
    NSLog(@"send=%@", sendString);
}

- (void)btnShutPressed:(UIButton*)sender
{
    if (objSocketListen)
    {
        CFSocketInvalidate(objSocketListen);
        objSocketListen = nil;
    }
    
    if (objSocketSession)
    {
        CFSocketInvalidate(objSocketSession);
        objSocketSession = nil;
    }
}

@end
