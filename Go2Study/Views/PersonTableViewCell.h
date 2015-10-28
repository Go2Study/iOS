//
//  PersonTableViewCell.h
//  Go2Study
//
//  Created by Ashish Kumar on 28/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;

@end
