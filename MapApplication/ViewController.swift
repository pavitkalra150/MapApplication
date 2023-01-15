//
//  ViewController.swift
//  MapApplication
//
//  Created by PAVIT KALRA on 2023-01-13.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate{

    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var directionBtn: UIButton!
    
    @IBOutlet weak var transportType: UISegmentedControl!
    var locationManager = CLLocationManager()
    var destination: CLLocationCoordinate2D!
    
    @IBOutlet weak var zoomIn: UIButton!
    @IBOutlet weak var zoomOut: UIButton!
    var type = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.isZoomEnabled = false
        map.showsUserLocation = true
    
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        map.delegate = self
        
        directionBtn.isHidden = true
        transportType.isHidden = true
        doubleTap()
        
    }

    //STEP 1
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        
        displayLocation(latitude: latitude, longitude: longitude, title: "my Location", subtitle: "you are here")
    }
    
    
    
    //STEP 2
    
    
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String){
        
        //DEFINE SPAN
        let latdelta: CLLocationDegrees = 0.05
        let lngdelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latdelta, longitudeDelta: lngdelta)
        
        
        //DEFINE LOCATION
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        
        //DEFINE REGION
        let region = MKCoordinateRegion(center: location, span: span)
        
        
        //SET REGION ON MAP
        map.setRegion(region, animated: true)
        
        
        //DEFINE ANNOTATION
        let annotation = MKPointAnnotation()
        
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
    }
    
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        
        removePin()
        map.removeOverlays(map.overlays)
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.title = "my destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        destination = coordinate
        directionBtn.isHidden = false
        transportType.isHidden = false
        
    }
    
    func doubleTap(){
        
        let double = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        double.numberOfTapsRequired = 2
        map.addGestureRecognizer(double)
    }
    
    func removePin(){
        for annotation in map.annotations{
            map.removeAnnotation(annotation)
        }
    }
    
//    @IBAction func zoomI(_ sender: UIButton) {
////        let userLocation = locations[0]
////        let latitude = userLocation.coordinate.latitude
////        let longitude = userLocation.coordinate.longitude
//
//
//        MKZoomScale(exactly: 0.7)
//    }
    
    
    
//    func zoomIn(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
//
//        let latdelta: CLLocationDegrees = 0.5
//        let lngdelta: CLLocationDegrees = 0.5
//
//
//        let span = MKCoordinateSpan(latitudeDelta: latdelta, longitudeDelta: lngdelta)
//
//
//        //DEFINE LOCATION
//        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//
//
//        //DEFINE REGION
//        let region = MKCoordinateRegion(center: location, span: span)
//
//        map.setRegion(region, animated: true)
//    }

    
    @IBAction func drawRoute(_ sender: UIButton) {
        
        
        map.removeOverlays(map.overlays)
        let sourcePlaceMark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        
        
        //REQUEST DIRECTION
        let directionRequest = MKDirections.Request()
        
        
        //ASSIGN SOURCE AND DESTINATION
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        //TRANSPORTATION TYPE
        directionRequest.transportType = .automobile
        
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate{ (response, error) in
            guard let directionResponse = response else {return}
            
            //CREATE ROUTE
            let route = directionResponse.routes[0]
            
            //DRAW POLYLINE
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            
            
        }
        
    }
    
    
    @IBAction func transportTypeClick(_ sender: UISegmentedControl) {
        
        
        let directionsRequest = MKDirections.Request()
        switch transportType.selectedSegmentIndex {
            case 0:
                directionsRequest.transportType = .automobile
            print(directionsRequest.transportType)
            break
            case 1:
                directionsRequest.transportType = .walking
            print(directionsRequest.transportType)
            break
        default:
                directionsRequest.transportType = .automobile
        }
    }
    
    
    
    
    
}

extension ViewController: MKMapViewDelegate {
    
    
    
    //STEP 3
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{
            return nil
        }
        
        switch annotation.title{
        case "my Location":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.markerTintColor = UIColor.orange
            return annotationView
        case "my destination":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.animatesWhenAdded = true
            annotationView.markerTintColor = UIColor.orange
            return annotationView
        default:
            return nil
        }
    }
    
    
    //RENDER FOR OVERLAY FUNCTION
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
}
