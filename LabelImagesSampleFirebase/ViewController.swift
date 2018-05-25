//
//  ViewController.swift
//  LabelImagesSampleFirebase
//
//  Created by Martin Saporiti on 24/05/2018.
//  Copyright © 2018 Martin Saporiti. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var result: UITextView!
    
    lazy var vision = Vision.vision()
    
    var imagePicker : UIImagePickerController? = UIImagePickerController()

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // [START config_label]
//    let options = VisionLabelDetectorOptions(confidenceThreshold: 0.7)
    
    let options : VisionCloudDetectorOptions = {
        let options = VisionCloudDetectorOptions()
        options.modelType = .latest
        options.maxResults = 20
        return options
    }()

    
    
    // [END config_label]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = UIImage(named: "sample")
        loadLabels(imageToEvaluate: imageView.image!)
        imagePicker?.delegate = self;
        
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.center = view.center;

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
    func loadLabels(imageToEvaluate: UIImage){

        self.result.text = "";

        self.imageView.image = imageToEvaluate
//        let labelDetector = vision.labelDetector(options: self.options)
        let labelDetector = Vision.vision().cloudLabelDetector(options: options)
        let visionImage = VisionImage(image: imageToEvaluate)
        
        
        self.activityIndicator.startAnimating()
        DispatchQueue.main.async {
            labelDetector.detect(in: visionImage) { (labels, error) in
                guard error == nil, let labels = labels, !labels.isEmpty else {
                    return
                }
                

                var labelText : String? = ""
                var confidence: NSNumber? = 0
                var entityToPrint : String? = ""
                for label in labels {
                    labelText = label.label!
    //                var entityId = label.entityID
                    confidence = label.confidence

                    confidence = NSNumber(value: round((confidence?.doubleValue)! * 100))
                    entityToPrint = " \(labelText!) - \(confidence!)% \n"
                    self.result.text.append(entityToPrint!)
                }
                self.activityIndicator.stopAnimating()
            }
            
        }
    }
    
    
    // INTERACCIONES DEL USUARIO
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let selectedImage : UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.loadLabels(imageToEvaluate: selectedImage.fixedOrientation())
    }
    

    @IBAction func openCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker?.sourceType = .camera;
            imagePicker?.allowsEditing = false
            self.present(imagePicker!, animated: true, completion: nil);
        }
    }

    
    @IBAction func openLibrary(_ sender: Any) {
        imagePicker!.allowsEditing = false
        imagePicker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker!, animated: true, completion: nil)
    }
    
}

