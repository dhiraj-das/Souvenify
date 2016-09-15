//
//  MapViewController.swift
//  Souvenify
//
//  Created by Dhiraj Das on 8/29/16.
//  Copyright © 2016 Dhiraj Das. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseAuth
import Firebase
import GoogleSignIn
import ImagePicker
import Lightbox


class MapViewController: UIViewController, SideBarDelegate, UIPopoverPresentationControllerDelegate{

    @IBOutlet weak var mapView: GMSMapView!
    
    var firAuthUser : FIRAuth!
    var locationManager = CLLocationManager()
    var didFindLocation = false
    var searchResultController : SearchResultViewController!
    var resultsArray = [String]()
    var resultMarker : GMSMarker!
    var sideBar = SideBar()
    var currentMarker : GMSMarker!
    var tappedAnnotation: Annotation?
    var infoTap : UITapGestureRecognizer!
    var annotations: [Annotation] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultController = SearchResultViewController()
        searchResultController.delegate = self

        let camera = GMSCameraPosition.cameraWithLatitude(-33.86, longitude: 151.20, zoom: 6.0)
        mapView.camera=camera;
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.myLocationEnabled = true
        locationManager.requestWhenInUseAuthorization()
        mapView.settings.setAllGesturesEnabled(true)
        mapView.settings.consumesGesturesInView = false
        
        sideBar = SideBar(sourceView: self.view, menuItems: ["first item", "second item", "funny item", "Sign Out"], user: firAuthUser)
        sideBar.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.hidesBackButton = true
        let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(MapViewController.searchButtonPressed))
        let drawerButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .Plain, target: self, action: #selector(MapViewController.drawerButtonPressed))
        self.navigationItem.rightBarButtonItem = searchButton
        self.navigationItem.leftBarButtonItem = drawerButton
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        populateUserMarkers()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func populateUserMarkers() {
        
        let databaseReference = FIRDatabase.database().referenceFromURL("https://souvenify.firebaseio.com/").child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("locations")
        databaseReference.observeSingleEventOfType(.Value, withBlock: { (snapshots) in
            
            for snapshot in snapshots.children {
                let key = String(snapshot.key)
                if let lat = snapshot.value["latitude"] as? Double {
                    if let lon = snapshot.value["longitude"] as? Double {
                        let coordinate = CLLocationCoordinate2DMake(lat, lon)
                        let marker = GMSMarker(position: coordinate)
                        marker.map = self.mapView
                        let annotation = Annotation(location: coordinate, key: key, marker: marker)
                        self.annotations.append(annotation)
                    }
                }
            }
        })
    }
    
    
    
    func drawerButtonPressed() {
        if sideBar.isSideBarOpen {
            sideBar.handleTap()
        }else{
            sideBar.handleSwipe()
        }
    }
    
    func sideBarDidSelectButtonAtIndex(index: Int, section: Int) {
        if section != 0 && index == 0{
            print("Profile Picture")
        } else if index == 1{
            print("2nd Button pressed")
        } else if index == 3{
            self.signOut()
            GIDSignIn.sharedInstance().disconnect()
        }
    }
    
    func signOut(){
        do{
            try! FIRAuth.auth()!.signOut()
            navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
}

//MARK: SearchControllerDelegate & SearchBarDelegate code
extension MapViewController : SearchResultViewControllerDelegate, UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error:NSError?) in
            self.resultsArray.removeAll()
            if results == nil {
                return
            }
            for result in results!{
                self.resultsArray.append(result.attributedFullText.string)
            }
            self.searchResultController.reloadDataWithArray(self.resultsArray)
        }
    }
    
    func searchButtonPressed() {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.presentViewController(searchController, animated: true, completion: nil)
    }

}

//MARK: MapView Delegate code
extension MapViewController : GMSMapViewDelegate {
    
    func locateWithLongitude(lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        performUIUpdatesOnMain({
            let position = CLLocationCoordinate2DMake(lat, lon)
            self.resultMarker = GMSMarker(position: position)
            
            let camera  = GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: 10)
            self.mapView.camera = camera
            
            self.resultMarker.title = title
            //self.resultMarker.map = self.mapView
        })
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        
        currentMarker = marker
        tappedAnnotation = annotations.filter() { $0.marker == marker}.first
        
        let contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("popover") as? PopoverViewViewController
        contentViewController!.modalPresentationStyle = .Popover
        contentViewController?.preferredContentSize = CGSizeMake(180, 60)
        performUIUpdatesOnMain({ contentViewController?.gallery.enabled = false })
        contentViewController?.currentMarker = currentMarker
        contentViewController?.tappedAnnotation = tappedAnnotation
        let databaseReference = FIRDatabase.database().referenceFromURL("https://souvenify.firebaseio.com/").child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("locations").child((tappedAnnotation?.key)!)
        databaseReference.observeSingleEventOfType(.Value, withBlock: { (snapshots) in
            for snapshot in snapshots.children {
                if snapshot.childrenCount > 0 {
                    contentViewController?.gallery.enabled = true
                }
            }
        })
        
        let popover = contentViewController?.popoverPresentationController
        contentViewController?.popoverPresentationController?.sourceRect = marker.accessibilityFrame
        contentViewController?.popoverPresentationController?.sourceView = self.view
        popover?.permittedArrowDirections = .Any
        popover?.delegate = self
        
        presentViewController(contentViewController!, animated: true, completion: nil)

        return true
    }
    
    
    func mapView(mapView: GMSMapView, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        print("Marker added")
        
        let marker = GMSMarker(position: coordinate)
        marker.map = self.mapView
        
        let databaseReference = FIRDatabase.database().referenceFromURL("https://souvenify.firebaseio.com/")
        let userReference = databaseReference.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("locations").childByAutoId()
        let values : [String : Double] = ["latitude": coordinate.latitude, "longitude": coordinate.longitude]
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err?.localizedDescription)
                return
            }
            let addedAnnotation = Annotation(location: coordinate, key: ref.key, marker: marker)
            self.annotations.append(addedAnnotation)
        })
    }

}
