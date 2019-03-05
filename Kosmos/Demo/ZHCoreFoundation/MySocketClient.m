#import "MySocketClient.h"
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface MySocketClient ()
{
    CFSocketRef  objSocketSession;
}

@end

@implementation MySocketClient

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton* btnLink = [[UIButton alloc] initWithFrame:CGRectMake( 10, 10, 80, 30)];
    btnLink.backgroundColor = [UIColor grayColor];
    [btnLink setTitle:@"Link" forState:UIControlStateNormal];
    [btnLink addTarget:self action:@selector(btnLinkPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLink];
    
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
    MySocketClient* server = (__bridge MySocketClient*)info;
    if (server)
    {
        [server socketCallBack:s callbackType:callbackType address:address data:data];
    }
}

- (void)btnLinkPressed:(UIButton*)sender
{
    CFSocketContext context = {0};
    context.info = (void*)CFBridgingRetain(self);
    objSocketSession = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack|kCFSocketDataCallBack, onSocketCallBack, &context);
    
    int opt = 1;
    setsockopt(CFSocketGetNative(objSocketSession), SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
    
    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr("192.168.2.2");
    addr.sin_port = htons(40000);
    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (const uint8_t*)&addr, sizeof(addr));
    CFSocketError e = CFSocketConnectToAddress(objSocketSession, address, 3.0);
    CFRelease(address);
    if (e)
    {
        NSLog(@"connect error %d", (int)e);
    }

    CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, objSocketSession, 0);
    CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
    CFRelease(runLoopSource);
}

- (void)socketCallBack:(CFSocketRef)s callbackType:(CFSocketCallBackType)callbackType address:(CFDataRef)address data:(CFDataRef)data
{
    if (s == objSocketSession)
    {
        if (callbackType == kCFSocketConnectCallBack)
        {
            NSLog(@"link:%@", data);
        }
        else if (callbackType == kCFSocketDataCallBack)
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
            
            NSLog(@"recv:%@", [[NSString alloc] initWithData:(__bridge NSData*)data encoding:NSUTF8StringEncoding]);
        }
        else
        {
            NSLog(@"unexpected socket event");
        }
    }
}

- (void)btnSendPressed:(UIButton*)sender
{
    NSString* sendString = [[NSDate date] description];
    NSData* sendData = [sendString dataUsingEncoding:NSUTF8StringEncoding];
    CFSocketError e = CFSocketSendData(objSocketSession, NULL, (__bridge CFDataRef)(sendData), 2.0);
    if (e)
    {
        NSLog(@"send %ld", e);
    }
    NSLog(@"send:%@", sendString);
}

- (void)btnShutPressed:(UIButton*)sender
{
    if (objSocketSession)
    {
        CFSocketInvalidate(objSocketSession);
        objSocketSession = nil;
    }
}

@end
