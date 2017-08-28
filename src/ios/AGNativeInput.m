

#import "AGNativeInput.h"
#import "ContainerViewController.h"

//
//  AGInputView.m
//  AppGyver
//
//  Created by Rafael Almeida on 6/07/15.
//  Copyright (c) 2015 AppGyver Inc. All rights reserved.
//

@interface AGNativeInput ()

@property (nonatomic) UIEdgeInsets webViewOriginalBaseScrollInsets;

@property (nonatomic, strong) NSDate* lastOnChange;

@property (nonatomic, strong) NSString* lastTextSentOnChange;

@property (nonatomic, strong) NSString* onChangeCallbackId;

@property (nonatomic, strong) NSString* onKeyboardClosedCallbackId;

@property (nonatomic, strong) NSString* onKeyboardActionCallbackId;

@property (nonatomic, strong) NSString* onButtonActionCallbackId;

@property (nonatomic) CGFloat originalLeftXPosition;

@property (nonatomic) BOOL autoCloseKeyboard;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarContainerVerticalSpacingConstraint;

@end

@implementation AGNativeInput

NSTimeInterval ON_CHANGE_LIMIT = 0.5;

//argument positions
int PANEL_ARG = 0;
int INPUT_ARG = 1;
int LEFT_BUTTON_ARG = 2;
int RIGHT_BUTTON_ARG = 3;

@synthesize inputView, webViewOriginalBaseScrollInsets, originalLeftXPosition, lastOnChange, lastTextSentOnChange, onChangeCallbackId, onKeyboardActionCallbackId, onButtonActionCallbackId, autoCloseKeyboard, onKeyboardClosedCallbackId;

- (AGNativeInput*)initWithWebView:(UIWebView*)theWebView {
    self = (AGNativeInput*)[super initWithWebView:(UIWebView*)theWebView];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{
    
    self.inputView = [self loadAGInputView];
    
    //move to setup pixate
//    self.inputView.styleClass = @"nativeInput-panel";
//    self.inputView.inputField.styleClass = @"nativeInput";
//    self.inputView.leftButton.styleClass = @"nativeInput-leftButton";
//    self.inputView.rightButton.styleClass = @"nativeInput-rightButton";
//    [self.inputView updateStyles];
    
    self.inputView.inputField.delegate = self;
    self.inputView.delegate = self;
    
    self.webViewOriginalBaseScrollInsets = self.webViewController.baseScrollInsets;
    
    self.lastOnChange = [NSDate date];
    
    self.originalLeftXPosition = self.inputView.leftButton.frame.origin.x;
    
    [self setupNotifications];
}

-(void)setupNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

-(int)inputViewHeight{
    return 46;
}

-(int)bottomGap{
    return self.webViewContentInsets.bottom - self.inputViewHeight;
}

-(AGInputView*)loadAGInputView{
    
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"AGInputView" owner:self.webView.superview options:nil];
    for (id currentObject in nibViews) {
        if ([currentObject isKindOfClass:[AGInputView class]]) {
            return (AGInputView *) currentObject;
        }
    }
    
    return nil;
}

-(UIEdgeInsets)webViewContentInsets{
    return self.webView.scrollView.contentInset;
}

-(CGRect)superViewFrame{
    return self.webView.superview.frame;
}

-(void)removeInputViewFromSuperView{
    [self.inputView removeFromSuperview];
}

-(void)increaseWebViewBaseScrollInsets{
    CGFloat newBottom = self.webViewOriginalBaseScrollInsets.bottom + self.inputViewHeight;
    
    self.webViewController.baseScrollInsets = UIEdgeInsetsMake(self.webViewController.baseScrollInsets.top, self.webViewController.baseScrollInsets.left, newBottom, self.webViewController.baseScrollInsets.right);
    
    [self.webViewController updateScrollInsets];
}

-(WebViewController*)webViewController{
    return (WebViewController*)self.viewController;
}

-(void)resetWebViewBaseScrollInsets{
    self.webViewController.baseScrollInsets = self.webViewOriginalBaseScrollInsets;
    [self.webViewController updateScrollInsets];
}

