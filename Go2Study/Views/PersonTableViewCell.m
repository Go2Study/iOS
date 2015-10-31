//
//  PersonTableViewCell.m
//  Go2Study
//
//  Created by Ashish Kumar on 28/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "PersonTableViewCell.h"

@implementation PersonTableViewCell

- (void)awakeFromNib {
    self.photo.layer.cornerRadius = 23;
    self.photo.clipsToBounds = YES;
    self.photo.backgroundColor = [UIColor purpleColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
