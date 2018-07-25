//
//  ViewController.swift
//  DispatchEfficiency
//
//  Created by 任义春 on 2018/7/24.
//  Copyright © 2018年 Zhuxin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dispatchAfterDoing()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: 延时处理
    func dispatchAfterDoing(){
        print("dispatchAfterDoing --->  开始处理")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print("延时处理")
        }
        print("dispatchAfterDoing --->  结束处理")
    }

    //MARK: 
}

