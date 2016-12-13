//
//  ViewController.swift
//  photoFire
//
//  Created by Sean Calkins on 12/12/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Properties
    let pickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerController.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: NSNotification.Name(rawValue: "Photos Downloaded"), object: nil)
      
    }

}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseController.shared.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Photo Cell", for: indexPath) as! PhotoFireTableViewCell
        
        let photo = FirebaseController.shared.photos[indexPath.row]
        
        cell.photoFireImageView.image = photo.image
        
        return cell
        
    }
    
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.view.frame.width
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.reloadData()
    }
    
}

// MARK: - Helper Methods
extension ViewController {
    
    func handleNotification() {
        
        self.tableView.reloadData()
        
    }
    
    func photoAdded() {
        
    }
    
    func photoRemoved() {
        
    }
    
    func resizeImage(image: UIImage, newSize: CGSize) -> (UIImage) {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext(), let imageRef = image.cgImage else {
            return UIImage()
        }
        
        // Set the quality level to use when rescaling
        context.interpolationQuality = CGInterpolationQuality.high
        let verticalFlip = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        
        context.concatenate(verticalFlip)
        // Draw into the context; this scales the image
        context.draw(imageRef, in: newRect)
      
        let newImageRef = context.makeImage()! as CGImage
        let newImage = UIImage(cgImage: newImageRef)
        
        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
    
}

// MARK: - IBAction
extension ViewController {
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        
        displayImagePickerSourceAlert()
        
    }
    
}

// MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Take Picture Tapped
    func displayImagePickerSourceAlert() {
        
        let alert = UIAlertController(title: "Image Source", message: nil, preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "Library", style: .default, handler: {
            action in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
             
                self.pickerController.allowsEditing = true
                self.pickerController.sourceType = .photoLibrary
                self.displayPickerController()
                
            } else {
                
                print("no access")
                
            }
            
        })
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                self.pickerController.sourceType = .camera
                self.pickerController.allowsEditing = true
                self.displayPickerController()
                
            } else {
                
                print("no access")
                
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(libraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        pickerController.dismiss(animated: true, completion: nil)
    }
    
    func displayPickerController() {
        
        self.present(pickerController, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage, let data = UIImagePNGRepresentation(editedImage) as Data? {
            
            let p = FirePhoto()
            
            let smallerImage = self.resizeImage(image: editedImage, newSize: CGSize(width: self.view.frame.width, height: self.view.frame.width))
            
            p.image = smallerImage
            p.imageData = data
            p.created = Date()
           
            FirebaseController.shared.upload(photo: p)
            
        }

        pickerController.dismiss(animated: true, completion: nil)
        
    }

    
}
