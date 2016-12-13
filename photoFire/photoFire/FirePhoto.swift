//
//  Photo.swift
//  photoFire
//
//  Created by Sean Calkins on 12/12/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FirePhoto {
   
    init(){}
    
    init(dict: [String: Any]) {
        
        print("init called")
        print(dict)
        
        if let created = dict["created"] as? Double {
            self.created = Date(timeIntervalSince1970: created)
        }
        
        if let ref = dict["ref"] as? String {
            self.ref = FIRDatabase.database().reference(fromURL: ref)
        }
        
        if let imageDownloadURL = dict["imageDownloadURLString"] as? String {
            
            print("image download url")
            self.imageDownloadURLString = imageDownloadURL
            self.fetchPhoto(photo: self)
            
        }
        
    }
    
    var image = UIImage()
    var created = Date()
    var imageData = Data()
    var ref = FIRDatabaseReference()
    var imageDownloadURLString = ""
    
}

extension FirePhoto {
    
    func fetchPhoto(photo: FirePhoto) {
        
        FirebaseController.shared.downloadImage(for: photo)
        
    }
    
}


// Saving
extension FirePhoto {
    
    func save() {
        
        self.ref.updateChildValues([
            
            "created": self.created.timeIntervalSince1970,
            "ref": "\(self.ref)",
            "imageDownloadURLString": self.imageDownloadURLString
            
            ])
        
    }
    
}
