//
//  MSCMoreOptionTableViewCell.m
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCell.h"

@interface MSCMoreOptionTableViewCell ()

@property (nonatomic, strong) UIButton *moreOptionButton;

@end

@implementation MSCMoreOptionTableViewCell

////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _moreOptionButtonTitle = @"More";
        _moreOptionButtonBackgroundColor = [UIColor lightGrayColor];
        _moreOptionButtonTitleColor = [UIColor whiteColor];
        
        _moreOptionButton = nil;
        
        for (CALayer *layer in self.layer.sublayers) {
            if ([layer.delegate class] == NSClassFromString(@"UITableViewCellScrollView")) {
                [layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
            }
        }
    }
    return self;
}

- (void)dealloc {
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.delegate class] == NSClassFromString(@"UITableViewCellScrollView")) {
            [layer removeObserver:self forKeyPath:@"sublayers" context:nil];
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject(NSKeyValueObserving)
////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sublayers"]) {
        if ([object isKindOfClass:[CALayer class]]) {
            BOOL moreOptionDelteButtonVisiblePrior = (self.moreOptionButton != nil);
            BOOL swipeToDeleteControlVisible = NO;
            for (CALayer *layer in [(CALayer *)object sublayers]) {
                if ([layer.delegate class] == NSClassFromString(@"UITableViewCellDeleteConfirmationView")) {
                    if (self.moreOptionButton) {
                        swipeToDeleteControlVisible = YES;
                    }
                    else {
                        UIView *deleteConfirmationView = layer.delegate;
                        
                        self.moreOptionButton = [[UIButton alloc] initWithFrame:CGRectZero];
                        [self.moreOptionButton addTarget:self action:@selector(moreOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        self.moreOptionButton.backgroundColor = self.moreOptionButtonBackgroundColor;
                        [self.moreOptionButton setTitleColor:self.moreOptionButtonTitleColor forState:UIControlStateNormal];
                        [self setMoreOptionButtonTitle:self.moreOptionButtonTitle inDeleteConfirmationView:deleteConfirmationView];
                        
                        [deleteConfirmationView addSubview:self.moreOptionButton];
                        
                        break;
                    }
                }
            }
            if (moreOptionDelteButtonVisiblePrior && !swipeToDeleteControlVisible) {
                self.moreOptionButton = nil;
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MSCMoreOptionTableViewCell
////////////////////////////////////////////////////////////////////////

- (void)setMoreOptionButtonTitle:(NSString *)moreOptionButtonTitle {
    if (![_moreOptionButtonTitle isEqualToString:moreOptionButtonTitle]) {
        if (self.moreOptionButton) {
        [self.moreOptionButton setTitle:moreOptionButtonTitle forState:UIControlStateNormal];
        }
        _moreOptionButtonTitle = moreOptionButtonTitle;
    }
}

- (void)setMoreOptionButtonBackgroundColor:(UIColor *)moreOptionButtonBackgroundColor {
    if (![_moreOptionButtonBackgroundColor isEqual:moreOptionButtonBackgroundColor]) {
        self.moreOptionButton.backgroundColor = moreOptionButtonBackgroundColor;
        _moreOptionButtonBackgroundColor = moreOptionButtonBackgroundColor;
    }
}

- (void)setMoreOptionButtonTitleColor:(UIColor *)moreOptionButtonTitleColor {
    if (![_moreOptionButtonTitleColor isEqual:moreOptionButtonTitleColor]) {
        [self.moreOptionButton setTitleColor:moreOptionButtonTitleColor forState:UIControlStateNormal];
        _moreOptionButtonTitleColor = moreOptionButtonTitleColor;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - private methods
////////////////////////////////////////////////////////////////////////

- (void)moreOptionButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate tableView:[self tableView] moreOptionButtonPressedInRowAtIndexPath:[[self tableView] indexPathForCell:self]];
    }
}

- (UITableView *)tableView {
    UIView *tableView = self.superview;
    while(tableView) {
        if(![tableView isKindOfClass:[UITableView class]]) {
			tableView = tableView.superview;
		}
        else {
            return (UITableView *)tableView;
        }
	}
    return nil;
}

- (void)setMoreOptionButtonTitle:(NSString *)title inDeleteConfirmationView:(UIView *)deleteConfirmationView {
    CGFloat priorMoreOptionButtonFrameWidth = self.moreOptionButton.frame.size.width;
    
    [self.moreOptionButton setTitle:self.moreOptionButtonTitle forState:UIControlStateNormal];
    [self.moreOptionButton sizeToFit];
    
    CGRect moreOptionButtonFrame = CGRectZero;
    moreOptionButtonFrame.size.width = self.moreOptionButton.frame.size.width + 30.f;
    moreOptionButtonFrame.size.height = deleteConfirmationView.frame.size.height;
    self.moreOptionButton.frame = moreOptionButtonFrame;
    
    CGRect rect = deleteConfirmationView.frame;
    rect.size.width = self.moreOptionButton.frame.origin.x + self.moreOptionButton.frame.size.width + (deleteConfirmationView.frame.size.width - priorMoreOptionButtonFrameWidth);
    rect.origin.x = deleteConfirmationView.superview.bounds.size.width - rect.size.width;
    deleteConfirmationView.frame = rect;
}

@end
