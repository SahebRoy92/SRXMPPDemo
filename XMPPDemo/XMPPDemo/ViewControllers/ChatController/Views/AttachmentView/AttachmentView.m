//
//  AttachmentView.m
//  XMPPDemo
//
//  Created by Saheb Roy on 26/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#define OVERLAY_HEIGHT (self.bounds.size.width/4)*2

#import "AttachmentView.h"


@interface AttachmentView()

@property (nonatomic,strong) UIView *overLayView;
@property (nonatomic,strong) NSMutableArray *arrayOfPositions;
@property (nonatomic,strong) NSMutableArray *arrayOfButtons;
@property (nonatomic,strong) UITapGestureRecognizer *tapGes;
@property float startingPosition;
@end

@implementation AttachmentView



-(instancetype)initwithStartingPosition:(float)yPosition andFrame:(CGRect)frame{
    if([super initWithFrame:frame]){
        self.startingPosition = yPosition;
        [self setupViews];
        [self viewsAnimating];
    }
    return self;
}

-(instancetype)init{
    if([super init]){
        [self setupViews];
        [self viewsAnimating];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if([super initWithFrame:frame]){
        [self setupViews];
        [self viewsAnimating];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if([super initWithCoder:aDecoder]){
        [self setupViews];
        [self viewsAnimating];
    }
    return self;
}



#pragma mark -- Setup 

-(void)setupViews{
    
    [self addSubview:self.overLayView];
    
    CGFloat xAx = 0;
    CGFloat yAx = 0;
    CGFloat widthAndHeight = self.overLayView.bounds.size.width/4;
    
    for (int i=0; i<9; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-widthAndHeight, 0, widthAndHeight, widthAndHeight)];
        btn.backgroundColor = [UIColor redColor];
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        btn.layer.borderWidth = 1;
        btn.tag = i;
        [btn addTarget:self action:@selector(log:) forControlEvents:UIControlEventTouchUpInside];
        btn.userInteractionEnabled = YES;
        
        [self.overLayView addSubview:btn];
        [self.arrayOfButtons addObject:btn];
        [self.arrayOfPositions addObject:NSStringFromCGRect(CGRectMake(xAx, yAx, widthAndHeight, widthAndHeight))];
        
        if(xAx >= self.overLayView.bounds.size.width){
            xAx = 0;
            yAx+=widthAndHeight;
        }
        else {
            xAx +=widthAndHeight;
        }
    }
    
    if(self.tapGes == nil){
        self.tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remove)];
    }
    [self addGestureRecognizer:self.tapGes];
    
}


-(void)viewsAnimating{
    float delay = 0;
    for (int i=0; i<self.arrayOfPositions.count; i++) {
        UIButton *btn = [self.arrayOfButtons objectAtIndex:i];
        CGRect frame = CGRectFromString([self.arrayOfPositions objectAtIndex:i]);
        [UIView animateWithDuration:0.2 delay:delay options:1 animations:^{
            btn.frame = frame;
        } completion:nil];
        delay+=0.15;
    }
}

-(IBAction)log:(id)sender{
    NSLog(@"PRETTY FUNCTION");
}


-(void)remove{
    [self removeFromSuperview];
}

-(UIView *)overLayView{
    if(_overLayView == nil){
        _overLayView = [[UIView alloc]initWithFrame:CGRectMake(0, self.startingPosition, self.bounds.size.width, OVERLAY_HEIGHT)];
        _overLayView.backgroundColor = [UIColor whiteColor];
    }
    return _overLayView;
}

-(NSMutableArray *)arrayOfPositions{
    if(_arrayOfPositions == nil){
        _arrayOfPositions = [NSMutableArray array];
    }
    return _arrayOfPositions;
}

-(NSMutableArray *)arrayOfButtons{
    if(_arrayOfButtons == nil){
        _arrayOfButtons = [NSMutableArray array];
    }
    return _arrayOfButtons;
}

@end
