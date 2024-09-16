//
//  ViewControllerObjc.h
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 8/30/24.
//

#import <UIKit/UIKit.h>

@interface TableViewControllerObjc : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end
