//
//  coordinate+convert.m
//  campus
//
//  Created by weizhen on 16/7/22.
//  Copyright © 2016年 whmx. All rights reserved.
//

#import "CoreLocation+Kosmos.h"

#define PI      3.14159265358979324
#define x_pi    3.14159265358979324 * 3000.0 / 180.0

double transformLat(double x, double y) {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * PI) + 20.0 * sin(2.0 * x * PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * PI) + 40.0 * sin(y / 3.0 * PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * PI) + 320 * sin(y * PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

double transformLon(double x, double y) {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * PI) + 20.0 * sin(2.0 * x * PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * PI) + 40.0 * sin(x / 3.0 * PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * PI) + 300.0 * sin(x / 30.0 * PI)) * 2.0 / 3.0;
    return ret;
}

CLLocationCoordinate2D delta(double lat, double lon) {
    double a = 6378245.0; //  a: 卫星椭球坐标投影到平面地图坐标系的投影因子。
    double ee = 0.00669342162296594323; //  ee: 椭球的偏心率。
    double dLat = transformLat(lon - 105.0, lat - 35.0);
    double dLon = transformLon(lon - 105.0, lat - 35.0);
    double radLat = lat / 180.0 * PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * PI);
    return CLLocationCoordinate2DMake(dLat, dLon);
}

bool outOfChina(double lat, double lon) {
    if (lon < 72.004 || lon > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

//WGS-84 to GCJ-02
CLLocationCoordinate2D WGS84toGCJ02(double wgsLat, double wgsLon) {
    if (outOfChina(wgsLat, wgsLon))
        return CLLocationCoordinate2DMake(wgsLat, wgsLon);
    CLLocationCoordinate2D d = delta(wgsLat, wgsLon);
    return CLLocationCoordinate2DMake(wgsLat + d.latitude, wgsLon + d.longitude);
}

//GCJ-02 to WGS-84
CLLocationCoordinate2D GCJ02toWGS84(double gcjLat, double gcjLon) {
    if (outOfChina(gcjLat, gcjLon))
        return CLLocationCoordinate2DMake(gcjLat, gcjLon);
    CLLocationCoordinate2D d = delta(gcjLat, gcjLon);
    return CLLocationCoordinate2DMake(gcjLat - d.latitude, gcjLon - d.longitude);
}

//GCJ-02 to WGS-84 exactly
CLLocationCoordinate2D GCJ02toWGS84_exact(double gcjLat, double gcjLon) {
    double initDelta = 0.01;
    double threshold = 0.000000001;
    double dLat = initDelta, dLon = initDelta;
    double mLat = gcjLat - dLat, mLon = gcjLon - dLon;
    double pLat = gcjLat + dLat, pLon = gcjLon + dLon;
    double wgsLat, wgsLon, i = 0;
    while (1) {
        wgsLat = (mLat + pLat) / 2;
        wgsLon = (mLon + pLon) / 2;
        CLLocationCoordinate2D tmp = WGS84toGCJ02(wgsLat, wgsLon);
        dLat = tmp.latitude - gcjLat;
        dLon = tmp.longitude - gcjLon;
        if ((fabs(dLat) < threshold) && (fabs(dLon) < threshold))
            break;
        if (dLat > 0) pLat = wgsLat; else mLat = wgsLat;
        if (dLon > 0) pLon = wgsLon; else mLon = wgsLon;        
        if (++i > 10000) break;
    }
    return CLLocationCoordinate2DMake(wgsLat, wgsLon);
}

//GCJ-02 to BD-09
CLLocationCoordinate2D GCJ02toBD09(double gcjLat, double gcjLon) {
    double x = gcjLon, y = gcjLat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    double bdLon = z * cos(theta) + 0.0065;
    double bdLat = z * sin(theta) + 0.006;
    return CLLocationCoordinate2DMake(bdLat, bdLon);
}

//BD-09 to GCJ-02
CLLocationCoordinate2D BD09toGCJ02(double bdLat, double bdLon) {
    double x = bdLon - 0.0065, y = bdLat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    double gcjLon = z * cos(theta);
    double gcjLat = z * sin(theta);
    return CLLocationCoordinate2DMake(gcjLat, gcjLon);
}

//WGS-84 to BD-09
CLLocationCoordinate2D WGS84toBD09(double wgsLat, double wgsLon) {
    CLLocationCoordinate2D coord;
    coord = WGS84toGCJ02(wgsLat, wgsLon);
    coord = GCJ02toBD09(coord.latitude, coord.longitude);
    return coord;
}

//BD-09 to WGS-84
CLLocationCoordinate2D BD09toWGS84(double bdLat, double bdLon) {
    CLLocationCoordinate2D coord;
    coord = BD09toGCJ02(bdLat, bdLon);
    coord = GCJ02toWGS84(coord.latitude, coord.longitude);
    return coord;
}

//WGS-84 to Web mercator
//mercatorLat -> y mercatorLon -> x
CLLocationCoordinate2D WGS84toMercator(double wgsLat, double wgsLon) {
    double x = wgsLon * 20037508.34 / 180.;
    double y = log(tan((90. + wgsLat) * PI / 360.)) / (PI / 180.);
    y = y * 20037508.34 / 180.;
    return CLLocationCoordinate2DMake(y, x);
}

// Web mercator to WGS-84
// mercatorLat -> y mercatorLon -> x
CLLocationCoordinate2D MercatortoWGS84(double mercatorLat, double mercatorLon) {
    double x = mercatorLon / 20037508.34 * 180.;
    double y = mercatorLat / 20037508.34 * 180.;
    y = 180 / PI * (2 * atan(exp(y * PI / 180.)) - PI / 2);
    return CLLocationCoordinate2DMake(y, x);
}

// two point's distance
double distance(double latA, double lonA, double latB, double lonB) {
    double earthR = 6371000.;
    double x = cos(latA * PI / 180.) * cos(latB * PI / 180.) * cos((lonA - lonB) * PI / 180);
    double y = sin(latA * PI / 180.) * sin(latB * PI / 180.);
    double s = x + y;
    if (s > 1) s = 1;
    if (s < -1) s = -1;
    double alpha = acos(s);
    double distance = alpha * earthR;
    return distance;
}
