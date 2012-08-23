//
//  RZSplitViewController.m
//  RZSplitViewController-Demo
//
//  Created by Joe Goullaud on 8/6/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RZSplitViewController.h"

@interface RZSplitViewController () <UINavigationControllerDelegate>

@property (strong, nonatomic, readwrite) UIBarButtonItem *collapseBarButton;

- (void)initializeSplitViewController;

- (void)layoutViewControllers;
- (void)layoutViewsForCollapsed:(BOOL)collapsed animated:(BOOL)animated;

- (void)configureCollapseButton:(UIBarButtonItem*)collapseButton forCollapsed:(BOOL)collapsed;

- (void)collapseBarButtonTapped:(id)sender;

@end

#define RZSPLITVIEWCONTROLLER_DEFAULT_MASTER_WIDTH 320.0

@implementation RZSplitViewController
@synthesize viewControllers = _viewControllers;
@synthesize delegate = _delegate;
@synthesize collapseBarButtonImage = _collapseBarButtonImage;
@synthesize expandBarButtonImage = _expandBarButtonImage;
@synthesize collapseBarButton = _collapseBarButton;
@synthesize collapsed = _collapsed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initializeSplitViewController];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initializeSplitViewController];
}

- (void)initializeSplitViewController
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self layoutViewControllers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutViewsForCollapsed:self.collapsed animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Property Accessor Overrides

- (void)setViewControllers:(NSArray *)viewControllers
{
    NSAssert(2 == [viewControllers count], @"You must have exactly 2 view controllers in the array. This array has %d.", [viewControllers count]);
    
    [_viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = (UIViewController*)obj;
        
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }];
    
    _viewControllers = [viewControllers copy];
    
    [_viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = (UIViewController*)obj;
        
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
    }];
    
    [self layoutViewControllers];
}

- (void)setCollapseBarButtonImage:(UIImage *)collapseBarButtonImage
{
    _collapseBarButtonImage = collapseBarButtonImage;
    
    if (!self.collapsed)
    {
        [_collapseBarButton setImage:_collapseBarButtonImage];
    }
}

- (void)setExpandBarButtonImage:(UIImage *)expandBarButtonImage
{
    _expandBarButtonImage = expandBarButtonImage;
    
    if (self.collapsed)
    {
        [_collapseBarButton setImage:_expandBarButtonImage];
    }
}

- (UIBarButtonItem*)collapseBarButton
{
    if (nil == _collapseBarButton)
    {
        _collapseBarButton = [[UIBarButtonItem alloc] initWithTitle:(self.collapsed ? @">>" : @"<<") style:UIBarButtonItemStylePlain target:self action:@selector(collapseBarButtonTapped:)];
        
        [self configureCollapseButton:_collapseBarButton forCollapsed:self.collapsed];
    }
    
    return _collapseBarButton;
}

- (void)setCollapsed:(BOOL)collapsed
{
    [self setCollapsed:collapsed animated:NO];
}

- (void)setCollapsed:(BOOL)collapsed animated:(BOOL)animated
{
    if (collapsed == _collapsed)
    {
        return;
    }
    
    _collapsed = collapsed;
    
    [self layoutViewsForCollapsed:collapsed animated:animated];
}

#pragma mark - Private Property Accessor Overrides

#pragma mark - View Controller Layout

- (void)layoutViewControllers
{
    UIViewController *masterVC = [self.viewControllers objectAtIndex:0];
    UIViewController *detailVC = [self.viewControllers objectAtIndex:1];
    
    UIViewAutoresizing masterAutoResizing = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    UIViewAutoresizing detailAutoResizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    masterVC.view.contentMode = UIViewContentModeScaleToFill;
    masterVC.view.autoresizingMask = masterAutoResizing;
    masterVC.view.autoresizesSubviews = YES;
    masterVC.view.clipsToBounds = YES;
    
    masterVC.view.layer.borderWidth = 1.0;
    masterVC.view.layer.borderColor = [[UIColor blackColor] CGColor];
    masterVC.view.layer.cornerRadius = 4.0;
    
    detailVC.view.contentMode = UIViewContentModeScaleToFill;
    detailVC.view.autoresizingMask = detailAutoResizing;
    detailVC.view.autoresizesSubviews = YES;
    detailVC.view.clipsToBounds = YES;
    
    detailVC.view.layer.borderWidth = 1.0;
    detailVC.view.layer.borderColor = [[UIColor blackColor] CGColor];
    detailVC.view.layer.cornerRadius = 4.0;
    
    [self.view addSubview:masterVC.view];
    [self.view addSubview:detailVC.view];
    
    [self layoutViewsForCollapsed:self.collapsed animated:NO];
}

