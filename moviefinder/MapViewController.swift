//
//  MapViewController.swift
//  moviefinder
//
//  Created by Paul Vialart on 15/02/2017.
//  Copyright © 2017 Margaux Smits, Paul Vialart. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.mapView.delegate = self
        // Ajout d'un observer pour récupérer les notifications du délégué
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange), name: Notification.Name.userDidChange, object: nil)
        
        // Ajout des movies sur la carte
        NotificationCenter.default.addObserver(self, selector: #selector(movieDidChange), name: NSNotification.Name.moviesDidChange, object: nil)

        
        
        let center = AppDelegate.instance().center
        let camera = MKMapCamera(lookingAtCenter: center, fromEyeCoordinate: center, eyeAltitude: 5000.0)
        self.mapView.setCamera(camera, animated: true)
        
    }
    
    func userDidChange(notification: Notification) {
        if let location = AppDelegate.instance().userLocation {
            let camera = MKMapCamera(lookingAtCenter: location.coordinate, fromEyeCoordinate: location.coordinate, eyeAltitude: 15000.0)
            self.mapView.setCamera(camera, animated: true)
        }
    }

    func movieDidChange(notification: Notification) {
        if let movies = AppDelegate.instance().movies {
            setAnnotations(with: movies)
        }
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
        // Requête
        let request = MKLocalSearchRequest()
        
        request.naturalLanguageQuery = "theatres"
        request.region = mapView.region
        print(mapView.region)
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
                return
            }
            
            for item in response.mapItems {
                let theatre = Movie(coordinate: item.placemark.coordinate)
                let pin = MKPointAnnotation()
                pin.coordinate = theatre.coordinate
                pin.title = item.name
                pin.subtitle = item.placemark.countryCode
                    mapView.addAnnotation(pin)
                
//                var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
//                if annotationView == nil {
//                    annotationView = MKPinAnnotationView(annotation: pin, reuseIdentifier: "Pin")
//                    annotationView?.canShowCallout = true
//                    annotationView?.rightCalloutAccessoryView = UIButton(type: .InfoLight)
//                }
//                else {
//                    annotationView?.annotation = pin
//                }
//                
            }
        }
    }

    // Do any additional setup after loading the view.

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    func setAnnotations(with movies: [[String: Any]]) {
        
        let centerLocation = CLLocation(latitude: centerLat, longitude: centerLon)
        
        //        for content in fountains {
        //            if  let loc = content["loc"] as? [String: Any],
        //                let lat = loc["lat"] as? CLLocationDegrees,
        //                let lon = loc["lon"] as? CLLocationDegrees
        //            {
        //                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        //                let fountain = Fountain(coordinate: coordinate)
        //                self.mapView.addAnnotation(fountain)
        //            }
        //        }
        //
        //
        //        let annotations0 = fountains
        //            .map { (content: [String : Any]) -> MKAnnotation in
        //                if  let loc = content["loc"] as? [String: Any],
        //                    let lat = loc["lat"] as? CLLocationDegrees,
        //                    let lon = loc["lon"] as? CLLocationDegrees
        //                {
        //                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        //                    let fountain = Fountain(coordinate: coordinate)
        //                    return fountain
        //                }
        //                let coordinate = CLLocationCoordinate2D()
        //                return Fountain(coordinate: coordinate)
        //            }
        
        let annotations = movies
            .flatMap { (content: [String : Any]) -> MKAnnotation? in
                if  let loc = content["loc"] as? [String: Any],
                    let lat = loc["lat"] as? CLLocationDegrees,
                    let lon = loc["lon"] as? CLLocationDegrees
                {
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    let movie = Movie(coordinate: coordinate)
                    return movie
                }
                return nil
            }
            .sorted { /* (f0: MKAnnotation, f1: MKAnnotation) -> Bool in */
                let location0 = CLLocation(latitude: $0.coordinate.latitude,
                                           longitude: $0.coordinate.longitude)
                let location1 = CLLocation(latitude: $1.coordinate.latitude,
                                           longitude: $1.coordinate.longitude)
                let distance0 = centerLocation.distance(from: location0)
                let distance1 = centerLocation.distance(from: location1)
                
                return distance0 < distance1
        }
        
        self.mapView.addAnnotations(annotations)
    }
}
