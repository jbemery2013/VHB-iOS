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

#import "CopingCardEditViewController.h"

@interface CopingCardEditViewController () {
}

@end

@implementation CopingCardEditViewController
@synthesize copingCard;
@synthesize managedObjectContext;
@synthesize problemText;
@synthesize skills;
@synthesize symptoms;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    problemText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Problem Area" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:.5 alpha:1.0]}];
    problemText.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CopingCardDetailRow" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    self.skills = [[NSMutableArray alloc] init];
    self.symptoms = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)loadCard
{
    if (copingCard) {
        problemText.text = dRaw(encodeKey, self.copingCard.problem);
        for (Symptom *symptom in self.copingCard.symptoms) {
            UITableViewCell *cell = [self createSymptomCell];
            UITextField *field = (UITextField *)[cell viewWithTag:3];
            field.text = dRaw(encodeKey, symptom.symptom);
            [self.symptoms addObject:cell];
        }
        
        for (CopingSkill *skill in self.copingCard.copingSkills) {
            UITableViewCell *cell = [self createSkillCell];
            UITextField *field = (UITextField *)[cell viewWithTag:3];
            field.text = dRaw(encodeKey, skill.skill);
            [self.skills addObject:cell];
        }
    } else {
        [self.skills addObject:[self createSkillCell]];
        [self.symptoms addObject:[self createSymptomCell]];
    }
    
    [self.tableView reloadData];
}

- (BOOL) saveCard
{
    //NSError *error;
    BOOL edit = self.copingCard != nil;
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!edit) {
        self.copingCard = [NSEntityDescription insertNewObjectForEntityForName:@"CopingCard" inManagedObjectContext:self.managedObjectContext];
        self.copingCard.created = [NSDate date];
    } else {
        for (Symptom *symptom in self.copingCard.symptoms) {
            [self.managedObjectContext deleteObject:symptom];
        }
        
        for (CopingSkill *skill in self.copingCard.copingSkills) {
            [self.managedObjectContext deleteObject:skill];
        }
    }
    self.copingCard.problem = eRaw(encodeKey, problemText.text);
    
    [appDelegate saveContext];
//    [self.managedObjectContext save:&error];
//    if (error) {
//        NSLog(@"%@", error);
//        return NO;
//    }
    
    Symptom *sym;
    CopingSkill *skill;
    NSMutableArray *syms = [[NSMutableArray alloc] init];
    NSMutableArray *skls = [[NSMutableArray alloc] init];
    UITextField *field;
    for (UITableViewCell *cell in self.symptoms) {
        field = (UITextField *)[cell viewWithTag:3];
        sym = [NSEntityDescription insertNewObjectForEntityForName:@"Symptom" inManagedObjectContext:self.managedObjectContext];
        sym.symptom = eRaw(encodeKey, field.text);
        sym.order = [NSNumber numberWithInt:(int)syms.count];
        [syms addObject:sym];
    }
    for (UITableViewCell *cell in self.skills) {
        field = (UITextField *)[cell viewWithTag:3];
        skill = [NSEntityDescription insertNewObjectForEntityForName:@"CopingSkill" inManagedObjectContext:self.managedObjectContext];
        skill.skill = eRaw(encodeKey, field.text);
        skill.order = [NSNumber numberWithInt:(int)skls.count];
        [skls addObject:skill];
    }
    
    [appDelegate saveContext];
//    [self.managedObjectContext save:&error];
//    if (error) {
//        NSLog(@"%@", error);
//        return NO;
//    }
    
    for (Symptom *symptom in syms) {
        [self.copingCard addSymptomsObject:symptom];
    }
    for (CopingSkill *skill in skls) {
        [self.copingCard addCopingSkillsObject:skill];
    }
    
    [appDelegate saveContext];
//    [self.managedObjectContext save:&error];
//    if (error) {
//        NSLog(@"%@", error);
//        return NO;
//    }
//    
    return YES;
}

- (UITableViewCell *)createDetailCell
{
    UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CopingCardDetailRow" owner:nil options:nil] objectAtIndex:0];
    
    UIButton *delete = (UIButton *)[cell viewWithTag:5];
    [delete addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UITextField *nextField = (UITextField *)[cell viewWithTag:3];
    nextField.delegate = self;
    
    return cell;
}

- (UITableViewCell *)createSkillCell
{
    UITableViewCell *cell = [self createDetailCell];
    
    UITextField *nextField = (UITextField *)[cell viewWithTag:3];
    
    nextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Coping Skill" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:.5 alpha:1.0]}];
    
    nextField.text = @"";
    
    return cell;
}

- (UITableViewCell *)createSymptomCell
{
    UITableViewCell *cell = [self createDetailCell];
    
    UITextField *nextField = (UITextField *)[cell viewWithTag:3];
    
    nextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Emotion / Symptom" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:.5 alpha:1.0]}];
    
    nextField.text = @"";
    
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath.section == 1 && indexPath.row < self.symptoms.count-1) {
        NSIndexPath *nextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        UITextField *nextField = (UITextField *)[[self.tableView cellForRowAtIndexPath:nextPath] viewWithTag:3];
        [nextField becomeFirstResponder];
    } else if (indexPath.section == 2 && indexPath.row < self.skills.count-1) {
        NSIndexPath *nextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        UITextField *nextField = (UITextField *)[[self.tableView cellForRowAtIndexPath:nextPath] viewWithTag:3];
        [nextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (void)deleteClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath.section == 1) {
        [self.symptoms removeObjectAtIndex:indexPath.row];
    } else if (indexPath.section == 2) {
        [self.skills removeObjectAtIndex:indexPath.row];
    }
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{     
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{     
    return UITableViewCellEditingStyleNone;     
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.symptoms.count + 1;
    } else if (section == 2) {
        return self.skills.count + 1;
    } else {
        return self.copingCard ? 1 : 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == self.symptoms.count) {
            return [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        } else {
            return [self.symptoms objectAtIndex:indexPath.row];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == self.skills.count) {
            return [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        } else {
            return [self.skills objectAtIndex:indexPath.row];
        }
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:.25 alpha:1]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.problemText becomeFirstResponder];
    } else if (indexPath.section == 1) {
        if (indexPath.row == self.symptoms.count) {
            UITableViewCell *cell = [self createSymptomCell];
            [self.symptoms addObject:cell];
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.symptoms.count-1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == self.skills.count) {
            UITableViewCell *cell = [self createSkillCell];
            [self.skills addObject:cell];
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.skills.count-1 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
    } else if (indexPath.section == 3) {
        [self.delegate deleteClicked];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text rangeOfString:@"\n"].location != NSNotFound || [text rangeOfString:@"\t"].location != NSNotFound) {
        [problemText becomeFirstResponder];
        return NO;
    }
    return YES;
}

@end
