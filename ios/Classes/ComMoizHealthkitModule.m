/**
 * Healthkit
 *
 * Created by Your Name
 * Copyright (c) 2019 Your Company. All rights reserved.
 */

#import "ComMoizHealthkitModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

#import <HealthKit/HealthKit.h>
#import <Foundation/Foundation.h>

@interface ComMoizHealthkitModule()

@property (nonatomic) HKHealthStore *healthStore;
@property (nonatomic) HKObserverQueryCompletionHandler compl;
@property (nonatomic) NSString* url;

struct stepsResults{
    int todayStepsCount;
    int yesterDayStepsCount;
};

@end


@implementation ComMoizHealthkitModule


#pragma mark Internal

// this is generated for your module, please do not change it
//-(id)moduleGUID
//{
//    return @"6ddb2898-e08e-4943-ba68-4f8dbdf85b0a";
//}
//
//// this is generated for your module, please do not change it
//-(NSString*)moduleId
//{
//    return @"gyh.shaperacehealthkit.com";
//}
- (id)moduleGUID
{
  return @"fc5b2ef4-027f-4a43-8831-8a19bf6e8344";
}

// This is generated for your module, please do not change it
- (NSString *)moduleId
{
  return @"com.moiz.healthkit";
}
#pragma mark Lifecycle



-(void)startup
{
    [super startup];
    
    // this method is called when the module is first loaded
    // you *must* call the superclass
}

-(void)shutdown:(id)sender
{
    // this method is called when the module is being unloaded
    // typically this is during shutdown. make sure you don't do too
    // much processing here or the app will be quit forceably
    
    // you *must* call the superclass
    [super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
    // release any resources that have been retained by the module
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
    // optionally release any resources that can be dynamically
    // reloaded once memory is available - such as caches
    [super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
    if (count == 1 && [type isEqualToString:@"my_event"])
    {
        // the first (of potentially many) listener is being added
        // for event named 'my_event'
    }
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
    if (count == 0 && [type isEqualToString:@"my_event"])
    {
        // the last listener called for event named 'my_event' has
        // been removed, we can optionally clean up any resources
        // since no body is listening at this point for that event
    }
}

#pragma Public APIs




// START main API functions


-(void) requestAuthorization:(id)args
{
    self.healthStore = [[HKHealthStore alloc] init];
    
    NSMutableSet* writeTypes = [self getTypes:[args objectAtIndex:0]];
    NSMutableSet* readTypes = [self getTypes:[args objectAtIndex:1]];
    
    
    [self.healthStore requestAuthorizationToShareTypes: writeTypes
                                             readTypes: readTypes
                                            completion:^(BOOL success, NSError *error) {
        NSLog(@"Healthkit module LOG: authorize method with error = %@", error);
        if (!error){
            [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:success]}];
            
        }
        else{
            [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:false], @"error": error.localizedDescription}];
        }
        
    }];
}


-(void) controlPermissions:(id)args{
    
    __block bool isAuthorized = true;
    if (![HKHealthStore isHealthDataAvailable]) isAuthorized = false;
    
    NSMutableSet* writeTypes = [self getTypes:[args objectAtIndex:0]];
    NSMutableSet* authorizedWriteTypes = [self authorizedWriteTypes:[args objectAtIndex:0]];
    NSMutableSet* readTypes = [self getTypes:[args objectAtIndex:1]];
    
    if ([writeTypes count] != [authorizedWriteTypes count]) isAuthorized = false;
    
    [self authorizedReadTypes:[args objectAtIndex:1] completion:^(NSMutableSet * authorizedReadTypes) {
        if ([readTypes count] != [authorizedReadTypes count]) isAuthorized = false;
        
        NSLog(@"Healthkit module LOG: controlpermisson method");
        
        [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:isAuthorized]}];
    }];
}


-(id)isHealthDataAvailable:(id)args{
    return [NSNumber numberWithBool:[HKHealthStore isHealthDataAvailable]];
}

// END main API functions




// START steps background activity functions

-(void)enableBackgroundDelivery:(id)args{
   // NSLog(@"healthkit module LOG: Calling enableBackgroundDeliverySteps")
    
    [self.healthStore enableBackgroundDeliveryForType:[HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierStepCount] frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (!error){
            [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:success]}];
        }
        else{
            [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:false], @"error": error.localizedDescription}];
        }
        
    }];
    //    [self.healthStore enableBackgroundDeliveryForType: [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierStepCount] frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError *error) {
    //        NSLog(@"---count -- %d", [args count])
    //        NSLog(@"---error -- %@", error.localizedDescription)
    //        NSLog(@"---error -- %d", [NSNumber numberWithBool:success])
    //
    ////        NSLog(@"SHAPERACE LOG: enableBackgroundDelveriySteps method with error = %@  %@", error,success);
    //       [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:true]}];
    ////        KrollCallback* callback = [[KrollCallback alloc] init];
    ////
    ////        for (int i = 0; i <= [args count]; i++)
    ////        {
    ////            if([[args objectAtIndex:i] isKindOfClass:[KrollCallback class]]){
    ////                NSLog(@"----found")
    ////
    ////                callback = [args objectAtIndex:i];
    ////            }
    ////            else{
    ////                NSLog(@"Not found...")
    ////            }
    ////        }
    ////        if (callback){
    ////            NSArray* array = [NSArray arrayWithObjects:@"success", nil];
    ////            [callback call:array thisObject:nil];
    ////        }
    ///   }];
}


-(void) disableBackgroundDeliverySteps:(id)args{
    [self.healthStore disableBackgroundDeliveryForType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount] withCompletion:^(BOOL success, NSError *error) {
        if (!error){
            [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:success]}];
        }
        else{
            [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:false], @"error": error.localizedDescription}];
        }
    }];
}


