//
//  AGInputView.h
//  AppGyver
//
//  Created by Rafael Almeida on 6/07/15.
//  Copyright (c) 2015 AppGyver Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PixateFreestyle/PixateFreestyle.h>
#import <PixateFreestyle/PXVirtualStyleableControl.h>
#import <PixateFreestyle/PXUtils.h>
#import <PixateFreestyle/PXOpacityStyler.h>
#import <PixateFreestyle/PXShapeStyler.h>
#import <PixateFreestyle/PXFillStyler.h>
#import <PixateFreestyle/PXBorderStyler.h>
#import <PixateFreestyle/PXBoxShadowStyler.h>
#import <PixateFreestyle/PXTextShadowStyler.h>
#import <PixateFreestyle/PXFontStyler.h>
#import <PixateFreestyle/PXPaintStyler.h>
#import <PixateFreestyle/PXTitaniumMacros.h>
#import <PixateFreestyle/PXVirtualStyleableControl.h>

#import <PixateFreestyle/PXStylingMacros.h>
#import <PixateFreestyle/UIView+PXStyling.h>
#import <PixateFreestyle/UIView+PXStyling-Private.h>

#import <PixateFreestyle/PXUIView.h>

#import <PixateFreestyle/PXStyleable.h>

#import <PixateFreestyle/PXUIButton.h>

@protocol AGInputViewDelegate
- (void)buttonTapped:(UIButton *)button;
@end

@interface AGInputView : UIView
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (nonatomic, weak) NSObject<AGInputViewDelegate>* delegate;

- (IBAction)buttonTapped:(UIButton *)button;

-(void)hideButtons;
-(void)showButtons;
-(void)showLeftButton;
-(void)showRightButton;

@end

@interface FrameObservingInputAccessoryView : UIView

@property (nonatomic, copy) void (^inputAcessoryViewFrameChangedBlock)(CGRect frame);
@property (nonatomic, readonly) CGRect inputAcesssorySuperviewFrame;

@end

