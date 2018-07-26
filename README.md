# GCDDispatch

iOS开发多线程处理常用GCD，相比NSThread和NSOperation更简单 便捷 易懂。Swift语法中对GCD的API进行了精简和优化 , 所以GCD使用更多。

* Dispatch

Dispatch会自动的根据CPU的使用情况，创建线程来执行任务，并且自动的运行到多核上，提高程序的运行效率。对于开发者来说，在GCD层面是没有线程的概念的，只有队列（queue）。任务都是以block的方式提交到对列上，然后GCD会自动的创建线程池去执行这些任务。

* DispatchQueue

DispatchQueue是一个类似线程的概念，这里称作对列队列是一个FIFO数据结构，(意味着先提交到队列的任务会先开始执行) 。DispatchQueue背后是一个由系统管理的线程池。

* DispatchQoS

DispatchQoS是服务质量等级，通过设置DispatchQueue的QoS，您可以指出其重要性，系统会对其进行优先级排序并相应地对其进行调度。
由于优先级较高的工作比较低优先级的工作执行得更快，资源更多，因此通常比低优先级工作需要更多的能量。为您的应用程序执行的工作准确指定适当的QoS类可确保您的应用程序具有响应性和节能性。

>优先级 :
  userInteractive > userInitiated > default > utility > background > unspecified

* DispatchQueue.Attributes 

DispatchQueue.Attributes是队列的属性(结构体)

  >concurrent 并行的方式运行 ，队列的所有任务同时处理
  
  >initiallyInactive 任务不会被自动执行，而是需要开发者手动去触发
  
  * DispatchWorkItem
  
  DispatchWorkItem 是一个代码块，它可以在任意一个队列上被调用，因此它里面的代码可以在后台运行，也可以在主线程运行。
  
  * DispatchSource
  
  DispatchSource 提供了一个接口，用于监视低级系统对象，如Mach端口，Unix描述符，Unix信号和VFS节点，用于活动和提交事件处理程序，以便在发生此类活动时调度队列以进行异步处理。
  
  DispatchSourceProtocol 基础协议，所有的用到的DispatchSource都实现了这个协议。
  几个共有的协议的方法:
  >activate //激活
  
  >suspend //挂起
  
  >resume //继续
  
  >cancel //取消(异步的取消，会保证当前eventHander执行完)
  
  >setEventHandler //事件处理逻辑
  
  >setCancelHandler //取消时候的清理逻辑
  
  * DispatchGroup
  
  DispatchGroup用来管理一组任务的执行，然后监听任务都完成的事件。(可以使用它提交多个不同的工作项并跟踪它们何时完成，即使它们可能在不同的队列上运行。)
  
  >enter() 添加事件记录
  
  >leave() 完结事件记录
  
  >wait() 等待之前提交的任务完成 DispatchTimeoutResult是返回是否处理完成
  
  添加和完结的记录相等才会调用notify通知方法
  
  * DispatchSemaphore
  
  DispatchSemaphore 是通过信号量来控制多个任务执行对资源的访问。
  
  * DispatchWorkItemFlags barrier
  
  DispatchWorkItemFlags是一个选项集，用于配置队列的任务执行行为，包括其服务质量类以及是创建障碍还是生成新的分离线程。
  
  barrier 是设置栅栏拦截， 出现拦截时需要处理完之前的任务, 才能执行新的任务。


  
  