-(void)setInputFieldOptions:(NSDictionary*)inputOptions {
    
    NSString* placeHolder = (NSString*)[inputOptions valueForKey:@"placeHolder"];
    NSString* proceedLabelKey = (NSString*)[inputOptions valueForKey:@"proceedLabelKey"];
    inputView.inputField.placeholder = placeHolder;
    
    NSString* type = (NSString*)[inputOptions valueForKey:@"type"];
    if([@"uri" isEqualToString:type]){
        inputView.inputField.keyboardType = UIKeyboardTypeURL;
    }
    else if([@"number" isEqualToString:type]){
        inputView.inputField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    else if([@"email" isEqualToString:type]){
        inputView.inputField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    else{
        inputView.inputField.keyboardType = UIKeyboardTypeDefault;
    }
    
    if ( !proceedLabelKey ) return;
    NSLog(@"proceedLabelKey %@", proceedLabelKey );
    if ( [proceedLabelKey isEqual: @"GO"] ) {
        inputView.inputField.returnKeyType = UIReturnKeyGo;
    }
    else if ( [proceedLabelKey isEqual: @"DONE"] ) {
        inputView.inputField.returnKeyType = UIReturnKeyDone;
    }
    else if ( [proceedLabelKey isEqual: @"JOIN"] ) {
        inputView.inputField.returnKeyType = UIReturnKeyJoin;
    }
    else if ( [proceedLabelKey isEqual: @"NEXT"] ) {
        inputView.inputField.returnKeyType = UIReturnKeyNext;
    }
    else if ( [proceedLabelKey isEqual: @"SEND"] ) {
        inputView.inputField.returnKeyType = UIReturnKeySend;
    }
    else if ( [proceedLabelKey isEqual: @"ROUTE"] ) {
        inputView.inputField.returnKeyType = UIReturnKeyRoute;
    }
    else if ( [proceedLabelKey isEqual: @"SEARCH"] ) {
        inputView.inputField.returnKeyType = UIReturnKeySearch;
    }
    else if ( [proceedLabelKey isEqual: @"CONTINUE"] ) {
        inputView.inputField.returnKeyType = UIReturnKeyContinue;
    }
    // Else it's the default
    
}

-(void)setPanelOptions:(NSDictionary*)options{
}

-(void)setButton:(UIButton*)button withOptions:(NSDictionary*)options{
    
    NSString* buttonLabel = (NSString *) [options valueForKey:@"label"];
    if (buttonLabel) {
        NSLog(@"button label %@", buttonLabel );
        [button setTitle:buttonLabel forState:UIControlStateNormal];
    }

}

-(BOOL)isNotNull:(id)obj{
    return obj != nil &&
            ! [[NSNull null] isEqual:obj];
}


-(BOOL)isValidDictionaryWithValues:(id)options{
    return ([self isNotNull:options] &&
            [options isKindOfClass:[NSDictionary class]] &&
            [(NSDictionary*)options count] > 0);
    
}

-(void)addInputViewToSuperView{
    
    if([self.webView.superview.subviews containsObject:self.inputView]){
        return;
    }
    
    [self.webView.superview addSubview:self.inputView];
    
    self.inputView.translatesAutoresizingMaskIntoConstraints = YES;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(inputView);
    
    [self.webView.superview.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[inputView]|"
                                                                                             options:0 metrics:nil views:viewsDictionary]];
    
    FrameObservingInputAccessoryView *frameObservingView = [[FrameObservingInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, self.webView.superview.frame.size.width, self.inputViewHeight)];
    
    frameObservingView.userInteractionEnabled = NO;
    
    self.inputView.inputField.inputAccessoryView = frameObservingView;
    
    CGFloat parentHeight = self.webView.superview.frame.size.height;
    CGFloat myHeight = self.inputViewHeight;
    CGFloat tabBarHeight = self.tabBarHeight;
    
    __weak typeof(self)weakSelf = self;
    
    frameObservingView.inputAcessoryViewFrameChangedBlock = ^(CGRect inputAccessoryViewFrame){
        CGFloat accessoryY = CGRectGetMinY(inputAccessoryViewFrame);
        
        CGFloat inputViewY = parentHeight - myHeight  - tabBarHeight;
        inputViewY = MIN(inputViewY, MAX(0, accessoryY));
        
        CGRect newFrame = CGRectMake(0,
                                     inputViewY,
                                     weakSelf.webView.superview.frame.size.width,
                                     myHeight);
        
        weakSelf.inputView.frame = newFrame;
    };

    CGFloat inputViewY = parentHeight - myHeight  - tabBarHeight;
    CGRect newFrame = CGRectMake(0,
                                 inputViewY,
                                 self.webView.superview.frame.size.width,
                                 myHeight);
    
    self.inputView.frame = newFrame;
}

-(BOOL)shouldAddTabBarHeightToInsets{
    return (! self.webViewController.navigationController.tabBarController.tabBar.hidden &&
            ! self.webViewController.containerViewController.hidesBottomBarWhenPushed &&
            self.webViewController.navigationController.tabBarController.tabBar.isTranslucent);
}


-(CGFloat)tabBarHeight{
    if([self shouldAddTabBarHeightToInsets]){
        CGRect tabBarFrame = self.webViewController.navigationController.tabBarController.tabBar.frame;
        return tabBarFrame.size.height;
    }
    else{
        return 0.0;
    }
}

- (void)setup:(CDVInvokedUrlCommand*)command{
    [self addInputViewToSuperView];
    
    self.inputView.hidden = YES;
    
    if([self isValidDictionaryWithValues:[command.arguments objectAtIndex:INPUT_ARG]]){
        NSDictionary* inputOptions = (NSDictionary*)[command.arguments objectAtIndex:INPUT_ARG];
        [self setInputFieldOptions:inputOptions];
    }
    
    if([self isValidDictionaryWithValues:[command.arguments objectAtIndex:PANEL_ARG]]){
        NSDictionary* panelOptions = (NSDictionary*)[command.arguments objectAtIndex:PANEL_ARG];
        [self setPanelOptions:panelOptions];
    }
    
    BOOL showLeftButton = [self isValidDictionaryWithValues:[command.arguments objectAtIndex:LEFT_BUTTON_ARG]];
    BOOL showRightButton = [self isValidDictionaryWithValues:[command.arguments objectAtIndex:RIGHT_BUTTON_ARG]];
    
    if(showLeftButton && showRightButton){
        [self setButton:self.inputView.leftButton withOptions:(NSDictionary*)[command.arguments objectAtIndex:LEFT_BUTTON_ARG]];
        [self setButton:self.inputView.rightButton withOptions:(NSDictionary*)[command.arguments objectAtIndex:RIGHT_BUTTON_ARG]];
        
        [self.inputView showButtons];
    }
    else if(showLeftButton){
        [self setButton:self.inputView.leftButton withOptions:(NSDictionary*)[command.arguments objectAtIndex:LEFT_BUTTON_ARG]];
        
        [self.inputView showLeftButton];
    }
    else if(showRightButton){
        [self setButton:self.inputView.rightButton withOptions:(NSDictionary*)[command.arguments objectAtIndex:RIGHT_BUTTON_ARG]];
        
        [self.inputView showRightButton];
    }
    else{
        [self.inputView hideButtons];
    }
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)show:(CDVInvokedUrlCommand*)command{
    if(command.arguments.count > 0 && [self isNotNull:[command.arguments objectAtIndex:0]]){
        NSString* value = [command.arguments objectAtIndex:0];
        self.inputView.inputField.text = value;
    }
    
    [self addInputViewToSuperView];
    
    self.inputView.hidden = NO;
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)showKeyboard:(CDVInvokedUrlCommand*)command{
    [inputView.inputField becomeFirstResponder];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)hide:(CDVInvokedUrlCommand*)command{
    [self resetWebViewBaseScrollInsets];
    self.inputView.hidden = YES;
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)closeKeyboard:(CDVInvokedUrlCommand*)command{
    [self.inputView.inputField resignFirstResponder];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)onButtonAction:(CDVInvokedUrlCommand*)command{
    self.onButtonActionCallbackId = command.callbackId;
}

- (void)onKeyboardAction:(CDVInvokedUrlCommand*)command{
    if(command.arguments.count > 0 && [self isNotNull:[command.arguments objectAtIndex:0]]){
        self.autoCloseKeyboard = [[command.arguments objectAtIndex:0] boolValue];
    }
    self.onKeyboardActionCallbackId = command.callbackId;
}

- (void)onKeyboardClose:(CDVInvokedUrlCommand*)command{
    self.onKeyboardClosedCallbackId = command.callbackId;
}

- (void)onChange:(CDVInvokedUrlCommand*)command{
    self.onChangeCallbackId = command.callbackId;
}

- (void)getValue:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:self.inputView.inputField.text];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setValue:(CDVInvokedUrlCommand*)command{
    if(command.arguments.count > 0 && [self isNotNull:[command.arguments objectAtIndex:0]]){
        NSString* value = [command.arguments objectAtIndex:0];
        self.inputView.inputField.text = value;
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    }
    else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter required!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

-(void)sendOnChangeEvent{
    NSString* text = self.inputView.inputField.text;
    if([text isEqualToString:self.lastTextSentOnChange]){
        return;
    }
    self.lastTextSentOnChange = text;
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:text];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.onChangeCallbackId];
}

