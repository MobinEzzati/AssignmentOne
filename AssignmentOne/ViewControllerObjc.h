//
//  ViewControllerObjc.h
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 8/30/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewControllerObjc : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView ;




@end

NS_ASSUME_NONNULL_END
