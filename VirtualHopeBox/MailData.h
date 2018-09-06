//
//  MailData.h
//  VirtualHopeBox
//
//  Created by Stephen ody on 8/4/15.
//  Copyright (c) 2015 The Geneva Foundation. All rights reserved.
//

@interface MailData : NSObject {
    NSArray *mailRecipients;
    NSString *mailSubject;
    NSString *mailBody;
}

@property (nonatomic, retain) NSArray *mailRecipients;
@property (nonatomic, retain) NSString *mailSubject;
@property (nonatomic, retain) NSString *mailBody;

@end