-(BOOL) observeSteps:(id)args{
    
    HKSampleType *quantityType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKObserverQuery *query =
    [[HKObserverQuery alloc]
     initWithSampleType:quantityType
     predicate:nil
     updateHandler:^(HKObserverQuery *query,
                     HKObserverQueryCompletionHandler completionHandler,
                     NSError *error) {
      //  NSLog(@"Healthkit module LOG: observeSteps method with error = %@", error);
        [self getStepsWith:args handler:completionHandler];
        //         [self getSteps:completionHandler];
        
    }];
    [self.healthStore executeQuery:query];
    return true;
}
-(BOOL) observeStatisticsSteps:(id)args{
    
    HKSampleType *quantityType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKObserverQuery *query =
    [[HKObserverQuery alloc]
     initWithSampleType:quantityType
     predicate:nil
     updateHandler:^(HKObserverQuery *query,
                     HKObserverQueryCompletionHandler completionHandler,
                     NSError *error) {
       // NSLog(@"Healthkit module LOG: observeSteps method with error = %@", error);
        [self getStepsStatisticsWith:args handler:completionHandler];
        //         [self getSteps:completionHandler];
        
    }];
    [self.healthStore executeQuery:query];
    return true;
}

- (void) energyBurnedOne:(id)args
    {
      //  NSLog(@"In Energy...")
        
        // end date
        NSArray *readTypes = @[
            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned]
        ];
        [self.healthStore requestAuthorizationToShareTypes:nil
                                                 readTypes:[NSSet setWithArray:readTypes]
                                                completion:^(BOOL success, NSError * _Nullable error) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                if (error) {
                //    NSLog(@"In Energy error...")
                    
                } else {
                    NSDate * modFromDate = [self getDateFromString:[args objectAtIndex:0] ];
                    NSDate * modToDate = [self getDateFromString:[args objectAtIndex:1]];
                    // Sample type
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    
                    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                                     fromDate:modFromDate];
                    
                    anchorComponents.hour = 0;
                    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
                    
                    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                    NSDateComponents *interval = [[NSDateComponents alloc] init];
                    interval.day = 0;
                    interval.hour  = 24;
                    interval.minute = 0;
                    
                    
                    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
                    
                    // Create the query
                 //   NSLog(@"In Energy start query...")
                    
                    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                                           quantitySamplePredicate:nil
                                                                                                           options:HKStatisticsOptionSeparateBySource
                                                                                                        anchorDate:anchorDate
                                                                                                intervalComponents:interval];
                    
                    // Set the results handler
                    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
                        
//                        if (error) {
//                            // Perform proper error handling here
//                            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
//                        }
                        
                        NSDate *endDate = [NSDate date];
                        NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                                 value:-7
                                                                toDate:endDate
                                                               options:0];
                       // NSLog(@"energy burned resultsss --- %@",results);
                        
                        
                        @try {
                            NSMutableArray *arrValues = [NSMutableArray array]; //alloc
                        } @catch (NSException *exception) {
                            NSLog(@"exception %@", exception)
                        } @finally {
                            
                        }
                        NSMutableArray *arrValues = [NSMutableArray array]; //alloc
                        
                        
                        
                        
                        
                        
                        // Plot the daily step counts over the past 7 days
                        __block double steps = 0.0;
                        //NSLog(@"energy burned resultsss --- %@",results);
                        [results enumerateStatisticsFromDate:modFromDate
                                                      toDate:modToDate
                                                   withBlock:^(HKStatistics *result, BOOL *stop) {
                            
                          //  NSLog(@"In Energy start query...1111111")
                            HKQuantity *quantity = result.sumQuantity;
                            //NSLog(@"In Energy start query...33333 %@",quantity)
                            NSString * startDate = [self getStringFromDate:result.startDate];
                            NSString * endDate = [self getStringFromDate:result.endDate];
                            
                            //NSLog(@"In Energy start query22222...")
                           // NSLog(@"In Energy start query22222.co..%@", result.sources);

                            HKSource *source = result.sources.firstObject;
                           // NSLog(@"quantity   --- %@", quantity);

                            NSNumber *mainSteps = [NSNumber numberWithDouble:[quantity doubleValueForUnit:[HKUnit jouleUnit]]] ;
                            NSNumber *mainStepsCalories = [NSNumber numberWithDouble:[quantity doubleValueForUnit:[HKUnit calorieUnit]]] ;
                            //NSLog(@"quantity --- %@",quantity);
                            NSString * name = @"";
                            NSString * bundleIdentifier = @"";
                            
                            if (source != nil){
                                bundleIdentifier = source.bundleIdentifier;
                                name = source.name;
                            }
                            
                            NSDictionary * dict = @{
                                @"startDate" : startDate,
                                @"endDate" : endDate,
                                @"bundleIdentifier" : bundleIdentifier,
                                @"energyJoule" :mainSteps,
                                 @"energyKcal" :mainStepsCalories,
                                @"deviceName": name
                            };
                            // NSLog(@"SHAPERACE LOG: going to check steps greater then zerooo");
                            if(mainSteps.doubleValue > 0){
                                [arrValues addObject:dict];
                            }
                            
                            if (quantity) {
                                HKSource *source = result.sources.firstObject;
                                if (  ![source.bundleIdentifier isEqualToString:@"com.apple.Health"]){
                                    double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                                    steps = steps + value;
                                }
                            }
                            
                        }];
                        
                        
                        
                        [self executeTitaniumCallback: args withResult: @{
                            
                            @"arrValues" : arrValues,
                            @"stepsCount": [NSNumber numberWithFloat:steps],
                            @"success" :[NSNumber numberWithBool:true]
                        }];
                        
                        //           [self executeTitaniumCallback:args withResult:@{
                        //               @"arrValues": arrValues,
                        //               @"success" :[NSNumber numberWithBool:true],
                        //               @"stepsCount" : [NSNumber numberWithFloat:steps],
                        //           }];
                    };
                    
                    [self.healthStore executeQuery:query];
                }
            });
        }];
        
    }

