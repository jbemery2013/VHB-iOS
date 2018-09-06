//
//  Symptom.h
//  VirtualHopeBox
//
//  Created by Weston Turney-Loos on 1/3/14.
//  Copyright (c) 2014 The Geneva Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CopingCard;

@interface Symptom : NSManagedObject

@property (nonatomic, retain) NSString * symptom;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) CopingCard *copingCard;

@end
