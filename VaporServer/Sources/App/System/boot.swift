import Vapor
import FluentPostgreSQL

/// Called after your application has initialized.

public func boot(_ app: Application) throws {
    
      //定时器
//    func runRepeatTimer() {
//        _  = app.eventLoop.scheduleTask(in: TimeAmount.seconds(5), runRepeatTimer) // 3s
//        foo(on: app)
//    }
//    runRepeatTimer()
    
}


func foo(on container: Container) {
    
    
    let future = container.withPooledConnection(to: .psql) { db in
        return Future.map(on: container){ "\(db) timer running" }
    }
    future.do{ msg in
        print(msg )
        }.catch{ error in
            print("\(error.localizedDescription)")
    }
    
}