-(NSDate *)getDateFromString:(NSString*)dateString{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    //  [dateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
    NSDate *yourDate = [dateFormatter dateFromString:dateString];
    return yourDate;
}
-(NSString *)getStringFromDate:(NSDate*)date{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
    // [dateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}
-(void) getStepsWith:(id)args handler:(HKObserverQueryCompletionHandler) completionHandler{
    
    
    //    NSCalendar *calendar = [NSCalendar currentCalendar];
    //
    //    NSDate *now = [NSDate date];
    //
    //    NSDate *toDate = [NSDate date]; //
    //    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    //    NSDateComponents *comps = [calendar components:unitFlags fromDate:toDate];
    //    comps.hour   = 00;
    //    comps.minute = 00;
    //    comps.second = 01;
    //    NSDate *tmpFromDate = [calendar dateFromComponents:comps];
   // NSLog(@"from----%@",[args objectAtIndex:0]);
   // NSLog(@"to----%@",[args objectAtIndex:1]);
    
    //NSDate* fromDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:tmpFromDate options:0];
    NSDate * modFromDate = [self getDateFromString:[args objectAtIndex:0] ];
    NSDate * modToDate = [self getDateFromString:[args objectAtIndex:1]];
    [self prepareStepsDataForDates:modFromDate endDate:modToDate args:args handler:completionHandler];
    //    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:fromDate endDate:toDate options:HKQueryOptionNone];
    
}
-(void) getStepsStatisticsWith:(id)args handler:(HKObserverQueryCompletionHandler) completionHandler{
    
    
    //    NSCalendar *calendar = [NSCalendar currentCalendar];
    //
    //    NSDate *now = [NSDate date];
    //
    //    NSDate *toDate = [NSDate date]; //
    //    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    //    NSDateComponents *comps = [calendar components:unitFlags fromDate:toDate];
    //    comps.hour   = 00;
    //    comps.minute = 00;
    //    comps.second = 01;
    //    NSDate *tmpFromDate = [calendar dateFromComponents:comps];
  //  NSLog(@"from----%@",[args objectAtIndex:0]);
   // NSLog(@"to----%@",[args objectAtIndex:1]);
    
    //NSDate* fromDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:tmpFromDate options:0];
    NSDate * modFromDate = [self getDateFromString:[args objectAtIndex:0] ];
    NSDate * modToDate = [self getDateFromString:[args objectAtIndex:1]];
    [self prepareStatisticsStepsDataForDates:modFromDate endDate:modToDate args:args handler:completionHandler];
    //    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:fromDate endDate:toDate options:HKQueryOptionNone];
    
}
-(NSDate*)getStartDate:(NSDate*)date{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    // [dateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
    NSString * newDateString = [dateFormatter stringFromDate:date];
    NSString * modifiedDateString = [NSString stringWithFormat:@"%@ %@", newDateString, @"00:00:00" ];
    
    NSDate * newDate = [self getDateFromString:modifiedDateString];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    
    //    NSDate *newDate = [calendar dateFromComponents:comps];
   // NSLog(@"startDate --- %@", newDate);
    
    return newDate;
}
-(NSDate*)getEndDate:(NSDate*)date{
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    // [dateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
    NSString * newDateString = [dateFormatter stringFromDate:date];
    NSString * modifiedDateString = [NSString stringWithFormat:@"%@ %@", newDateString, @"23:59:59" ];
    
    NSDate * newDate = [self getDateFromString:modifiedDateString];
    
    //NSLog(@"endDate --- %@", newDate);
    
    return newDate;
}
-(void)prepareStepsDataForDates:(NSDate*)startDate endDate:(NSDate*)endDate args:(id)args handler:(HKObserverQueryCompletionHandler) completionHandler{
    NSArray * allBetweenDates = [self getDatesBetweenDates:startDate endDate:endDate];
   // NSLog(@"allBetweenDates   %@ --------- allBetweenDates ", allBetweenDates)
    NSMutableArray * arrResults = [NSMutableArray array];
    for (int i = 0; i < allBetweenDates.count ; i++){
        NSDate *date = allBetweenDates[i];
        
        NSInteger limit = 0;
        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:[self getStartDate:allBetweenDates[i]]  endDate:[self getEndDate:allBetweenDates[i]] options:HKQueryOptionStrictEndDate];
        
        NSString *endKey =  HKSampleSortIdentifierEndDate;
        NSSortDescriptor *endDateSort = [NSSortDescriptor sortDescriptorWithKey: endKey ascending: NO];
        
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]
                                                               predicate: predicate
                                                                   limit: limit
                                                         sortDescriptors: @[endDateSort]
                                                          resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
           // NSLog(@"Healthkit module LOG: getSteps method with error = %@", error);
            if(!error){
                NSDictionary * currentResult = [self prepareStepsResultForTransmission:results];
                [arrResults addObject:currentResult];
               // NSLog(@"results   %@ --------- results ", results)
                
                if (arrResults.count == allBetweenDates.count) {
                    [self executeTitaniumCallback: args withResult: @{
                        @"data" :  @{
                                @"arrResults" : arrResults,
                                @"forDate": [self getStringFromDate:date]
                        } ,
                        @"success" :[NSNumber numberWithBool:true],
                    }];
                    if (completionHandler) completionHandler();
                }
                //                  [self sendStepsDataWith:args results:results];
                //[self sendStepsData: results];
            }
            else{
                if (completionHandler) completionHandler();
                //[self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:false], @"error": error.localizedDescription}];
            }
            
            
        }];
        [self.healthStore executeQuery:query];
    }
    
}
-(void)prepareStatisticsStepsDataForDates:(NSDate*)startDate endDate:(NSDate*)endDate args:(id)args handler:(HKObserverQueryCompletionHandler) completionHandler{
    NSArray * allBetweenDates = [self getDatesBetweenDates:startDate endDate:endDate];
   // NSLog(@"allBetweenDates   %@ --------- allBetweenDates ", allBetweenDates)
    NSMutableArray * arrResults = [NSMutableArray array];
    for (int i = 0; i < allBetweenDates.count ; i++){
        NSDate *date = allBetweenDates[i];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDate * modFromDate = [self getStartDate:allBetweenDates[i]];
        NSDate * modToDate = [self getEndDate:allBetweenDates[i]];
        NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                         fromDate:modFromDate];
        
        anchorComponents.hour = 0;
        NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *interval = [[NSDateComponents alloc] init];
        interval.day = 0;
        interval.hour  = 24;
        interval.minute = 0;
        
        
        HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        
        // Create the query
        HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                               quantitySamplePredicate:nil
                                                                                               options:HKStatisticsOptionSeparateBySource
                                                                                            anchorDate:anchorDate
                                                                                    intervalComponents:interval];
        
        // Set the results handler
        query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
            
