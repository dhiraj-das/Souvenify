//
//  PopoverViewViewController.swift
//  Souvenify
//
//  Created by Dhiraj Das on 9/8/16.
//  Copyright © 2016 Dhiraj Das. All rights reserved.
//

import UIKit
import ImagePicker
import Lightbox
import Firebase
import GoogleMaps

class PopoverViewViewController: UIViewController, ImagePickerDelegate{

    var currentMarker : GMSMarker!
    
    @IBOutlet weak var gallery: UIButton!
    @IBOutlet weak var addPhotos: UIButton!
    
    
    @IBAction func galleryPressed(sender: AnyObject) {
        print("gallery pressed")
        
        var keys : [String] = [String]()
        var imagesURL = [String]()
        let databaseReference = FIRDatabase.database().referenceFromURL("https://souvenify.firebaseio.com/").child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("locations")
        databaseReference.observeSingleEventOfType(.Value, withBlock: { (snapshots) in
            
            for snapshot in snapshots.children {
                if let lat = snapshot.value["latitude"] as? Double {
                    if let lon = snapshot.value["longitude"] as? Double {
                        if self.currentMarker.position.latitude == lat && self.currentMarker.position.longitude == lon {
                            for child in snapshot.children {
                                keys.append(((child.key!)!))
                            }
                        }
                    }
                }
            }
            keys.removeLast()
            keys.removeLast()
            
            for snapshot in snapshots.children {
                if let lat = snapshot.value["latitude"] as? Double {
                    if let lon = snapshot.value["longitude"] as? Double {
                        if self.currentMarker.position.latitude == lat && self.currentMarker.position.longitude == lon {
                            for (_, val) in keys.enumerate() {
                                let temp = (snapshot.value[val]!)! as! String
                                imagesURL.append(temp)
                            }
                        }
                    }
                }
            }
            self.showPhotos(imagesURL)
        })
    }
    
    @IBAction func addPhotosPressed(sender: AnyObject) {
        print("add photos pressed")
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showPhotos(imagesURLArray: [String]){
        var image : UIImage?
        var images = [LightboxImage]()
        let session = NSURLSession.sharedSession()
        for eachImageURL in imagesURLArray {
            let url = NSURL(string: eachImageURL)!
            let request = NSURLRequest(URL: url)
            let task = session.dataTaskWithRequest(request) { (data, response, error) in
                image = UIImage(data: data!)
                images.append(LightboxImage(image: image!))
                if images.count == imagesURLArray.count {
                    let controller = LightboxController(images: images)
                    controller.dynamicBackground = true
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
            task.resume()
        }
    }
    
    func cancelButtonDidPress(imagePicker: ImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        addPhotos.enabled = true
    }
    
    func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        let lightboxImages = images.map {
            return LightboxImage(image: $0)
        }
        
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.presentViewController(lightbox, animated: true, completion: nil)
    }
    
    func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        
        addPhotos.enabled = false
        gallery.enabled = false
        let databaseReference = FIRDatabase.database().referenceFromURL("https://souvenify.firebaseio.com/").child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("locations")
        
        for image in images {
            let imageName = NSUUID().UUIDString
            let storageRef = FIRStorage.storage().reference().child((FIRAuth.auth()?.currentUser?.email)!).child("\(imageName).jpg")
            let uploadData = UIImageJPEGRepresentation(image, 0.1) // UIImagePNGRepresentation(image)
            
            //let locationData = FIRStorageMetadata()
            //locationData.customMetadata = ["latitude" : "\(currentMarker.position.latitude)" , "longitude" : "\(currentMarker.position.longitude)"]
            let task = storageRef.putData(uploadData!, metadata: nil)
            task.observeStatus(.Success) { snapshot in
                self.addPhotos.enabled = true
                self.gallery.enabled = true
                let downloadURL = (snapshot.metadata?.downloadURL()?.absoluteString)!
                print(downloadURL)
                databaseReference.observeSingleEventOfType(.Value, withBlock: { (snapshots) in
                    
                    for snapshot in snapshots.children {
                        if let lat = snapshot.value["latitude"] as? Double {
                            if let lon = snapshot.value["longitude"] as? Double {
                                if self.currentMarker.position.latitude == lat && self.currentMarker.position.longitude == lon {
                                    databaseReference.child(snapshot.key).childByAutoId().setValue(downloadURL)
                                }
                            }
                        }
                    }
                })
            }
        }
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }

    
}
