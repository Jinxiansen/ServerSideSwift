import Vapor

/// Called after your application has initialized.

public func boot(_ app: Application) throws {
    
      //定时器
//    func runRepeatTimer() {
//        _  = app.eventLoop.scheduleTask(in: TimeAmount.seconds(3), runRepeatTimer) // 3s
//        foo(on: app)
//    }
//    runRepeatTimer()
    
}


func foo(on container: Container) {
    
    let future = container.withPooledConnection(to: .mysql) { db in
        return Future.map(on: container){ "timer running" }
    }
    future.do{ msg in
        print(msg + " \(arc4random())")
        }.catch{ error in
            print("\(error.localizedDescription)")
    }
    
}
