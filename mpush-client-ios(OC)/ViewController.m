//
//  ViewController.m
//  mpush-client-ios(OC)
//
//  Created by Yonglin on 16/8/29.
//  Copyright © 2016年 Yonglin. All rights reserved.
//

#import "ViewController.h"
#import "MPClient.h"




@interface ViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource, MPClientDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

@property (weak, nonatomic) IBOutlet UITableView *messageTableView;

/** 盛放消息内容的数组  */
@property(nonatomic,strong)NSMutableArray *messages;

/** 绑定的用户id  */
@property(nonatomic,copy)NSString *userId;
//@property (nonatomic, strong)MPMessageHandler *messageHandler;
@property (nonatomic, strong)MPClient *mpClient;

@property (weak, nonatomic) IBOutlet UITextField *allocerTextField;
@property (weak, nonatomic) IBOutlet UITextField *userFromTextField;
@property (weak, nonatomic) IBOutlet UITextField *userToTextField;
@property (weak, nonatomic) IBOutlet UITextField *pushContentTextField;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;
@property (weak, nonatomic) IBOutlet UIButton *unBindButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;


@end

@implementation ViewController


- (NSMutableArray *)messages{
    if (_messages == nil) {
        _messages = [[NSMutableArray alloc] init];
    }
    return _messages ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allocerTextField.text = [MPConfig defaultConfig].allotServer;
    self.allocerTextField.enabled = false;
    
//    MPMessageHandler *messageHandler = [MPMessageHandler shareMessageHandler];
//    messageHandler.delegate = self;
//    self.messageHandler = messageHandler;
    
    MPClient *client = [MPClient sharedClient];
    client.delegate = self;
    self.mpClient = client;
    
    self.messageTableView.dataSource = self;
    self.messageTableView.delegate = self;
    self.messageTextField.delegate = self;
    \
}

#pragma mark - 连接流程操作
// 建立连接
//- (IBAction)connectBtnClick:(id)sender
//{
//    if (!self.messageHandler.isRunning) {
//        [self.messageHandler connectToHostSuccess:^(id successContent) {
//            MPLog(@"connect success call back");
//        }];
//    }
//}
//
//// 断开连接
//- (IBAction)didConnectBtnClick:(id)sender
//{
//    [self.messageHandler disconnectSuccess:^(id successContent) {
//        MPInLog(@"disconnect success");
//    }];
//}
//
//// 绑定用户
//- (IBAction)bindBtnClick:(id)sender
//{
//    NSString *userId = self.userFromTextField.text;
//    if (!userId || [userId isEqualToString:@""]) {
//        return;
//    }
//    self.userId = userId;
//    [self.messageHandler bindUserWithUserId: self.userId];
//}
//// 解绑用户
//- (IBAction)unbindBtnClick:(id)sender
//{
//    [self.messageHandler unbindUserWithUserId:self.userId];
//    self.userId = nil;
//}

// 建立连接
- (IBAction)connectBtnClick:(id)sender
{
    if (!self.mpClient.isRunning) {
        [self.mpClient connectToHost];
    }
}

// 断开连接
- (IBAction)didConnectBtnClick:(id)sender
{
    [self.mpClient disconnect];
}

// 绑定用户
- (IBAction)bindBtnClick:(id)sender
{
    NSString *userId = self.userFromTextField.text;
    if (!userId || [userId isEqualToString:@""]) {
        return;
    }
    self.userId = userId;
    [self.mpClient bindUserWithUserId: self.userId];
}
// 解绑用户
- (IBAction)unbindBtnClick:(id)sender
{
    [self.mpClient unbindUserWithUserId:self.userId];
    self.userId = nil;
}


// 发送消息按钮点击
- (IBAction)senfBtnClick:(id)sender
{
    [self sendPushMessage];
}

- (void) sendPushMessage
{
    // 通过http代理发送数据
    NSMutableDictionary *contentDict = [NSMutableDictionary dictionary];
    contentDict[@"userId"] = self.userToTextField.text;
    contentDict[@"hello"] = self.messageTextField.text;
    
    [self.mpClient sendPushMessageWithContent:contentDict];
    
    [self messageTableViewAddMessage:[NSString stringWithFormat:@"发送数据: %@",self.messageTextField.text]];
}

- (void)messageTableViewAddMessage:(NSString *)message
{
    // PUSH_HOST_ADDRESS
    [self.messages addObject: message];
    [self messageTableViewReloadData];
    self.messageTextField.text = nil;
}
- (void) messageTableViewReloadData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageTableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
        [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark -UITextFieldDelegate
// 发送消息
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendPushMessage];
    return YES;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.messages[indexPath.row];
    return cell;
}

#pragma mark - MPClientDelegate
-(void)client:(MPClient *)client onConnectedSock:(GCDAsyncSocket *)sock{
    MPLog(@"MPClientDelegate onConnectedSock");
}
- (void)client:(MPClient *)client onDisConnectedSock:(GCDAsyncSocket *)sock{
    MPLog(@"MPClientDelegate onDisConnectedSock");
}
- (void)client:(MPClient *)client onHandshakeOk:(int32_t)heartbeat{
    MPLog(@"MPClientDelegate heartbeat: %d", heartbeat);
}

- (void)client:(MPClient *)client onRecieveOkMsg:(MPOkMessage *)okMsg{
    MPLog(@"MPClientDelegate onRecieveOkMsg: %@",[okMsg debugDescription]);
}
- (void)client:(MPClient *)client onRecieveErrorMsg:(MPErrorMessage *)errorMsg{
    MPLog(@"MPClientDelegate onRecieveErrorMsg: %@",[errorMsg debugDescription]);
}

- (void)client:(MPClient *)client onRecievePushMsg:(MPPushMessage *)pushMessage{
    
    MPLog(@"[NSThread currentThread: %@] onRecievePushMsg pushMessage: %@",[NSThread currentThread] ,[pushMessage debugDescription]);
}

@end