//            if (error) {
//                // Perform proper error handling here
//                NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
//            }
            
            NSDate *endDate = [NSDate date];
            NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                     value:-7
                                                    toDate:endDate
                                                   options:0];
            
            
            @try {
                NSMutableArray *arrValues = [NSMutableArray array]; //alloc
            } @catch (NSException *exception) {
                NSLog(@"exception %@", exception)
            } @finally {
                
            }
            NSMutableArray *arrValues = [NSMutableArray array]; //alloc
            
            
            
            
            
            
            // Plot the daily step counts over the past 7 days
            __block double steps = 0.0;
            [results enumerateStatisticsFromDate:modFromDate
                                          toDate:modToDate
                                       withBlock:^(HKStatistics *result, BOOL *stop) {
                
                
                HKQuantity *quantity = result.sumQuantity;
                NSString * startDate = [self getStringFromDate:result.startDate];
                NSString * endDate = [self getStringFromDate:result.endDate];
                HKSource *source = result.sources.firstObject;
                
                NSNumber *mainSteps = [NSNumber numberWithDouble:[quantity doubleValueForUnit:[HKUnit countUnit]]] ;
                
                NSString * name = @"";
                NSString * bundleIdentifier = @"";
                
                if (source != nil){
                    bundleIdentifier = source.bundleIdentifier;
                    name = source.name;
                }
                
                NSDictionary * dict = @{
                    @"startDate" : startDate,
                    @"endDate" : endDate,
                    @"bundleIdentifier" : bundleIdentifier,
                    @"steps" :mainSteps,
                    @"deviceName": name
                    
                };
                // NSLog(@"SHAPERACE LOG: going to check steps greater then zerooo");
                if(mainSteps.doubleValue > 0){
                    [arrValues addObject:dict];
                }
                
                if (quantity) {
                    HKSource *source = result.sources.firstObject;
                    if (  ![source.bundleIdentifier isEqualToString:@"com.apple.Health"]){
                        double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                        steps = steps + value;
                    }
                }
                
            }];
            [arrResults addObject: @{
                @"arrValues" : arrValues,
                @"stepsCount": [NSNumber numberWithFloat:steps],
                @"forDate": [self getStringFromDate:date]
                
            }];
            
            if (arrResults.count == allBetweenDates.count) {
                
                [self executeTitaniumCallback: args withResult: @{
                    
                    @"arrResults" : arrResults,
                    
                    @"success" :[NSNumber numberWithBool:true]
                }];
            }
            //           [self executeTitaniumCallback:args withResult:@{
            //               @"arrValues": arrValues,
            //               @"success" :[NSNumber numberWithBool:true],
            //               @"stepsCount" : [NSNumber numberWithFloat:steps],
            //           }];
        };
        
        [self.healthStore executeQuery:query];
        //         NSInteger limit = 0;
        //        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:[self getStartDate:allBetweenDates[i]]  endDate:[self getEndDate:allBetweenDates[i]] options:HKQueryOptionStrictEndDate];
        //
        //          NSString *endKey =  HKSampleSortIdentifierEndDate;
        //          NSSortDescriptor *endDateSort = [NSSortDescriptor sortDescriptorWithKey: endKey ascending: NO];
        //
        //          HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]
        //                                                                 predicate: predicate
        //                                                                     limit: limit
        //                                                           sortDescriptors: @[endDateSort]
        //                                                            resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
        //              NSLog(@"Healthkit module LOG: getSteps method with error = %@", error);
        //              if(!error){
        //                  NSDictionary * currentResult = [self prepareStepsResultForTransmission:results];
        //                  [arrResults addObject:currentResult];
        //                  NSLog(@"results   %@ --------- results ", results)
        //
        //                  if (arrResults.count == allBetweenDates.count) {
        //
        //                      [self executeTitaniumCallback: args withResult: @{
        //                             @"data" :  @{
        //                                         @"arrResults" : arrResults,
        //                                         @"forDate": [self getStringFromDate:date]
        //                                        } ,
        //                             @"success" :[NSNumber numberWithBool:true],
        //                         }];
        //                  }
        ////                  [self sendStepsDataWith:args results:results];
        //                  //[self sendStepsData: results];
        //                  //if (completionHandler) completionHandler();
        //              }
        //              else{
        //                  //[self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:false], @"error": error.localizedDescription}];
        //              }
        //
        //
        //          }];
        //          [self.healthStore executeQuery:query];
    }
    
}
// END steps background activity functions




