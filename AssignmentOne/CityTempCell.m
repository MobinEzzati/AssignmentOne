//
//  CityTempCell.m
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/16/24.
//

#import "CityTempCell.h"

// CityTempCell.m

@implementation CityTempCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialize the labels
        self.cityLabel = [[UILabel alloc] init];
        self.tempLabel = [[UILabel alloc] init];
        
        self.cityLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.tempLabel.translatesAutoresizingMaskIntoConstraints = NO;

        // Add the labels to the content view of the cell
        [self.contentView addSubview:self.cityLabel];
        [self.contentView addSubview:self.tempLabel];

        // Add constraints to the labels
        [NSLayoutConstraint activateConstraints:@[
            // City label constraints
            [self.cityLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15],
            [self.cityLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],

            // Temp label constraints
            [self.tempLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],
            [self.tempLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]
        ]];
    }
    return self;
}

@end
