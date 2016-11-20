//
//  ViewController.swift
//  YLPaintShopDemo
//
//  Created by Alexander Li on 2016-11-19.
//  Copyright © 2016 Yuhui Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    
    // Put a delay to image render
    var shouldDraw = true
    var sampleImage = UIImage(named: "pusheen.jpg")!
    var lastRadius = 20
    var delay = 0.05
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        slider.value = Float(lastRadius)
        mainImageView.image = sampleImage.scatter(lastRadius)
        
    }
    
    @IBAction func sliderValueChanged(_ sender: AnyObject) {
        
        // Add lastRadius to prevent repeated drawing of same integer radius
        if shouldDraw && lastRadius != Int(slider.value) {
            shouldDraw = false
            lastRadius = Int(slider.value)
            
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.shouldDraw = true;
            })
            
            mainImageView.image = sampleImage.scatter(Int(slider.value))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