// START sending steps related functions


-(void) sendStepsDataWith:(id)args results: (NSArray*) results{
    //  NSLog(@"rwsults -----------%@", results) hussain
    [self executeTitaniumCallback:args withResult:[self prepareStepsResultForTransmission:results]];
    // NSString * total = [[self prepareStepsResultForTransmission:results] valueForKey:@"todayStepsCount"];
    //    [[[UIAlertView alloc]initWithTitle:@"Alert" message:[NSString stringWithFormat:@"%@",total] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    //    struct stepsResults preparedResults = [self prepareStepsResultForTransmission:results];
    //    NSLog(@"stepsResults -----------%@", preparedResults)
    //
    //
    //    NSDate* now = [NSDate date];
    //    NSCalendar* calendar = [NSCalendar currentCalendar];
    //    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    //    NSDateComponents* comp = [calendar components:unitFlags fromDate:now];
    //
    //    NSString* dateAsString = [NSString stringWithFormat:@"%li-%li-%li", (long)comp.year, (long)comp.month, (long)comp.day];
    //
    //    NSString* parameters = [NSString stringWithFormat:@"&date=%@&steps=%i&steps_yesterday=%i", dateAsString, preparedResults.todayStepsCount, preparedResults.yesterDayStepsCount];
    
    //    NSString* addr = [self.url stringByAppendingString: parameters];
    //
    //
    //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:addr]];
    //
    //    [request setHTTPMethod:@"GET"];
    //
    //    NSLog(@"SHAPERACE LOG: sendStepsData method");
    //
    //    NSError *error = [[NSError alloc] init];
    //    NSHTTPURLResponse *responseCode = nil;
    //
    //    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
}



-(NSDictionary*) prepareStepsResultForTransmission:(NSArray*)results{
    
    double stepsCount = 0.0;
    
    
    // NSLog(@"make array") hussain
    @try {
        NSMutableArray *arrValues = [NSMutableArray array]; //alloc
    } @catch (NSException *exception) {
        NSLog(@"exception %@", exception)
    } @finally {
        
    }
    NSMutableArray *arrValues = [NSMutableArray array]; //alloc
    
    for (HKQuantitySample *sample in results) {
        //NSComparisonResult compareResult = [sample.startDate compare:fromDate];
        // NSLog(@"source -----  %@", sample.source.bundleIdentifier); hussain
        if ([sample.source.bundleIdentifier isEqualToString:@"com.apple.Health"]) continue;
        NSString * startDate = [self getStringFromDate:sample.startDate];
        NSString * endDate = [self getStringFromDate:sample.endDate];
        NSNumber *steps = [NSNumber numberWithDouble:[sample.quantity doubleValueForUnit:[HKUnit countUnit]]] ;
        NSString * bundleIdentifier = sample.source.bundleIdentifier;
        NSDictionary * dict = @{
            
            @"startDate" : startDate,
            @"endDate" : endDate,
            @"bundleIdentifier" : bundleIdentifier,
            @"steps" : steps,
            @"deviceName":sample.source.name
        };
        
        [arrValues addObject:dict];
        stepsCount += [sample.quantity doubleValueForUnit:[HKUnit countUnit]];
    }
    // NSLog(@"%@",arrValues);hussain
    return @{
        @"arrValues" : arrValues,
        //        @"success" :[NSNumber numberWithBool:true],
        @"stepsCount" : [NSNumber numberWithInt:stepsCount],
    };
}

-(NSInteger) daysBetweenDate:(NSDate *)firstDate andDate:(NSDate *)secondDate {
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [currentCalendar components: NSDayCalendarUnit fromDate: firstDate toDate: secondDate options: 0];
    
    NSInteger days = [components day];
    
    return days;
}
-(NSArray*)getDatesBetweenDates:(NSDate*)startDate endDate:(NSDate*)endDate{
    
    
    if([self daysBetweenDate:startDate andDate:endDate] == 0)
    {
        return [NSArray arrayWithObject:startDate];
    }
    else{
        
        
        NSMutableArray *dates = [@[startDate] mutableCopy];
        
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        
        for (int i = 1; i < components.day; ++i) {
            NSDateComponents *newComponents = [NSDateComponents new];
            newComponents.day = i;
            
            NSDate *date = [gregorianCalendar dateByAddingComponents:newComponents
                                                              toDate:startDate
                                                             options:0];
            [dates addObject:date];
        }
        
        [dates addObject:endDate];
        return dates;
    }
}
// END sending steps related functions




-(void)stopQuery: (id)args{
    
}

// START database interactions functions

