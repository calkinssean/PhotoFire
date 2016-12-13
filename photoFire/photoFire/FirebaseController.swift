//
//  FirebaseController.swift
//  photoFire
//
//  Created by Sean Calkins on 12/12/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class FirebaseController {
    
    static let shared = FirebaseController()
    
    var photos = [FirePhoto]()
    let storageRef = FIRStorage.storage().reference(forURL: "gs://photofire-ea973.appspot.com")
    
    init(){
        
        self.observePhotos()
        
    }
    
}


// MARK: - Image download and upload operations
extension FirebaseController {
    
    func upload(photo: FirePhoto) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let imageRef = storageRef.child("photos").child(uid).child("\(Date().timeIntervalSince1970)".components(separatedBy: ".").first!)
        
        imageRef.put(photo.imageData, metadata: nil) {
            
            metadata, error in
            
            if (error != nil) {
                
            } else {
              
                if let downloadURL = metadata!.downloadURL() {
                 
                    photo.imageDownloadURLString = "\(downloadURL)"
                    
                    photo.ref = FIRDatabase.database().reference().child("Photos").child("\(uid)\(Date().timeIntervalSince1970)".components(separatedBy: ".").first!)
                    
                    photo.save()
                    
                }
                
            }
            
        }
        
    }
    
    func downloadImage(for photo: FirePhoto) {
     
        let downloadRef = FIRStorage.storage().reference(forURL: photo.imageDownloadURLString)
    
        downloadRef.data(withMaxSize: 1 * 1600 * 1600) { (data, error) -> Void in
            if (error != nil) {
                
                print(error!.localizedDescription)
                
            } else {
                
                if let data = data, let image = UIImage(data: data) {
                   
                    photo.image = image
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Photos Downloaded"), object: nil)
                }
            }
        }
    }
}

// MARK: - Observers
extension FirebaseController {
    
    func observePhotos() {
     
        FIRDatabase.database().reference().child("Photos").observe(.childAdded, with: {
            
            snapshot in
            
            if let dict = snapshot.value as? [String: Any] {
             
                let photo = FirePhoto(dict: dict)
                self.photos.append(photo)

            }
            
        })
        
        FIRDatabase.database().reference().child("Photos").observe(.childRemoved, with: {
            
            snapshot in
            
            if let dict = snapshot.value as? [String: Any] {
                
                print(dict)
                
            }
            
        })

    }
    
}
