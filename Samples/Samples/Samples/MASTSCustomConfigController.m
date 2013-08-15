//
//  MASTSCustomConfigController.m
//  AdMobileSamples
//
//  Created on 4/18/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSCustomConfigController.h"

@interface MASTSCustomConfigController ()
@property (nonatomic, assign) id activeResponder;
@property (nonatomic, retain) NSMutableDictionary* settings;
@property (nonatomic, retain) NSMutableDictionary* tagKeys;
@end

@implementation MASTSCustomConfigController

@synthesize delegate;
@synthesize activeResponder, settings, tagKeys;

- (void)dealloc
{
    self.delegate = nil;
    self.activeResponder = nil;
    self.settings = nil;
    self.tagKeys = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Configuration";
        
        UIBarButtonItem* cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                       target:self
                                                                                       action:@selector(cancel:)] autorelease];
        
        UIBarButtonItem* doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                     target:self
                                                                                     action:@selector(done:)] autorelease];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
        self.navigationItem.rightBarButtonItem = doneButton;
        
        self.tagKeys = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)cancel:(id)sender
{
    [self.delegate cancelCustomConfig:self];
}

- (void)done:(id)sender
{
    if ([self.activeResponder isFirstResponder])
        [self.activeResponder endEditing:YES];
    
    [self.delegate customConfig:self updatedWithConfig:self.settings];
}

- (void)setConfig:(NSDictionary *)config
{
    if (self.settings == nil)
        self.settings = [NSMutableDictionary dictionary];
    
    [self.settings addEntriesFromDictionary:config];
    
    [super.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 8;
        case 1:
            return 1;
    }
    
    return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Position and Size";
        case 1:
            return @"Options";
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* NumberCellId = @"nCell";
    static NSString* BooleanCellId = @"bCell";
    static NSString* CheckmarkCellId = @"cCell";
     
    NSString* cellId = NumberCellId;
    
    if (indexPath.section == 1)
        cellId = BooleanCellId;
    else if (indexPath.section == 2)
        cellId = CheckmarkCellId;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:cellId] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        NSInteger tag = arc4random();
        while ([self.tagKeys.allKeys containsObject:[NSNumber numberWithInteger:tag]])
            tag = arc4random();
        
        if (cellId == NumberCellId)
        {
            CGRect frame = CGRectMake(0, 8, 100, 28);
            UITextField* textField = [[[UITextField alloc] initWithFrame:frame] autorelease];
            textField.delegate = self;
            textField.borderStyle = UITextBorderStyleBezel;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.tag = tag;
            cell.accessoryView = textField;           
        }
        else if (cellId == BooleanCellId)
        {
            UISwitch* switchField = [[UISwitch new] autorelease];
            switchField.tag = tag;
            cell.accessoryView = switchField;
            [switchField addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
        }
        else if (cellId == CheckmarkCellId)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    
    NSInteger tag = cell.accessoryView.tag;
    NSString* setting = nil;
    NSString* settingKey = nil;
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                    setting = @"x";
                    settingKey = @"x";
                    break;
                case 1:
                    setting = @"y";
                    settingKey = @"y";
                    break;
                case 2:
                    setting = @"width";
                    settingKey = @"width";
                    break;
                case 3:
                    setting = @"height";
                    settingKey = @"height";
                    break;
                case 4:
                    setting = @"min width";
                    settingKey = @"minWidth";
                    break;
                case 5:
                    setting = @"min height";
                    settingKey = @"minHeight";
                    break;
                case 6:
                    setting = @"max width";
                    settingKey = @"maxWidth";
                    break;
                case 7:
                    setting = @"max height";
                    settingKey = @"maxHeight";
                    break;                    
            }
            break;
        }
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                    setting = @"use internal browser";
                    settingKey = @"useInternalBrowser";
                    break;
            }
            break;
        }
    }
    
    id value = [self.settings valueForKey:settingKey];
    [self.tagKeys setObject:settingKey forKey:[NSNumber numberWithInteger:tag]];
    cell.textLabel.text = setting;
    
    if (cellId == NumberCellId)
    {
        UITextField* textField = (UITextField*)cell.accessoryView;
        textField.text = [value description];
    }
    else if (cellId == BooleanCellId)
    {
        UISwitch* switchField = (UISwitch*)cell.accessoryView;
        [switchField setOn:[value boolValue]];
    }
    else if (cellId == CheckmarkCellId)
    {
        NSUInteger valueIndex = 0;
        
        if (valueIndex == indexPath.row)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else 
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.activeResponder isFirstResponder])
        [self.activeResponder endEditing:YES];
    
    self.activeResponder = nil;
}

#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeResponder = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString* setting = [self.tagKeys objectForKey:[NSNumber numberWithInteger:textField.tag]];
    
    if (textField.keyboardType == UIKeyboardTypeNumberPad)
        [self.settings setValue:[NSNumber numberWithInteger:[textField.text integerValue]] forKey:setting];
    else
        [self.settings setValue:textField.text forKey:setting];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -

- (void)switchChange:(UISwitch*)switchField
{
    if ([self.activeResponder isFirstResponder])
        [self.activeResponder endEditing:YES];

    self.activeResponder = nil;

    NSString* setting = [self.tagKeys objectForKey:[NSNumber numberWithInteger:switchField.tag]];
    [self.settings setValue:[NSNumber numberWithBool:switchField.on] forKey:setting];
}

@end