-(void) getQuantityResult:(id)args{
    NSDictionary* queryObj = [args objectAtIndex:0];
    NSInteger limit = [queryObj objectForKey:@"limit"];
    NSDictionary* predicateDict = [queryObj objectForKey:@"predicate"];
    NSPredicate* predicate = nil;
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:[queryObj objectForKey:@"quantityType"]];
    
    if ([predicateDict objectForKey:@"datePredicate"] != nil)
        predicate = [self datePredicate:[predicateDict objectForKey:@"datePredicate"]];
    
    NSString *endKey =  HKSampleSortIdentifierEndDate;
    NSSortDescriptor *endDate = [NSSortDescriptor sortDescriptorWithKey: endKey ascending: NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: quantityType
                                                           predicate: predicate
                                                               limit: limit
                                                     sortDescriptors: @[endDate]
                                                      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
        
        bool success = (error == nil) ? true : false;
        NSDictionary *res;
        
        if ([results lastObject] != nil && success){
            HKQuantitySample* sample = [results lastObject];
            HKSource* source = sample.source;
            
            res = @{
                @"quantities" : [self resultAsNumberArray:results],
                @"quantityType" : sample.quantityType,
                @"sources" : [self resultAsSourceArray:results],
                @"success" :[NSNumber numberWithBool: success]
                
            };
        } else{
            res = @{
                @"success" :[NSNumber numberWithBool: success]
            };
        }
        [self executeTitaniumCallback:args withResult:res];
        
    }];
    [self.healthStore executeQuery:query];
}



-(void)saveWorkout:(id)args{
    
    if ([self.healthStore authorizationStatusForType: [HKWorkoutType workoutType]] != HKAuthorizationStatusSharingAuthorized){
        [self executeTitaniumCallback:args withResult:@{@"success": @"0"}];
        return;
    }
    
    NSDictionary* props = [args objectAtIndex:0];
    NSString* strCals = [props objectForKey:@"calories"];
    NSString* strDist = [props objectForKey:@"distance"];
    double cals = [strCals doubleValue];
    double dist = [strDist doubleValue];
    
    HKQuantity* burned = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:cals];
    HKQuantity* distance = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue: dist];
    HKWorkout* workout = [HKWorkout workoutWithActivityType:[props objectForKey:@"HKWorkoheutActivityType"]
                                                  startDate:[self NSDateFromCustomJavaScriptDateString:[props objectForKey:@"startDate"]]
                                                    endDate:[self NSDateFromCustomJavaScriptDateString:[props objectForKey:@"endDate"]]
                                                   duration:[[NSDate date] timeIntervalSinceNow]
                                          totalEnergyBurned:burned
                                              totalDistance:distance metadata:nil];
    
    [self.healthStore saveObject:workout withCompletion:^(BOOL success, NSError *error) {
        
        NSArray* intervals =                    [[NSArray alloc] initWithObjects:[NSDate dateWithTimeIntervalSinceNow: -1200], [NSDate date], nil];
        NSMutableArray *samples =               [NSMutableArray array];
        HKQuantityType *energyBurnedType =      [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierActiveEnergyBurned];
        //     HKQuantity *energyBurnedPerInterval =   [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:15.5];
        
        HKQuantitySample *energyBurnedPerIntervalSample = [HKQuantitySample quantitySampleWithType: energyBurnedType
                                                                                          quantity: [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:cals]
                                                                                         startDate: intervals[0]
                                                                                           endDate: intervals[1]];
        [samples addObject:energyBurnedPerIntervalSample];
        
        [self.healthStore
         addSamples:samples
         toWorkout:workout
         completion:^(BOOL success, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:success]}];
            });
        }];
    }];
}



-(void)getWorkout:(id)args{
    
    HKWorkoutType *workouts = [HKWorkoutType workoutType ];
    NSString *endKey =  HKSampleSortIdentifierEndDate;
    NSSortDescriptor *endDate = [NSSortDescriptor sortDescriptorWithKey: endKey ascending: NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: workouts
                                                           predicate:nil
                                                               limit:1
                                                     sortDescriptors: @[endDate]
                                                      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            HKWorkout *sample = [results lastObject];
            
            // NSLog(@"workout --- results%@", results);
            //                                                              NSLog(@"workout --- error%@", error.localizedDescription);
            
            // krashar appen ibland om nil
            //                                                              HKQuantity *d = sample.workoutActivityType;
            //                                                              int d1 = [d doubleValueForUnit:HKUnit.countUnit];
            //                                                              d1 = sample.workoutActivityType;
            [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:1], @"results": results}];
        });
    }];
    [self.healthStore executeQuery:query];
}



- (void)readDistanceWalkingRunning:(id)args{
    {
        // start date
        
        // end date
        NSArray *readTypes = @[
            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning]
        ];
        
        [self.healthStore requestAuthorizationToShareTypes:nil
                                                 readTypes:[NSSet setWithArray:readTypes]
                                                completion:^(BOOL success, NSError * _Nullable error) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                if (error) {
                    [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:false], @"error": error.localizedDescription}];
                    
                } else {
                    NSDate * modFromDate = [self getDateFromString:[args objectAtIndex:0] ];
                    NSDate * modToDate = [self getDateFromString:[args objectAtIndex:1]];
                    // Sample type
                    HKSampleType *sampleCyclingDistance = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
                    
                    // Predicate
                    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:modFromDate
                                                                               endDate:modToDate
                                                                               options:HKQueryOptionStrictStartDate];
                    
                    // valud
                    __block float dailyValue = 0;
                    
                    // query
                    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: sampleCyclingDistance
                                                                           predicate: predicate
                                                                               limit: 0
                                                                     sortDescriptors: nil
                                                                      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            if (error) {
                                
                                
                                
                            } else {
                                @try {
                                    NSMutableArray *arrValues = [NSMutableArray array]; //alloc
                                } @catch (NSException *exception) {
                                    NSLog(@"exception %@", exception)
                                } @finally {
                                    
                                }
                                NSMutableArray *arrValues = [NSMutableArray array]; //alloc
                                
                                
                                for (HKQuantitySample *sample in results) {
                                    //NSComparisonResult compareResult = [sample.startDate compare:fromDate];
                                    if ([sample.source.bundleIdentifier isEqualToString:@"com.apple.Health"]) continue;
                                    NSString * startDate = [self getStringFromDate:sample.startDate];
                                    NSString * endDate = [self getStringFromDate:sample.endDate];
                                    NSNumber *steps = [NSNumber numberWithFloat:[[sample quantity] doubleValueForUnit:[HKUnit meterUnit]]] ;
                                    NSString * bundleIdentifier = sample.source.bundleIdentifier;
                                    NSDictionary * dict = @{
                                        @"startDate" : startDate,
                                        @"endDate" : endDate,
                                        @"bundleIdentifier" : bundleIdentifier,
                                        @"count" : steps,
                                        @"deviceName":sample.source.name                                                               };
                                    
                                    [arrValues addObject:dict];
                                    
                                    dailyValue += [[sample quantity] doubleValueForUnit:[HKUnit meterUnit]];
                                }
                                
                                
                                
                                
                                
                                [self executeTitaniumCallback:args withResult:@{@"success" :[NSNumber numberWithBool:1], @"totalDistance": [NSNumber numberWithFloat:dailyValue], @"arrValues":arrValues}];
                                
                                //                                                                  finishBlock(nil, @(dailyValue));
                            }
                        });
                    }
                                            ];
                    
                    // execute query
                    [self.healthStore executeQuery:query];
                }
            });
        }];
        
    }
}


