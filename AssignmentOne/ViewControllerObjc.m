//
//  ViewControllerObjc.m
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 8/30/24.
//

#import "ViewControllerObjc.h"

@interface ViewControllerObjc ()
@property (strong, nonatomic) NSNumber * correctNumb;
@end

@implementation ViewControllerObjc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Ensure the tableView is properly connected and recognized
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title = @"Favorite"; 
    // Register the UITableViewCell class for the cell reuse identifier
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}



// Implement the UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3; // Example: 10 rows
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = @"hellow world";
    
    return cell;
}

@end
