//
//  CustomizeUserCell.m
//  WJ-IN-2014
//
//  Created by lion on 2/25/14.
//  Copyright (c) 2014 Matthias Lukjantschuk. All rights reserved.
//

#import "CustomizeUserCell.h"

@implementation CustomizeUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setLayoutControllers];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setLayoutControllers {
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.backgroundColor = [UIColor clearColor];
    
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 3, 44, 44)];
    [self.imgView setImage:[UIImage imageNamed:@"userIcon"]];
    [self addSubview:self.imgView];
    
    self.imgView.layer.cornerRadius = 22;
    self.imgView.layer.masksToBounds = YES;

    
    self.txtLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 3, 200, 44)];
    [self.txtLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.txtLabel];
    
}

@end
