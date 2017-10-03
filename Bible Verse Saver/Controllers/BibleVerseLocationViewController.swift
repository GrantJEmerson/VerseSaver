//
//  locationView.swift
//  Bible Verse Saver
//
//  Created by Grant Emerson on 3/3/17.
//  Copyright © 2017 com.grant-emerson. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class BibleVerseLocationViewController: UIViewController {
    
    // MARK: - Properties
    
    var coordinate: CLLocationCoordinate2D!
    var annotationText: String!
    
    @IBOutlet weak var map: MKMapView!
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var region = MKCoordinateRegion()
        var span = MKCoordinateSpan()
        span.latitudeDelta = 0.01
        span.longitudeDelta = 0.01
        region.span = span
        region.center = coordinate
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "You Saved: " + annotationText
        
        map.addAnnotation(annotation)
        map.setRegion(region, animated: true)
        map.regionThatFits(region)
        
    }
    
    // MARK: - IBActions
    
    @IBAction func exitMap(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true)
    }
    
}

