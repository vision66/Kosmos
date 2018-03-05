//
//  KosmosCoreLocation.swift
//  electrombile
//
//  Created by weizhen on 2017/11/22.
//  Copyright © 2017年 whmx. All rights reserved.
//

import CoreLocation

func ==(left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> Bool { return left.latitude == right.latitude && left.longitude == right.longitude }
func !=(left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> Bool { return left.latitude != right.latitude || left.longitude != right.longitude }

fileprivate let PI =   3.14159265358979324
fileprivate let X_PI = 3.14159265358979324 * 3000.0 / 180.0

extension CLLocationCoordinate2D {
    
    private func transformLat(_ x: CLLocationDegrees, _ y: CLLocationDegrees) -> CLLocationDegrees {
        var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))
        ret += (20.0 * sin(6.0 * x * PI) + 20.0 * sin(2.0 * x * PI)) * 2.0 / 3.0
        ret += (20.0 * sin(y * PI) + 40.0 * sin(y / 3.0 * PI)) * 2.0 / 3.0
        ret += (160.0 * sin(y / 12.0 * PI) + 320 * sin(y * PI / 30.0)) * 2.0 / 3.0
        return ret
    }
    
    private func transformLon(_ x: CLLocationDegrees, _ y: CLLocationDegrees) -> CLLocationDegrees {
        var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))
        ret += (20.0 * sin(6.0 * x * PI) + 20.0 * sin(2.0 * x * PI)) * 2.0 / 3.0
        ret += (20.0 * sin(x * PI) + 40.0 * sin(x / 3.0 * PI)) * 2.0 / 3.0
        ret += (150.0 * sin(x / 12.0 * PI) + 300.0 * sin(x / 30.0 * PI)) * 2.0 / 3.0
        return ret
    }
    
    private var delta : CLLocationCoordinate2D {
        let lat = self.latitude
        let lon = self.longitude
        let a = 6378245.0 //  a: 卫星椭球坐标投影到平面地图坐标系的投影因子。
        let ee = 0.00669342162296594323 //  ee: 椭球的偏心率。
        var dLat = transformLat(lon - 105.0, lat - 35.0)
        var dLon = transformLon(lon - 105.0, lat - 35.0)
        let radLat = lat / 180.0 * PI
        var magic = sin(radLat)
        magic = 1 - ee * magic * magic
        let sqrtMagic = sqrt(magic)
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * PI)
        dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * PI)
        return CLLocationCoordinate2DMake(dLat, dLon)
    }
    
    private var outOfChina : Bool {
        let lat = self.latitude
        let lon = self.longitude
        if (lon < 72.004 || lon > 137.8347) { return true }
        if (lat < 0.8293 || lat > 55.8271) { return true }
        return false
    }
    
    //WGS-84 to GCJ-02
    var WGS84toGCJ02 : CLLocationCoordinate2D {
        let wgsLat = self.latitude
        let wgsLon = self.longitude
        if self.outOfChina {
            return CLLocationCoordinate2DMake(wgsLat, wgsLon)
        }
        let d = self.delta
        return CLLocationCoordinate2DMake(wgsLat + d.latitude, wgsLon + d.longitude)
    }
    
    //GCJ-02 to WGS-84
    var GCJ02toWGS84 : CLLocationCoordinate2D {
        let gcjLat = self.latitude
        let gcjLon = self.longitude
        if self.outOfChina {
            return CLLocationCoordinate2DMake(gcjLat, gcjLon)
        }
        let d = self.delta
        return CLLocationCoordinate2DMake(gcjLat - d.latitude, gcjLon - d.longitude)
    }
    
    //GCJ-02 to WGS-84 exactly
    var GCJ02toWGS84_exact : CLLocationCoordinate2D {
        let gcjLat = self.latitude
        let gcjLon = self.longitude
        let initDelta = 0.01
        let threshold = 0.000000001
        var dLat = initDelta
        var dLon = initDelta
        var mLat = gcjLat - dLat
        var mLon = gcjLon - dLon
        var pLat = gcjLat + dLat
        var pLon = gcjLon + dLon
        var wgsLat = 0.0
        var wgsLon = 0.0
        for _ in 0 ... 10000 {
            wgsLat = (mLat + pLat) / 2
            wgsLon = (mLon + pLon) / 2
            let tmp = CLLocationCoordinate2DMake(wgsLat, wgsLon).WGS84toGCJ02
            dLat = tmp.latitude - gcjLat
            dLon = tmp.longitude - gcjLon
            if ((fabs(dLat) < threshold) && (fabs(dLon) < threshold)) { break }
            if (dLat > 0) {pLat = wgsLat} else {mLat = wgsLat}
            if (dLon > 0) {pLon = wgsLon} else {mLon = wgsLon}
        }
        return CLLocationCoordinate2DMake(wgsLat, wgsLon)
    }
    
    //GCJ-02 to BD-09
    var GCJ02toBD09 : CLLocationCoordinate2D {
        let gcjLat = self.latitude
        let gcjLon = self.longitude
        let x = gcjLon
        let y = gcjLat
        let z = sqrt(x * x + y * y) + 0.00002 * sin(y * X_PI)
        let theta = atan2(y, x) + 0.000003 * cos(x * X_PI)
        let bdLon = z * cos(theta) + 0.0065
        let bdLat = z * sin(theta) + 0.006
        return CLLocationCoordinate2DMake(bdLat, bdLon)
    }
    
    //BD-09 to GCJ-02
    var BD09toGCJ02 : CLLocationCoordinate2D {
        let bdLat = self.latitude
        let bdLon = self.longitude
        let x = bdLon - 0.0065
        let y = bdLat - 0.006
        let z = sqrt(x * x + y * y) - 0.00002 * sin(y * X_PI)
        let theta = atan2(y, x) - 0.000003 * cos(x * X_PI)
        let gcjLon = z * cos(theta)
        let gcjLat = z * sin(theta)
        return CLLocationCoordinate2DMake(gcjLat, gcjLon)
    }
    
    //WGS-84 to BD-09
    var WGS84toBD09 : CLLocationCoordinate2D {
        return self.WGS84toGCJ02.BD09toGCJ02
    }
    
    //BD-09 to WGS-84
    var BD09toWGS84 : CLLocationCoordinate2D {
        return self.BD09toGCJ02.GCJ02toWGS84
    }
    
    //WGS-84 to Web mercator
    //mercatorLat -> y mercatorLon -> x
    var WGS84toMercator : CLLocationCoordinate2D {
        let wgsLat = self.latitude
        let wgsLon = self.longitude
        let x = wgsLon * 20037508.34 / 180.0
        var y = log(tan((90.0 + wgsLat) * PI / 360.0)) / (PI / 180.0)
        y = y * 20037508.34 / 180.0
        return CLLocationCoordinate2DMake(y, x)
    }
    
    // Web mercator to WGS-84
    // mercatorLat -> y mercatorLon -> x
    var MercatortoWGS84 : CLLocationCoordinate2D {
        let mercatorLat = self.latitude
        let mercatorLon = self.longitude
        let x = mercatorLon / 20037508.34 * 180.0
        var y = mercatorLat / 20037508.34 * 180.0
        y = 180 / PI * (2 * atan(exp(y * PI / 180.0)) - PI / 2)
        return CLLocationCoordinate2DMake(y, x)
    }
    
    // two point's distance
    func distance(to another: CLLocationCoordinate2D) -> Double {
        let latA = self.latitude
        let lonA = self.longitude
        let latB = another.latitude
        let lonB = another.longitude
        let earthR = 6371000.0
        let x = cos(latA * PI / 180.0) * cos(latB * PI / 180.0) * cos((lonA - lonB) * PI / 180)
        let y = sin(latA * PI / 180.0) * sin(latB * PI / 180.0)
        var s = x + y
        if (s > 1) {s = 1}
        if (s < -1) {s = -1}
        let alpha = acos(s)
        let distance = alpha * earthR
        return distance
    }
}
