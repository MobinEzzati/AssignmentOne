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

        // Set content hugging and compression resistance priorities
        [self.cityLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.tempLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

        [self.cityLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.tempLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

        // Add the labels to the content view of the cell
        [self.contentView addSubview:self.cityLabel];
        [self.contentView addSubview:self.tempLabel];

        // Add constraints to the labels
        [NSLayoutConstraint activateConstraints:@[
            // City label constraints
            [self.cityLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:40],
            [self.cityLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
            [self.cityLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10],

            // Temp label constraints
            [self.tempLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-40],
            [self.tempLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [self.tempLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
            [self.tempLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10]
        ]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Trigger a layout pass to apply the constraints
    [self.contentView layoutIfNeeded];
}

@end
