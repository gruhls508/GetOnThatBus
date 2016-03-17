//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Glen Ruhl on 8/5/14. 
//  Copyright (c) 2014 Masangcay. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import <MapKit/MapKit.h>


@interface ViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
@property NSArray *busStops;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet MKMapView *busMapView;
@property MKPointAnnotation *busStopAnnotation;

@property NSString *titleString;

@property float longitudeSum;
@property float latitudeSum;
@property float longitudeMean;
@property float latitudeMean;

@end

@implementation ViewController

- (void)viewDidLoad
{

    [super viewDidLoad];
    //  Obtain permission from user to obtain location. iOS 8 and above
    [self requestPermissionForLocationUpdates];

    //  Our school created a JSON Array that stored the info for all of the Chicago bus stops we would plot on the MapView within our app.

    NSURL *url = [NSURL URLWithString:@"https://s3.amazonaws.com/mobile-makers-lib/bus.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:
    [NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

    self.busStops = [[NSJSONSerialization JSONObjectWithData:data
                                                        options:0
                                                            error:nil] objectForKey:@"row"];
        for (NSDictionary *busDic in self.busStops) {

            CLLocationCoordinate2D  coordinate;
            coordinate.latitude = [[busDic objectForKey:@"latitude"]floatValue];



            //  Our instructors intentionally gave us one coordinate set in which the longitude's absolute value was correct, but it was made POSITIVE, rather than the negative value corresponding to the acutal Chicago bus stop. The following "if" statement is set up to handle that contingency.

            if ([[busDic objectForKey:@"longitude"]floatValue] > 0) {
                 coordinate.longitude = [[busDic objectForKey:@"longitude"]floatValue] * -1;
            }
            else{

            coordinate.longitude = [[busDic objectForKey:@"longitude"]floatValue];

            }

            self.longitudeSum += coordinate.longitude;
            self.latitudeSum += coordinate.latitude;
            self.longitudeMean = self.longitudeSum / self.busStops.count;
            self.latitudeMean = self.latitudeSum / self.busStops.count;




            //  The following code sets up the Map Annotations, and gets their titles/subtitles from the corresponding data within the online array that denotes the bus stop's name and routes serviced.

            self.busStopAnnotation = [[MKPointAnnotation alloc]init];
            self.busStopAnnotation.coordinate = coordinate;
            self.busStopAnnotation.title = [busDic objectForKey:@"cta_stop_name"];
            self.busStopAnnotation.subtitle = [busDic objectForKey:@"routes"];
            [self.busMapView addAnnotation:self.busStopAnnotation];




            //  Here we experimented with different numerical values in order to find the "sweet spot" that would display all of the bus stops we plotted without being too zoomed out. Our final solution can be found within the parentheses in the MKCoordinateRegionMakeWithDistance call.

            CLLocationCoordinate2D zoomLocation;
            zoomLocation.latitude = self.latitudeMean;
            zoomLocation.longitude = self.longitudeMean;
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 30000, 25000);
            MKCoordinateRegion adjustedRegion = [self.busMapView regionThatFits:viewRegion];
            [self.busMapView setRegion:adjustedRegion animated:YES];
        }

    }];


}


//  iOS 8 and above requires requesting permission when updating user's location.
//  if user is on iOS 7 and below then this won't execute.
- (void)requestPermissionForLocationUpdates {
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    //Check if using iOS 8 or above to request permission to update location.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [self.locationManager requestWhenInUseAuthorization ];
    [self.locationManager startUpdatingLocation];
}



        //  In this code we created our Map Annotations (pins.) We set them up so that they could show "callouts" that would display the pin's title & subtitle (bus stop name and routes.)

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return pin;


}



    //  We made it so that the DetailView would open if the user tapped on the pin callout.

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{

    self.titleString = view.annotation.title;

   [self performSegueWithIdentifier: @"DetailPush" sender: self];

}



    //  This next code programs the MapView's behavior for when the user taps on one of the pins.


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

    CLLocationCoordinate2D centerCoordinate = view.annotation.coordinate;
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = 0.02;
    coordinateSpan.longitudeDelta = 0.02;
    MKCoordinateRegion region;
    region.center = centerCoordinate;
    region.span = coordinateSpan;

    [self.busMapView setRegion:region animated:YES];


}




    //  Here we set up for the segue to DetailView. It passes the info about the selected stop over in the form of a dictionary.

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    DetailViewController *dvc = segue.destinationViewController;

    for (NSDictionary *dic in self.busStops) {
        if ([dic objectForKey:@"cta_stop_name"] == self.titleString) {
            dvc.busStopInfo = dic;
        }
    }

}

    //  The unwind segue for returning to the Root ViewController from the Detail View.


-(IBAction)unwindBack:(UIStoryboardSegue *)sender
{

    NSLog(@"We BACK.");

}


@end
