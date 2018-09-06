//
//  ExampleSourcFile.m
//  VirtualHopeBox
//

/*
*
* VirtualHopeBox 
*
* Copyright © 2009-2015 United States Government as represented by
* the Chief Information Officer of the National Center for Telehealth
* and Technology. All Rights Reserved.
*
* Copyright © 2009-2015 Contributors. All Rights Reserved.
*
* THIS OPEN SOURCE AGREEMENT ("AGREEMENT") DEFINES THE RIGHTS OF USE,
* REPRODUCTION, DISTRIBUTION, MODIFICATION AND REDISTRIBUTION OF CERTAIN
* COMPUTER SOFTWARE ORIGINALLY RELEASED BY THE UNITED STATES GOVERNMENT
* AS REPRESENTED BY THE GOVERNMENT AGENCY LISTED BELOW ("GOVERNMENT AGENCY").
* THE UNITED STATES GOVERNMENT, AS REPRESENTED BY GOVERNMENT AGENCY, IS AN
* INTENDED THIRD-PARTY BENEFICIARY OF ALL SUBSEQUENT DISTRIBUTIONS OR
* REDISTRIBUTIONS OF THE SUBJECT SOFTWARE. ANYONE WHO USES, REPRODUCES,
* DISTRIBUTES, MODIFIES OR REDISTRIBUTES THE SUBJECT SOFTWARE, AS DEFINED
* HEREIN, OR ANY PART THEREOF, IS, BY THAT ACTION, ACCEPTING IN FULL THE
* RESPONSIBILITIES AND OBLIGATIONS CONTAINED IN THIS AGREEMENT.
*
* Government Agency: The National Center for Telehealth and Technology
* Government Agency Original Software Designation: VirtualHopeBox 
* Government Agency Original Software Title: VirtualHopeBox 
* User Registration Requested. Please send email
* with your contact information to: robert.kayl2@us.army.mil
* Government Agency Point of Contact for Original Software: robert.kayl2@us.army.mil
*
*/

#import "CopingCard.h"
#import "CopingSkill.h"
#import "Symptom.h"


@implementation CopingCard

@dynamic problem;
@dynamic created;
@dynamic symptoms;
@dynamic copingSkills;

static NSString *const kSkillsKey = @"copingSkills";
static NSString *const kSymptomsKey = @"symptoms";

- (void)insertObject:(CopingSkill *)value inCopingSkillsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSkillsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSkillsKey]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSkillsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSkillsKey];
}

- (void)removeObjectFromCopingSkillsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSkillsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSkillsKey]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSkillsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSkillsKey];
}

- (void)insertCopingSkills:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSkillsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSkillsKey]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSkillsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSkillsKey];
}

- (void)removeCopingSkillsAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSkillsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSkillsKey]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSkillsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSkillsKey];
}

- (void)replaceObjectInCopingSkillsAtIndex:(NSUInteger)idx withObject:(CopingSkill *)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSkillsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSkillsKey]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSkillsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSkillsKey];
}

- (void)replaceCopingSkillsAtIndexes:(NSIndexSet *)indexes withCopingSkills:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSkillsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSkillsKey]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSkillsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSkillsKey];
}

- (void)addCopingSkillsObject:(CopingSkill *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSkillsKey]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSkillsKey];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSkillsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSkillsKey];
}

- (void)removeCopingSkillsObject:(CopingSkill *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSkillsKey]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSkillsKey];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:kSkillsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSkillsKey];
    }
}

- (void)addCopingSkills:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSkillsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSkillsKey];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:kSkillsKey];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSkillsKey];
    }
}

- (void)removeCopingSkills:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSkillsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSkillsKey];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:kSkillsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSkillsKey];
    }
}

- (void)insertObject:(Symptom *)value inSymptomsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSymptomsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSymptomsKey]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSymptomsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSymptomsKey];
}

- (void)removeObjectFromSymptomsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSymptomsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSymptomsKey]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSymptomsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSymptomsKey];
}

- (void)insertSymptoms:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSymptomsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSymptomsKey]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSymptomsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSymptomsKey];
}

- (void)removeSymptomsAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSymptomsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSymptomsKey]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSymptomsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSymptomsKey];
}

- (void)replaceObjectInSymptomsAtIndex:(NSUInteger)idx withObject:(Symptom *)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSymptomsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSymptomsKey]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSymptomsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSymptomsKey];
}

- (void)replaceSymptomsAtIndexes:(NSIndexSet *)indexes withSymptoms:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSymptomsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSymptomsKey]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSymptomsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSymptomsKey];
}

- (void)addSymptomsObject:(Symptom *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSymptomsKey]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSymptomsKey];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSymptomsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSymptomsKey];
}

- (void)removeSymptomsObject:(Symptom *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSymptomsKey]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSymptomsKey];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:kSymptomsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSymptomsKey];
    }
}

- (void)addSymptoms:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSymptomsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSymptomsKey];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:kSymptomsKey];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSymptomsKey];
    }
}

- (void)removeSymptoms:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSymptomsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSymptomsKey];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:kSymptomsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSymptomsKey];
    }
}

@end
