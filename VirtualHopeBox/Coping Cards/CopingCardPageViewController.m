//
//  ExampleSourcFile.m
//  VirtualHopeBox
//

/*
*
* VirtualHopeBox 
*
* Copyright © 2009-2015 United States Government as represented by
* the Chief Information Officer of the National Center for Telehealth
* and Technology. All Rights Reserved.
*
* Copyright © 2009-2015 Contributors. All Rights Reserved.
*
* THIS OPEN SOURCE AGREEMENT ("AGREEMENT") DEFINES THE RIGHTS OF USE,
* REPRODUCTION, DISTRIBUTION, MODIFICATION AND REDISTRIBUTION OF CERTAIN
* COMPUTER SOFTWARE ORIGINALLY RELEASED BY THE UNITED STATES GOVERNMENT
* AS REPRESENTED BY THE GOVERNMENT AGENCY LISTED BELOW ("GOVERNMENT AGENCY").
* THE UNITED STATES GOVERNMENT, AS REPRESENTED BY GOVERNMENT AGENCY, IS AN
* INTENDED THIRD-PARTY BENEFICIARY OF ALL SUBSEQUENT DISTRIBUTIONS OR
* REDISTRIBUTIONS OF THE SUBJECT SOFTWARE. ANYONE WHO USES, REPRODUCES,
* DISTRIBUTES, MODIFIES OR REDISTRIBUTES THE SUBJECT SOFTWARE, AS DEFINED
* HEREIN, OR ANY PART THEREOF, IS, BY THAT ACTION, ACCEPTING IN FULL THE
* RESPONSIBILITIES AND OBLIGATIONS CONTAINED IN THIS AGREEMENT.
*
* Government Agency: The National Center for Telehealth and Technology
* Government Agency Original Software Designation: VirtualHopeBox 
* Government Agency Original Software Title: VirtualHopeBox 
* User Registration Requested. Please send email
* with your contact information to: robert.kayl2@us.army.mil
* Government Agency Point of Contact for Original Software: robert.kayl2@us.army.mil
*
*/


#import "CopingCardPageViewController.h"
#import "VHBAppDelegate.h"
@interface CopingCardPageViewController ()

@end

@implementation CopingCardPageViewController

@synthesize card;
@synthesize backgroundView;
@synthesize scrollView;
@synthesize problemHeader;
@synthesize problemLabel;
@synthesize symptomsHeader;
@synthesize skillsHeader;
@synthesize checkImage;
@synthesize dynamicViews;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dynamicViews = [[NSMutableSet alloc] init];
    checkImage = [UIImage imageNamed:@"card_check.png"];
}

- (void)layout
{
    if (self.card == nil) {
        return;
    }
    
    [dynamicViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [dynamicViews removeAllObjects];
    
    float pad = 10;
    float width = self.view.frame.size.width;
    float checkSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 32 : 22;
    float margin = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 30 : 20;
    CGSize bound = CGSizeMake([UIScreen mainScreen].bounds.size.width - (margin * 4), CGFLOAT_MAX);
    UIFont *headerFont = self.problemHeader.font;
    UIFont *contentFont = self.problemLabel.font;
    CGRect frame = CGRectMake(margin, margin, width - (margin * 4), 0);
    
    float height = [VHBViewUtils boundingRectForString:card.problem withSize:bound font:contentFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft].height;
    
    frame.origin.y += self.problemHeader.frame.size.height + pad;
    self.problemLabel.text = card.problem.length > 0 ? dRaw(encodeKey, card.problem) : @" ";
    frame.size.height = height;
    self.problemLabel.frame = frame;
    
    //    NSLog(@"Problem Label %@", NSStringFromCGRect(frame));
    
    frame.origin.y += frame.size.height + pad;
    height = [VHBViewUtils boundingRectForString:self.symptomsHeader.text withSize:bound font:contentFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft].height;
    
    frame.size.height = height;
    self.symptomsHeader.frame = frame;
    
    //    NSLog(@"Symptom Head %@", NSStringFromCGRect(frame));
    
    
    for (Symptom *sym in card.symptoms) {
        UILabel *lbl = [[UILabel alloc] init];
        lbl.font = self.problemLabel.font;
        lbl.textColor = self.problemLabel.textColor;
        lbl.numberOfLines = 0;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.lineBreakMode = NSLineBreakByWordWrapping;
        lbl.text = sym.symptom.length > 0 ? dRaw(encodeKey, sym.symptom) : @" ";
        
        frame.origin.y += frame.size.height + pad;
        
        height = [VHBViewUtils boundingRectForString:lbl.text withSize:bound font:contentFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft].height;
        
        frame.size.height = height;
        lbl.frame = frame;
        //        NSLog(@"Symptom %@", NSStringFromCGRect(frame));
        [dynamicViews addObject:lbl];
        [scrollView addSubview:lbl];
    }
    
    frame.origin.y += frame.size.height + pad;
    height = [VHBViewUtils boundingRectForString:self.skillsHeader.text withSize:bound font:headerFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft].height;
    frame.size.height = height;
    self.skillsHeader.frame = frame;
    //    NSLog(@"Skill Head %@", NSStringFromCGRect(frame));
    CGSize skillBound = CGSizeMake(bound.width - checkSize - 10, bound.height);
    
    for (CopingSkill *skill in card.copingSkills) {
        UILabel *lbl = [[UILabel alloc] init];
        lbl.font = self.problemLabel.font;
        lbl.textColor = self.problemLabel.textColor;
        lbl.numberOfLines = 0;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.lineBreakMode = NSLineBreakByWordWrapping;
        lbl.text = skill.skill.length > 0 ? dRaw(encodeKey, skill.skill) : @" ";
        
        frame.origin.y += frame.size.height + pad;
        UIImageView *checkView = [[UIImageView alloc] initWithImage:self.checkImage];
        checkView.frame = CGRectMake(frame.origin.x, frame.origin.y, checkSize, checkSize - 2);
        [dynamicViews addObject:checkView];
        [scrollView addSubview:checkView];
        
        frame.origin.x += checkSize + 10;
        frame.size.width -= checkSize + 10;
        height = [VHBViewUtils boundingRectForString:lbl.text withSize:skillBound font:contentFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft].height;
        frame.size.height = height;
        lbl.frame = frame;
        // NSLog(@"Skill %@", NSStringFromCGRect(frame));
        [dynamicViews addObject:lbl];
        [scrollView addSubview:lbl];
        frame.size.width += checkSize + 10;
        frame.origin.x -= checkSize + 10;
    }
    
    
    frame.size.height = frame.origin.y + frame.size.height + margin;
    frame.origin.y = 0;
    frame.origin.x = 0;
    
    frame.size.width = width-(margin * 2);
    self.backgroundView.frame = frame;
    NSLog(@"bgframe %@", NSStringFromCGRect(frame));
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
