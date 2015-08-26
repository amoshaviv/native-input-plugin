//
//  AGInputView.m
//  AppGyver
//
//  Created by Rafael Almeida on 6/07/15.
//  Copyright (c) 2015 AppGyver Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <PixateFreestyle/PixateFreestyle.h>
#import "CDVPlugin.h"
#import "AGInputView.h"
#import "WebViewController.h"

@interface AGNativeInput : CDVPlugin<UITextFieldDelegate, AGInputViewDelegate>

@property (nonatomic, strong) AGInputView *inputView;


- (void)show:(CDVInvokedUrlCommand*)command;

- (void)closeKeyboard:(CDVInvokedUrlCommand*)command;

- (void)onButtonAction:(CDVInvokedUrlCommand*)command;

- (void)onKeyboardAction:(CDVInvokedUrlCommand*)command;

- (void)hide:(CDVInvokedUrlCommand*)command;

- (void)onChange:(CDVInvokedUrlCommand*)command;

- (void)getValue:(CDVInvokedUrlCommand*)command;

- (void)setValue:(CDVInvokedUrlCommand*)command;

@end
