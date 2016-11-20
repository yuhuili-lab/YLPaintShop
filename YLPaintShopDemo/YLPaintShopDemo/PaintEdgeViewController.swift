//
//  PaintEdgeViewController.swift
//  YLPaintShopDemo
//
//  Created by Yuhui Li on 2016-11-20.
//  Copyright © 2016 Yuhui Li. All rights reserved.
//

import UIKit

class PaintEdgeViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    
    // Put a delay to image render
    var shouldDraw = true
    var sampleImage = UIImage(named: "pusheen.jpg")!
    var lastThreshold = 120
    var delay = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        slider.value = Float(lastThreshold)
        mainImageView.image = sampleImage.paintEdge(lastThreshold)
    }
    
    @IBAction func sliderValueChanged(_ sender: AnyObject) {
        
        // Add lastRadius to prevent repeated drawing of same integer radius
        if shouldDraw && lastThreshold != Int(slider.value) {
            shouldDraw = false
            lastThreshold = Int(slider.value)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                self.shouldDraw = true;
            })
            
            mainImageView.image = sampleImage.paintEdge(Int(slider.value))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
