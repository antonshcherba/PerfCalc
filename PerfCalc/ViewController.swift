//
//  ViewController.swift
//  PerfCalc
//
//  Created by Anton Shcherba on 11/12/19.
//  Copyright © 2019 Anton Shcherba. All rights reserved.
//

import UIKit
import Metal

class ViewController: UIViewController {

    let device = MTLCreateSystemDefaultDevice()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let metalAdder = MetalAdder.init(with: device)
        metalAdder.prepareData()
        metalAdder.sendComputeCommand()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

