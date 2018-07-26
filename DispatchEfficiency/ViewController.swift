//
//  ViewController.swift
//  DispatchEfficiency
//
//  Created by 任义春 on 2018/7/24.
//  Copyright © 2018年 Zhuxin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var inactive : DispatchQueue?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDispatchWorkItemFlagsTest()
        if #available(iOS 10.0, *) {
            self.inActiveQueue()
        } else {
            // Fallback on earlier versions
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //activate() 方法会让任务开始执行
        if #available(iOS 10.0, *) {
            self.inactive?.activate()
        } else {
            // Fallback on earlier versions
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: 主线程延时处理
    func dispatchQueueMainAfterDoing(){
        print("dispatchAfterDoing --->  开始处理")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print("延时处理")
        }
        print("dispatchAfterDoing --->  结束处理")
    }

    //MARK: 自定义队列延时处理
    func defaultQueueAfter(){
        let queue = DispatchQueue.init(label: "queue-after")
        let additionalTime: DispatchTimeInterval = .seconds(2)
        print("准备延时处理\(Date())")
        queue.asyncAfter(deadline: .now()+additionalTime) {
            print("开始延时处理\(Date())")
        }
    }

    //MARK: 单队列手动启动(inactive)
    @available(iOS 10.0, *)
    func inActiveQueue(){
        // atrributes 参数可设置是数组 [.initiallyInactive,.concurrent]
        let queue = DispatchQueue.init(label: "inactive-Queue", attributes: .initiallyInactive)
        self.inactive = queue
        queue.async {
            print("inactiveQueue --> 处理任务")
        }
        print("inactiveQueue --> 发配任务")
    }

    //MARK: 单队列并发
    func queueConcurrent(){
        //当attributes 参数被指定为 concurrent 时，该特定队列中的所有任务都会被同时执行
        let defaultQueue = DispatchQueue.init(label: "concurrent-Queue", qos: .utility , attributes: .concurrent )
        defaultQueue.async {
            for n in 0...10{
                print("😁 = default = \(n)")
            }
        }
        defaultQueue.async {
            for i in 0...100{
                print("😎 = initiated = \(i)")
            }
        }
    }

    //MARK: 多队列优先级处理
    func queueQosNoAttribute(){
        // 设置队列优先等级qos
        let defaultQueue = DispatchQueue.init(label: "QueueQosdefault", qos: .default)
        let initiatedQueue = DispatchQueue.init(label: "QueueInitiated", qos: .userInitiated)
        defaultQueue.async {
            for n in 0...5{
                print("😁 = default = \(n)")
            }
        }
        initiatedQueue.async {
            for i in 0...5{
                print("😎 = initiated = \(i)")
            }
        }
    }

    //MARK: 多队列优先级处理(并发)
    func queueQosConcurrent(){
        // 设置队列优先等级qos 和 attribute
        // concurrent并发 多队列之间资源可共享
        let defaultQueue = DispatchQueue.init(label: "concurrent-QueueQosdefault", qos: .default, attributes: .concurrent)
        let initiatedQueue = DispatchQueue.init(label: "concurrent-QueueInitiated", qos: .userInitiated, attributes: .concurrent)
        defaultQueue.async {
            for n in 0...5{
                print("😁 = default = \(n)")
            }
        }
        initiatedQueue.async {
            for n in 0...5{
                print("😢 = default = \(n)")
            }
            for i in 0...100{
                print("😎 = initiated = \(i)")
            }
        }
    }

    //MARK: DispatchWorkItem 派遣工作项目
    func useWorkItem() {
        var value = 10
        // 创建任务代码块
        let workItem = DispatchWorkItem {
            value += 5
        }
        // workItem.perform() 执行任务代码块

        let queue = DispatchQueue.global(qos: .utility)
        // 将任务派发到队列处理
        queue.async(execute: workItem)
        // 给任务对象添加通知
        workItem.notify(queue: DispatchQueue.main) {
            print("value = ", value)
        }
    }

    //MARK: DispatchSourceTimer
    func dispatchSourceTimerTest(){
        let timer = DispatchSource.makeTimerSource()
        // 定时触发
        timer.setEventHandler {
            //这里要注意循环引用，[weak self] in
            print("Timer fired at \(NSDate())")
        }
        // 结束触发
        timer.setCancelHandler {
            print("Timer canceled at \(NSDate())" )
        }

        // deadline 表示开始时间
        // leeway   表示能够容忍的误差。
        //repeating 标识间隔时间
        timer.schedule(deadline: .now() + .seconds(1), repeating: 2.0, leeway: .microseconds(10))

        print("Timer resume at \(NSDate())")
        // 重新开启
        timer.resume()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(20), execute:{
            timer.cancel()
        })
    }


    //MARK: 模拟网络请求
    func networkTask(parameter : String , costTime : UInt32 , complate :@escaping ()->Void){
        print("request start \(Date())")
        DispatchQueue.global().async {
            sleep(costTime)
            print(parameter + "request resulted \(Date())")
            DispatchQueue.main.async(execute: {
                complate()
            })
        }
    }

    //MARK: DispatchGroup 多队列任务管理
    func creatDispatchGroup(){
        let group = DispatchGroup.init()

        group.enter()
        self.networkTask(parameter: "第一个请求", costTime: 2) {
            group.leave()
            print("request complate , groud leave \(Date())")
        }

        group.enter()
        self.networkTask(parameter: "第二个请求", costTime: 4) {
            group.leave()
            print("request complate , groud leave \(Date())")
        }

        print("First Before wait")
        //等待返回之前任务是否完结
        let ResultTime = group.wait(timeout: .now() + .seconds(5))
        print("First After wait \(ResultTime)")

        group.notify(queue: .main) {
            print("Done wait")
            //等待返回之前任务是否完结
            let ResultTime = group.wait(timeout: .now() + .seconds(5))
            print("Done wait \(ResultTime)")
            print("All NetWork is done")
        }
    }

    //MARK: 信号量记录队列任务
    func dispatchSemaphoreTest(){
        // 设置信号量个数
        let semaphore = DispatchSemaphore(value: 2)
        let queue = DispatchQueue(label: "dispatchSemaphoreQueue", qos: .default, attributes: .concurrent)

        queue.async {
            semaphore.wait()
            self.testTask(parameter: "1", costTime: 2, complate: {
                semaphore.signal()
            })
        }

        queue.async {
            semaphore.wait()
            self.testTask(parameter: "2", costTime: 2, complate: {
                semaphore.signal()
            })
        }
        // 当前型号量数是2  任务数大于2 需要等之前任务结束 信号量消费完 执行新的任务
        queue.async {
            semaphore.wait()
            self.testTask(parameter: "3", costTime: 1, complate: {
                semaphore.signal()
            })
        }
    }

    func testTask(parameter : String , costTime : UInt32 , complate :@escaping ()->Void){
        NSLog("Start %@",parameter)
        sleep(costTime)
        NSLog("End %@",parameter)
        complate()
    }

    //MARK: 添加barrier 任务队列栅栏处理
    //DispatchWorkItemFlags是一个选项集
    func addDispatchWorkItemFlagsTest(){
        let concurrentQueue = DispatchQueue(label: "dispatchWorkItemFlags", attributes: .concurrent)
        concurrentQueue.async {
            self.readDataTask(parameter: "3", costTime: 3)
        }

        concurrentQueue.async {
            self.readDataTask(parameter: "3", costTime: 3)
        }
        concurrentQueue.async(flags: .barrier, execute: {
            NSLog("Task from barrier 1 begin")
            sleep(3)
            NSLog("Task from barrier 1 end")
        })

        concurrentQueue.async {
            self.readDataTask(parameter: "3", costTime: 3)
        }
    }

    func readDataTask(parameter : String , costTime : UInt32 ){
        print(parameter + " request start \(Date())")
        sleep(costTime)
        print(parameter + " request resulted \(Date())")

    }


}

