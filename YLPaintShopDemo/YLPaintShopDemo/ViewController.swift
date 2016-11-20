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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mainImageView.image = sampleImage.scatter(20)
        
    }
    
    @IBAction func sliderValueChanged(sender: AnyObject) {
        if (shouldDraw) {
            shouldDraw = false;
            
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
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

