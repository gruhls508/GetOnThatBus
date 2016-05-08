//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Glen Ruhl on 8/5/14. 
//  Copyright (c) 2014 Masangcay. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "XmlHandler.h"

#import <MapKit/MapKit.h>
#import "Constants.h"
@import GoogleMaps;


@interface ViewController ()<MKMapViewDelegate, CLLocationManagerDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property MKPointAnnotation *busStopAnnotation;

@property NSString *titleString;
@property float longitudeMean;
@property float latitudeMean;

@end

@implementation ViewController {

    XmlHandler *xmlHandler;
    NSDictionary *busStops;
    NSString *stopName;
    NSDictionary *stopCoordinates;

    BOOL elementIsStopName;
    BOOL elementIsLat;
    BOOL elementIsLong;

    float latitudeSum;
    float longitudeSum;
    GMSMapView *mapView_;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //  Obtain permission from user to obtain location. iOS 8 and above
    [self requestPermissionForLocationUpdates];
    stopName = @"";
    busStops = @{};

    NSURL *ctaUrl = [NSURL URLWithString:
                            @"http://www.ctabustracker.com/bustime/api/v1/getstops?"
                                    "key=PhJHkRTCjfjFTcT8FuSufpBri&rt=20&dir=Westbound"];

    NSURLRequest *request = [NSURLRequest requestWithURL:ctaUrl];
    xmlHandler = [XmlHandler new];

    [NSURLConnection sendAsynchronousRequest:request queue:
    [NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        [xmlHandler parseXmlData:data];
        [xmlHandler.parser setDelegate:self];
        BOOL didParse = [xmlHandler.parser parse];



        if (didParse) {
            NSLog(@"parsed");

            //  call -drawPolyline function using stops data in 'busStops'
            [self drawRouteWithStops:busStops];

        }



        else if (!didParse) {
            NSLog(@"did not parse");
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



- (void)parseXmlData:(NSData *)data {

    BOOL success;
    NSXMLParser *parser = [[NSXMLParser alloc]initWithData:data];
    parser.delegate = self;
    [parser parse];
}




- (void)drawRouteWithStops:(NSDictionary *)stops {


    for (NSDictionary *stop in stops.allValues) {

        
    }

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

//    [self.busMapView setRegion:region animated:YES];


}




    //  Here we set up for the segue to DetailView. It passes the info about the selected stop over in the form of a dictionary.

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    DetailViewController *dvc = segue.destinationViewController;


    //  This must change to get appropriate stop for detail view from
    //  new 'busStops' NSDictionary object.


//    for (NSDictionary *dic in self.busStops) {
//        if ([dic objectForKey:@"cta_stop_name"] == self.titleString) {
//            dvc.busStopInfo = dic;
//        }
//    }

}

    //  The unwind segue for returning to the Root ViewController from the Detail View.


-(IBAction)unwindBack:(UIStoryboardSegue *)sender
{
    NSLog(@"We BACK.");
}



#pragma mark NSXMLParserDelegate

//  Guide to handling XML elements/attributes--specifically recognizing an elementName in -didStartElement:
//  and using that to determine identity of string in -parser:foundCharacters:, and thus be able to pass that value
//  along from the callback correctly https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/XMLParsing/Articles/HandlingElements.html#//apple_ref/doc/uid/20002265-BCIJFGJI

//  Put this implementation, and the method -parseXmlData: into model object(s)


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {

    NSLog(@"-didStartElement, elementName == %@", elementName);

    if ([elementName isEqualToString:kstopElementName]) {
        elementIsStopName = YES;
    }
    else if ([elementName isEqualToString:klatKey]) {
        elementIsLat = YES;
    }
    else if ([elementName isEqualToString:klongKey]) {
        elementIsLong = YES;
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    NSLog(@"found characters, %@", string);

    if (elementIsStopName) {
        stopName = [stopName isEqualToString:@""] ? string : [XmlHandler appendNameComponent:string toName:stopName];
    }
    else if (elementIsLat || elementIsLong) {

        NSString *key;

        if (elementIsLat) {
            stopCoordinates = @{};
            key = klatKey;
        }
        else if (elementIsLong) {

            key = klongKey;
        }
        stopCoordinates = [XmlHandler dictionary:stopCoordinates addObject:string forKey:key];
        NSLog(@"stopCoordinates == %@", stopCoordinates);
    }
    NSLog(@"stopName == %@", stopName);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
                                                                                    qualifiedName:(NSString *)qName {
    if (elementIsStopName)
        elementIsStopName = !elementIsStopName;
    else if (elementIsLat)
        elementIsLat = !elementIsLat;
    else if (elementIsLong) {

        elementIsLong = !elementIsLong;

        busStops = [XmlHandler dictionary:busStops addObject:stopCoordinates forKey:stopName];
        NSLog(@"busStops == %@", busStops);
        

        //  Call function to make map annotation and place on map using coords and name set up using XML that was just provided/consumed
        //  by the app.
        float latitude = [[stopCoordinates objectForKey:klatKey]floatValue];
        float longitude = [[stopCoordinates objectForKey:klongKey]floatValue];
        CLLocationCoordinate2D  coordinate = CLLocationCoordinate2DMake(latitude, longitude);

        MKPointAnnotation *stopPoint = [MKPointAnnotation new];
        stopPoint.coordinate = coordinate;
        stopPoint.title = stopName;
        //  TODO: Get route for here - orig. code self.busStopAnnotation.subtitle = [busDic objectForKey:@"routes"];

        latitudeSum += latitude;
        longitudeSum += longitude;

        NSUInteger numberOfStops = busStops.allKeys.count;
        _latitudeMean = latitudeSum / numberOfStops;
        _longitudeMean = longitudeSum / numberOfStops;

        CLLocationCoordinate2D zoomLocation;
        zoomLocation.latitude = self.latitudeMean;
        zoomLocation.longitude = self.longitudeMean;

        dispatch_async(dispatch_get_main_queue(), ^{

            //  ***Google Maps***
            //  Create instance of GMSCameraPosition using the self.latitudeMean, self.longitudeMean

            static dispatch_once_t once;
            dispatch_once(&once, ^{

                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.latitudeMean
                                                                        longitude:self.longitudeMean
                                                                             zoom:11.28];

                mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
                mapView_.myLocationEnabled = YES;
                self.view = mapView_;
            });
        });


        stopName = @"";

        //  **calculate latitude/longitude sums here
    }


    NSLog(@"-didEndElement elementName == %@", elementName);
}

@end
