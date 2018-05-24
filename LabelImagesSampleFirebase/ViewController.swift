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


    // [START config_label]
    let options = VisionLabelDetectorOptions(confidenceThreshold: 0.7)
    // [END config_label]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = UIImage(named: "sample")
        loadLabels(imageToEvaluate: imageView.image!)
        imagePicker?.delegate = self;

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
    
    func loadLabels(imageToEvaluate: UIImage){

        self.imageView.image = imageToEvaluate
        self.result.text = "";
        let labelDetector = vision.labelDetector(options: self.options)
        
        let visionImage = VisionImage(image: imageToEvaluate)
        let metadata = VisionImageMetadata()
        
        print(imageToEvaluate.imageOrientation.rawValue)
//        if(imageToEvaluate.imageOrientation.rawValue == 0){
//            metadata.orientation = .leftTop
//        }
//        metadata.orientation = .rightTop
        
//        let image = VisionImage(buffer: bufferRef)
//        image.metadata = metadata
        
        labelDetector.detect(in: visionImage) { (labels, error) in
            guard error == nil, let labels = labels, !labels.isEmpty else {
                return
            }
            
            for label in labels {
                let labelText = label.label
                let entityId = label.entityID
                let confidence = label.confidence
                
                print("Label text: ", labelText)
                print("entityId: ", entityId)
                print("confidence: ", confidence)
                
                let entityToPrint = " \(labelText) - \(confidence) \n"
                self.result.text.append(entityToPrint)
            }
        }
        
    }
    
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