// END database interactions functions





// START general helper functions


-(NSDate*) NSDateFromCustomJavaScriptDateString:(NSString*) dateStr{
    NSTimeZone *currentDateTimeZone = [NSTimeZone defaultTimeZone];
    NSDateFormatter *currentDateFormat = [[NSDateFormatter alloc]init];
    //[currentDateFormat setTimeZone:currentDateTimeZone];
    [currentDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [currentDateFormat dateFromString:dateStr];
}


-(NSPredicate*) datePredicate:(NSArray*) array{
    NSDate *startDate = [self NSDateFromCustomJavaScriptDateString:[array objectAtIndex:0]];
    NSDate *endDate = [self NSDateFromCustomJavaScriptDateString:[array objectAtIndex:1]];
    
    return [NSPredicate predicateWithFormat:@"startDate >= %@ AND endDate <= %@", startDate, endDate];
}


-(NSMutableArray*)resultAsNumberArray:(NSArray*)result{
    NSMutableArray* numberArray = [[NSMutableArray alloc] init];
    
    for (HKQuantitySample* sample in result){
        [numberArray addObject:[NSNumber numberWithInt:[sample.quantity doubleValueForUnit:[HKUnit countUnit]]]];
    }
    return numberArray;
}


-(NSMutableArray*)resultAsSourceArray:(NSArray*)result{
    NSMutableArray* sourceArray = [[NSMutableArray alloc] init];
    
    for (HKQuantitySample* sample in result){
        [sourceArray addObject: sample.source.bundleIdentifier];
    }
    return sourceArray;
}

-(void) executeTitaniumCallback:(id)args withResult: (NSDictionary*) res{
    
    KrollCallback* callback = [[KrollCallback alloc] init];
    int i = 0;
    while (i < [args count] ){
        if([[args objectAtIndex:i] isKindOfClass:[KrollCallback class]]){
            callback = [args objectAtIndex:i];
            break;
        }
        i++;
    }
    if (callback){
        NSArray* array = [NSArray arrayWithObjects: res, nil];
        [callback call:array thisObject:nil];
    }
}



// END general helper functions



// START check permissions for write types

-(NSMutableSet*) authorizedWriteCategoryTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKQuantityType categoryTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    return set;
}


-(NSMutableSet*) authorizedWriteCharacteristicTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKCharacteristicType characteristicTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    return set;
}


-(NSMutableSet*) authorizedWriteCorrelationTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKQuantityType correlationTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    return set;
}


-(NSMutableSet*) authorizedWriteQuantityTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKQuantityType quantityTypeForIdentifier: type]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    return set;
}


-(NSMutableSet*) authorizedWriteWorkoutTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    for (NSString* type in types){
        if ([self.healthStore authorizationStatusForType: [HKWorkoutType workoutType]] == HKAuthorizationStatusSharingAuthorized){
            [set addObject:type];
        }
    }
    return set;
}


-(NSMutableSet*) authorizedWriteTypes:(NSDictionary*) types{
    NSMutableSet* set = [[NSMutableSet alloc] init];
    
    [set unionSet: [self authorizedWriteCategoryTypes:[types objectForKey:@"HKCategoryType"]]];
    [set unionSet: [self authorizedWriteCharacteristicTypes:[types objectForKey:@"HKCharacteristicType"]]];
    [set unionSet: [self authorizedWriteCorrelationTypes:[types objectForKey:@"HKCorrelationType"]]];
    [set unionSet: [self authorizedWriteQuantityTypes:[types objectForKey:@"HKQuantityType"]]];
    [set unionSet: [self authorizedWriteWorkoutTypes:[types objectForKey:@"HKWorkoutType"]]];
    
    return set;
}

// END check permissions for write types


// START check permissions for read types

-(void) authorizedReadCategoryTypes:(NSArray*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if ([types count] == 0) completion(set);
    for (NSString* type in types){
        [self readDataAvailableForType:@"HKCategoryType" WithIdentifier:type completion:^(bool successful) {
            if (successful) [set addObject:type];
            if ([type isEqualToString: [types lastObject]]) completion(set);
        }];
    }
}



-(void) authorizedReadCharacteristicTypes:(NSArray*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if ([types count] == 0) completion(set);
    for (NSString* type in types){
        [self readDataAvailableForType:@"HKCharacteristicType" WithIdentifier:type completion:^(bool successful) {
            if (successful) [set addObject:type];
            if ([type isEqualToString: [types lastObject]]) completion(set);
        }];
    }
}


