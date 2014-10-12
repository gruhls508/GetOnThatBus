//
//  DetailViewController.m
//  GetOnThatBus
//
//  Created by Glen Ruhl on 8/5/14.
//  Copyright (c) 2014 Masangcay. All rights reserved.
//

#import "DetailViewController.h"
#import "ViewController.h"

#import <CoreLocation/CoreLocation.h>

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *busNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *busStopAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *busRouteLabel;

@property (weak, nonatomic) IBOutlet UILabel *transfersLabel;

@end



@implementation DetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"HERE: %@",self.busStopInfo);


    //  This is where we pull the appropriate data from the dictionary and use it to populate the labels that tell the user info about the stop they selected.

    self.busNameLabel.text = [self.busStopInfo objectForKey:@"cta_stop_name"];
    self.busRouteLabel.text = [self.busStopInfo objectForKey:@"routes"];
    if (![self.busStopInfo objectForKey:@"inter_modal"]) {

    } else {
        self.transfersLabel.text = [self.busStopInfo objectForKey:@"inter_modal"];
    }

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[self.busStopInfo objectForKey:@"latitude"] floatValue] longitude:[[self.busStopInfo objectForKey:@"longitude"] floatValue]];

    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            return;
        }
        for (CLPlacemark *place in placemarks)
        {
            self.busStopAddressLabel.text = place.thoroughfare;
            NSLog(@"%@",place.thoroughfare);

        }
        
    }];



  
}




@end
