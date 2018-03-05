//
//  coordinate+convert.h
//  campus
//
//  Created by weizhen on 16/7/22.
//  Copyright © 2016年 whmx. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

//WGS-84 to GCJ-02
CLLocationCoordinate2D WGS84toGCJ02(double wgsLat, double wgsLon);

//GCJ-02 to WGS-84
CLLocationCoordinate2D GCJ02toWGS84(double gcjLat, double gcjLon);

//GCJ-02 to WGS-84 exactly
CLLocationCoordinate2D GCJ02toWGS84_exact(double gcjLat, double gcjLon);

//GCJ-02 to BD-09
CLLocationCoordinate2D GCJ02toBD09(double gcjLat, double gcjLon);

//BD-09 to GCJ-02
CLLocationCoordinate2D BD09toGCJ02(double bdLat, double bdLon);

//WGS-84 to BD-09
CLLocationCoordinate2D WGS84toBD09(double wgsLat, double wgsLon);

//BD-09 to WGS-84
CLLocationCoordinate2D BD09toWGS84(double bdLat, double bdLon);

//WGS-84 to Web mercator
//mercatorLat -> y mercatorLon -> x
CLLocationCoordinate2D WGS84toMercator(double wgsLat, double wgsLon);

// Web mercator to WGS-84
// mercatorLat -> y mercatorLon -> x
CLLocationCoordinate2D MercatortoWGS84(double mercatorLat, double mercatorLon);

// two point's distance
double distance(double latA, double lonA, double latB, double lonB);

