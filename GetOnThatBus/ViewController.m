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


@interface ViewController ()<MKMapViewDelegate, CLLocationManagerDelegate, NSXMLParserDelegate>
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

@implementation ViewController {

    XmlHandler *xmlHandler;
    NSDictionary *busStops;
    NSString *stopName;
    NSDictionary *stopCoordinates;

    BOOL elementIsStopName;
    BOOL elementIsLat;
    BOOL elementIsLong;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //  Obtain permission from user to obtain location. iOS 8 and above
    [self requestPermissionForLocationUpdates];
    stopName = @"";


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
    else if (!elementIsStopName && [stopName isEqualToString:@""] == NO) {
        stopName = @"";
    }
    else if (elementIsLat) {
        stopCoordinates = nil;
        NSMutableDictionary *mutableCoordinates = stopCoordinates.mutableCopy;
        [mutableCoordinates setObject:string forKey:klatKey];
        stopCoordinates = [NSDictionary dictionaryWithDictionary:mutableCoordinates];
    }
    NSLog(@"stopName == %@", stopName);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (elementIsStopName)
        elementIsStopName = !elementIsStopName;
    else if (elementIsLat)
        elementIsLat = !elementIsLat;
    else if (elementIsLong) {

        elementIsLong = !elementIsLong;
        //  Call function to make map annotation and place on map using coords and name set up using XML that was just provided/consumed
        //  by the app.
    }


    NSLog(@"-didEndElement elementName == %@", elementName);
}

@end
