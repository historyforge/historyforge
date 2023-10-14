/*
    Document   : wms.js
    Created on : Feb 16, 2011, 3:25:27 PM
    Author     : "Gavin Jackson <Gavin.Jackson@csiro.au>"

    Refactored code from http://lyceum.massgis.state.ma.us/wiki/doku.php?id=googlemapsv3:home

    The code below was actually refactored from the above code, via MapWarper.
*/

function bound(value, opt_min, opt_max) {
    if (opt_min != null) value = Math.max(value, opt_min);
    if (opt_max != null) value = Math.min(value, opt_max);
    return value;
}

function degreesToRadians(deg) {
    return deg * (Math.PI / 180);
}

function radiansToDegrees(rad) {
    return rad / (Math.PI / 180);
}

const MERCATOR_RANGE = 256;

class MercatorProjection {
    pixelOrigin_ = new google.maps.Point(MERCATOR_RANGE / 2, MERCATOR_RANGE / 2);
    pixelsPerLonDegree_ = MERCATOR_RANGE / 360;
    pixelsPerLonRadian_ = MERCATOR_RANGE / (2 * Math.PI);

    fromLatLngToPoint(latLng, opt_point) {
        const point = opt_point || new google.maps.Point(0, 0);

        const origin = this.pixelOrigin_;
        point.x = origin.x + latLng.lng() * this.pixelsPerLonDegree_;
        // NOTE(appleton): Truncating to 0.9999 effectively limits latitude to
        // 89.189.  This is about a third of a tile past the edge of the world tile.
        const sinY = bound(Math.sin(degreesToRadians(latLng.lat())), -0.9999, 0.9999);
        point.y = origin.y + 0.5 * Math.log((1 + sinY) / (1 - sinY)) * -this.pixelsPerLonRadian_;
        return point;
    }

    fromDivPixelToLatLng(pixel, zoom) {
        const origin = this.pixelOrigin_;
        const scale = Math.pow(2, zoom);
        const lng = (pixel.x / scale - origin.x) / this.pixelsPerLonDegree_;
        const latRadians = (pixel.y / scale - origin.y) / -this.pixelsPerLonRadian_;
        const lat = radiansToDegrees(2 * Math.atan(Math.exp(latRadians)) - Math.PI / 2);
        return new google.maps.LatLng(lat, lng);
    }

    fromDivPixelToSphericalMercator(pixel, zoom) {
        const coord = this.fromDivPixelToLatLng(pixel, zoom);

        const r = 6378137.0;
        const x = r * degreesToRadians(coord.lng());
        const latRad = degreesToRadians(coord.lat());
        const y = (r/2) * Math.log((1+Math.sin(latRad))/ (1-Math.sin(latRad)));

        return new google.maps.Point(x,y);
    }
}

class WMSLoader {
    map: IMap;
    baseURL: string;
    id: number;
    position: string;
    wmsParams: string;

    constructor(map, layer, position) {
        this.baseURL = layer.url.replace(/mosaics\/tile/, 'mosaics/wms').replace("/{z}/{x}/{y}.png", "").split('?')[0] + '?';
        this.id = layer.id;
        this.map = map;
        this.position = position;
        this.wmsParams = [
            "REQUEST=GetMap",
            "SERVICE=WMS",
            "VERSION=1.1.1",
            "BGCOLOR=0xFFFFFF",
            "TRANSPARENT=TRUE",
            "SRS=EPSG:900913",
            "WIDTH=256",
            "HEIGHT=256",
            "FORMAT=image/png",
            `LAYERS=${layer.layers_param ?? "image"}`
        ].join("&");
    }

    getTileUrl(coord, zoom) {
        const lULP = new google.maps.Point(coord.x*256,(coord.y+1)*256);
        const lLRP = new google.maps.Point((coord.x+1)*256,coord.y*256);

        const projectionMap = new MercatorProjection();

        const lULg = projectionMap.fromDivPixelToSphericalMercator(lULP, zoom);
        const lLRg  = projectionMap.fromDivPixelToSphericalMercator(lLRP, zoom);

        const lUL_Latitude = lULg.y;
        const lUL_Longitude = lULg.x;
        const lLR_Latitude = lLRg.y;
        const lLR_Longitude = lLRg.x < lUL_Longitude ? Math.abs(lLRg.x) : lLRg.x;
        const bbox = `${lUL_Longitude},${lUL_Latitude},${lLR_Longitude},${lLR_Latitude}`
        return `${this.baseURL}${this.wmsParams}&bbox=${bbox}`;
    }

    get overlayOptions() {
        return {
            getTileUrl: this.getTileUrl.bind(this),
            tileSize: new google.maps.Size(256, 256),
            minZoom: 2,
            maxZoom: 28,
            opacity: 1,
            isPng: true,
            name: this.id
        }
    }

    load() {
        const overlayWMS = new google.maps.ImageMapType(this.overlayOptions);

        if (this.position === 'top') {
            this.map.overlayMapTypes.push(overlayWMS);
        } else if (this.position) {
            this.map.overlayMapTypes.insertAt(this.position, overlayWMS);
        } else {
            this.map.overlayMapTypes.insertAt(0, overlayWMS);
        }

        return overlayWMS;
    }
}

export default function loadWMS(map, layer, position){
    const loader = new WMSLoader(map, layer, position);
    return loader.load()
}