-(void) authorizedReadCorrelationTypes:(NSArray*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if ([types count] == 0) completion(set);
    for (NSString* type in types){
        [self readDataAvailableForType:@"HKCorrelationType" WithIdentifier:type completion:^(bool successful) {
            if (successful) [set addObject:type];
            if ([type isEqualToString: [types lastObject]]) completion(set);
        }];
    }
}



-(void) authorizedReadQuantityTypes:(NSArray*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if ([types count] == 0) completion(set);
    for (NSString* type in types){
        [self readDataAvailableForType:@"HKQuantityType" WithIdentifier:type completion:^(bool successful) {
            if (successful) [set addObject:type];
            if ([type isEqualToString: [types lastObject]]) completion(set);
        }];
    }
    
}


-(void) authorizedReadWorkoutTypes:(NSArray*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if ([types count] == 0) completion(set);
    for (NSString* type in types){
        [self readDataAvailableForType:@"HKWorkoutType" WithIdentifier:type completion:^(bool successful) {
            if (successful) [set addObject:type];
            if ([type isEqualToString: [types lastObject]]) completion(set);
        }];
    }
}


-(void) readDataAvailableForType: (NSString*)type WithIdentifier: (NSString*)identifier completion: (void (^)(bool))completion{
    
    NSMutableArray* sampleType = [[NSMutableArray alloc] init];
    
    if ([type isEqualToString:@"HKCharacteristicType"]){
        completion([HKCharacteristicType characteristicTypeForIdentifier:identifier] != 0);
        return;
    }
    
    if ([type isEqualToString:@"HKCategoryType"]) [sampleType addObject: [HKCategoryType categoryTypeForIdentifier: identifier]];
    else if ([type isEqualToString:@"HKCorrelationType"]) [sampleType addObject: [HKCorrelationType correlationTypeForIdentifier: identifier]];
    else if ([type isEqualToString:@"HKQuantityType"]) [sampleType addObject: [HKQuantityType quantityTypeForIdentifier: identifier]];
    else if ([type isEqualToString:@"HKWorkoutType"]) [sampleType addObject: [HKWorkoutType workoutType]];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: [sampleType firstObject]
                                                           predicate: nil
                                                               limit: 1
                                                     sortDescriptors: nil
                                                      resultsHandler:^(HKSampleQuery *query, NSArray* results, NSError *error){
        
        if (completion) completion([results lastObject] != nil);
        
    }];
    [self.healthStore executeQuery:query];
}


-(void) authorizedReadTypes:(NSDictionary*) types completion: (void (^)(NSMutableSet*))completion{
    NSMutableSet* set = [[NSMutableSet alloc] init];
    __block int returnedSets = 0;
    
    [self authorizedReadCategoryTypes:[types objectForKey:@"HKCategoryType"] completion:^(NSMutableSet * resultSet) {
        [set unionSet: resultSet];
        if (++returnedSets == 5) completion(set);
    }];
    
    [self authorizedReadCharacteristicTypes:[types objectForKey:@"HKCharacteristicType"] completion:^(NSMutableSet * resultSet) {
        [set unionSet: resultSet];
        if (++returnedSets == 5) completion(set);
    }];
    
    [self authorizedReadCorrelationTypes:[types objectForKey:@"HKCorrelationType"] completion:^(NSMutableSet * resultSet) {
        [set unionSet: resultSet];
        if (++returnedSets == 5) completion(set);
    }];
    
    [self authorizedReadQuantityTypes:[types objectForKey:@"HKQuantityType"] completion:^(NSMutableSet * resultSet) {
        [set unionSet: resultSet];
        if (++returnedSets == 5) completion(set);
    }];
    
    [self authorizedReadWorkoutTypes:[types objectForKey:@"HKWorkoutType"] completion:^(NSMutableSet * resultSet) {
        [set unionSet: resultSet];
        if (++returnedSets == 5) completion(set);
    }];
}

// END check permissions for read types





// START extract types from JS-object

-(NSMutableSet*) categoryTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    for (int i = 0; i < types.count; i++) [set addObject:[HKObjectType categoryTypeForIdentifier:types[i]]];
    return set;
}

-(NSMutableSet*) charateristicsTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    for (int i = 0; i < types.count; i++) [set addObject:[HKObjectType characteristicTypeForIdentifier:types[i]]];
    return set;
}

-(NSMutableSet*) correlationTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    for (int i = 0; i < types.count; i++) [set addObject:[HKObjectType correlationTypeForIdentifier:types[i]]];
    return set;
}

-(NSMutableSet*) quantityTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    for (int i = 0; i < types.count; i++) [set addObject:[HKObjectType quantityTypeForIdentifier:types[i]]];
    return set;
}

-(NSMutableSet*) workoutTypes:(NSArray*) types{
    NSMutableSet* set = [[NSMutableSet alloc]init];
    if (types.count > 0)
        [set addObject:[HKObjectType workoutType]];
    return set;
}

-(NSMutableSet*) getTypes:(NSDictionary*) types{
    NSMutableSet* set = [[NSMutableSet alloc] init];
    
    [set unionSet: [self categoryTypes:[types objectForKey:@"HKCategoryType"]]];
    [set unionSet: [self charateristicsTypes:[types objectForKey:@"HKCharacteristicType"]]];
    [set unionSet: [self correlationTypes:[types objectForKey:@"HKCorrelationType"]]];
    [set unionSet: [self quantityTypes:[types objectForKey:@"HKQuantityType"]]];
    [set unionSet: [self workoutTypes:[types objectForKey:@"HKWorkoutType"]]];
    
    return set;
}


@end