- (void)layoutViewsForCollapsed:(BOOL)collapsed animated:(BOOL)animated
{
    void (^layoutBlock)(void);
    void (^completionBlock)(BOOL finished);
    
    UIViewController *masterVC = [self.viewControllers objectAtIndex:0];
    UIViewController *detailVC = [self.viewControllers objectAtIndex:1];
    
    CGRect viewBounds = self.view.bounds;
    
    if (collapsed)
    {
        layoutBlock = ^(void){
            CGRect masterFrame = CGRectMake(-RZSPLITVIEWCONTROLLER_DEFAULT_MASTER_WIDTH, 0, RZSPLITVIEWCONTROLLER_DEFAULT_MASTER_WIDTH+1.0, viewBounds.size.height);
            CGRect detailFrame = CGRectMake(0, 0, viewBounds.size.width, viewBounds.size.height);
            
            masterVC.view.frame = masterFrame;
            detailVC.view.frame = detailFrame;
        };
        
        completionBlock = ^(BOOL finished){
            [masterVC.view removeFromSuperview];
        };
    }
    else
    {
        [self.view addSubview:masterVC.view];
        masterVC.view.frame = CGRectMake(-RZSPLITVIEWCONTROLLER_DEFAULT_MASTER_WIDTH, 0, RZSPLITVIEWCONTROLLER_DEFAULT_MASTER_WIDTH+1.0, viewBounds.size.height);
        
        
        layoutBlock = ^(void){
            CGRect masterFrame = CGRectMake(0, 0, RZSPLITVIEWCONTROLLER_DEFAULT_MASTER_WIDTH+1.0, viewBounds.size.height);
            CGRect detailFrame = CGRectMake(RZSPLITVIEWCONTROLLER_DEFAULT_MASTER_WIDTH, 0, viewBounds.size.width - (RZSPLITVIEWCONTROLLER_DEFAULT_MASTER_WIDTH ), viewBounds.size.height);
            
            masterVC.view.frame = masterFrame;
            detailVC.view.frame = detailFrame;
        };
        
        completionBlock = ^(BOOL finished){
            
        };
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionLayoutSubviews
                         animations:layoutBlock
                         completion:completionBlock];
    }
    else
    {
        layoutBlock();
        completionBlock(YES);
    }
}

- (void)configureCollapseButton:(UIBarButtonItem*)collapseButton forCollapsed:(BOOL)collapsed
{
    if (collapsed)
    {
        if (self.expandBarButtonImage)
        {
            [collapseButton setImage:self.expandBarButtonImage];
        }
        else if (self.collapseBarButtonImage)
        {
            [collapseButton setImage:self.collapseBarButtonImage];
        }
        else
        {
            [collapseButton setTitle:@">>"];
        }
    }
    else
    {
        if (self.collapseBarButtonImage)
        {
            [collapseButton setImage:self.collapseBarButtonImage];
        }
        else
        {
            [collapseButton setTitle:@"<<"];
        }
    }
}

#pragma mark - Action Methods

- (void)collapseBarButtonTapped:(id)sender
{
    BOOL collapsed = !self.collapsed;
    
    UIBarButtonItem *buttonItem = (UIBarButtonItem*)sender;
    
    [self configureCollapseButton:buttonItem forCollapsed:collapsed];
    
    [self setCollapsed:collapsed animated:YES];
}

@end


@implementation UIViewController (RZSplitViewController)

- (RZSplitViewController*)rzSplitViewController
{
    if (self.parentViewController)
    {
        if ([self.parentViewController isKindOfClass:[RZSplitViewController class]])
        {
            return (RZSplitViewController*)self.parentViewController;
        }
        else
        {
            return [self.parentViewController rzSplitViewController];
        }
    }

    return nil;
}

@end