//Method use to avoid sending too much events down the pipe for every key stroke
//if a key stroke has
-(void)scheduleOnChangeDelivery{
    __weak typeof (self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        __strong typeof (self) strongSelf = weakSelf;
        
        NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.lastOnChange];
        if(interval > ON_CHANGE_LIMIT){
            strongSelf.lastOnChange = [NSDate new];
            [strongSelf sendOnChangeEvent];
        }
        else{
            [strongSelf scheduleOnChangeDelivery];
        }
        
    });
}

-(void)sendKeyboardAction{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"newline"];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.onKeyboardActionCallbackId];
}

#pragma AGInputViewDelegate
- (void)buttonTapped:(UIButton *)button{
    NSString* side;
    
    if(button == self.inputView.leftButton){
        side = @"left";
    }
    if(button == self.inputView.rightButton){
        side = @"right";
    }
    
    if(self.onButtonActionCallbackId){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:side];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.onButtonActionCallbackId];
    }
}

#pragma UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(self.onChangeCallbackId != nil){
        [self scheduleOnChangeDelivery];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(self.onKeyboardActionCallbackId != nil){
        [self sendKeyboardAction];
        if(self.autoCloseKeyboard){
            [self closeKeyboard:nil];
        }
    }
    return YES;
}

#pragma Keyboard Events

-(void)keyboardDidHide:(NSNotification *)notification{
    if([self isNotNull:self.onKeyboardClosedCallbackId]){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.onKeyboardClosedCallbackId];
    }
}

@end
