# GetOnThatBus
An app showing bus stops in Chicago using MapView, MKPointAnnotations, and JSON API call


**NOTE:**
- Currently bus stops do not appear to be displaying on the map when it is presented. It is possible that the AWS page serving as the data
source for the bus stops the app intends to present is no longer a valid source--I will be looking into this and coming up with a 
new source for the data if that is the case.

*Update (3/17)*
- The data source is indeed gone. Researching alternatives.
- Found one possible alternative, the [CTA BusTracker API](http://www.transitchicago.com/developers/bustracker.aspx). Waiting on an API key.
- Docs for the API are [here](http://www.transitchicago.com/assets/1/developer_center/BusTime_Developer_API_Guide.pdf)
