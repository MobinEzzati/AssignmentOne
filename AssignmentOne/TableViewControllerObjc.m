//
//  ViewControllerObjc.m
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 8/30/24.
//
#import "TableViewControllerObjc.h"
#import "CityTempCell.h"



@implementation TableViewControllerObjc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the data source with dictionaries for city names and temperature data
    self.dataArray = [[NSMutableArray alloc] init];

    // Initialize and set up the table view
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Register the custom cell class with a different identifier
    [self.tableView registerClass:[CityTempCell class] forCellReuseIdentifier:@"CityTempCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CityMaxMinCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CityCustomFontCell"];
    
    // Add the table view to the view controller's view
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cityData = self.dataArray[indexPath.row];
    
    UITableViewCell *cell;

    // Choose cell type based on row or custom condition
    if (indexPath.row % 3 == 0) {
        // Custom CityTempCell with constraints
        CityTempCell *cityTempCell = [tableView dequeueReusableCellWithIdentifier:@"CityTempCell" forIndexPath:indexPath];
        
        // Configure the cityTempCell
        cityTempCell.cityLabel.text = cityData[@"city"];
        cityTempCell.tempLabel.text = cityData[@"temp"];
        
        return cityTempCell;
        
    } else if (indexPath.row % 3 == 1) {
        // Cell for displaying city name, max, and min temperatures
        cell = [tableView dequeueReusableCellWithIdentifier:@"CityMaxMinCell" forIndexPath:indexPath];
        
        // Configure the cell
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - Max: %@, Min: %@", cityData[@"city"], cityData[@"max"], cityData[@"min"]];
    } else {
        // Cell for displaying city name with different font
        cell = [tableView dequeueReusableCellWithIdentifier:@"CityCustomFontCell" forIndexPath:indexPath];
        
        // Configure the cell with custom font
        cell.textLabel.text = cityData[@"city"];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        cell.textLabel.textColor = [UIColor blueColor];  // Custom text color
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cityData = self.dataArray[indexPath.row];
    NSLog(@"Selected: %@", cityData[@"city"]);
}

@end
