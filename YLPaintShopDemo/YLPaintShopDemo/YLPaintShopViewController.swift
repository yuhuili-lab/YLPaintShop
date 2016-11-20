//
//  YLPaintShopViewController.swift
//  YLPaintShopDemo
//
//  Created by Yuhui Li on 2016-11-20.
//  Copyright © 2016 Yuhui Li. All rights reserved.
//

import UIKit

enum YLPaintShopEffect {
    case Scatter
    case PaintEdge
    case GaussianBlur
}

let effectLibrary = ["Scatter", "Paint Edge", "Gaussian Blur"]

class YLPaintShopViewController: UIViewController {

    let defaultImage = UIImage(named: "pusheen.jpg")
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.reset(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reset(_ sender: Any) {
        imageView.image = defaultImage
        activityIndicator.isHidden = true
    }
    
    @IBAction func newEffect(_ sender: Any) {
        askForEffect { effect in
            self.askValue(valueTitle: self.parameterNameOfEffect(effect), effectName: self.nameOfEffect(effect), { (parameter) in
                self.applyEffect(effect, parameter: parameter, reset: true)
            })
        }
    }

    @IBAction func addEffect(_ sender: Any) {
        askForEffect { effect in
            self.askValue(valueTitle: self.parameterNameOfEffect(effect), effectName: self.nameOfEffect(effect), { (parameter) in
                self.applyEffect(effect, parameter: parameter, reset: false)
            })
        }
    }
    
    func nameOfEffect(_ effect: YLPaintShopEffect) -> String {
        switch effect {
        case .Scatter:
            return "Scatter"
        case .PaintEdge:
            return "Paint Edge"
        case .GaussianBlur:
            return "Gaussian Blur"
        }
    }
    
    func effectOfName(_ name: String) -> YLPaintShopEffect {
        switch name {
        case "Scatter":
            return .Scatter
        case "Paint Edge":
            return .PaintEdge
        case "Gaussian Blur":
            return .GaussianBlur
        default:
            return .Scatter
        }
    }
    
    func parameterNameOfEffect(_ effect: YLPaintShopEffect) -> String {
        switch effect {
        case .Scatter:
            return "radius"
        case .PaintEdge:
            return "threshold"
        case .GaussianBlur:
            return "radius"
        }
    }
    
    func askForEffect(_ onCompletion:@escaping (_: YLPaintShopEffect) -> Void) {
        let alert = UIAlertController(title: "Choose an Effect", message: "Please choose an effect to be applied to the image.", preferredStyle: .alert)
        
        for effectName in effectLibrary {
            alert.addAction(UIAlertAction(title: effectName, style: .default, handler: { _ in
                onCompletion(self.effectOfName(effectName))
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func askValue(valueTitle vt:String, effectName:String, _ onCompletion:@escaping (_: Int) -> Void) {
        let alert = UIAlertController(title: effectName, message: String(format:"Please enter the value for %@", vt), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = vt
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let textField = alert.textFields![0] as UITextField
            onCompletion(Int(textField.text!)!)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func applyEffect(_ effect: YLPaintShopEffect, parameter:Int, reset: Bool) {
        
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        var newImage:UIImage?
        
        DispatchQueue.global(qos: .background).async {
            
            switch effect {
            case .Scatter:
                if reset {
                    newImage = self.defaultImage?.scatter(parameter)
                } else {
                    newImage = self.imageView.image?.scatter(parameter)
                }
                break
            case .PaintEdge:
                if reset {
                    newImage = self.defaultImage?.paintEdge(parameter)
                } else {
                    newImage = self.imageView.image?.paintEdge(parameter)
                }
                break
            case .GaussianBlur:
                if reset {
                    newImage = self.defaultImage?.gaussianBlur(parameter)
                } else {
                    newImage = self.imageView.image?.gaussianBlur(parameter)
                }
                break
            }
            
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.imageView.image = newImage
                self.saveImage()
            }
        }
        
        
    }
    
    func saveImage() {
        let fileManager = FileManager.default
        let path = String((NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)) + String(format:"/%i.png", Int(arc4random()%10000+10000))
        print(path)
        let imageData = UIImagePNGRepresentation(imageView.image!)
        fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
    }
}
