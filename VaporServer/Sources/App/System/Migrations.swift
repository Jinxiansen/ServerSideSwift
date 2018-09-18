//
//  swift
//  App
//
//  Created by 晋先森 on 2018/9/19.
//

import Foundation
import Vapor
import Fluent

extension MigrationConfig {
    
    mutating func setupModels() {
        
        add(model: User.self, database: .psql)
        add(model: EmailResult.self, database: .psql)
        
        add(model: PageView.self, database: .psql)
        add(model: AccessToken.self, database: .psql)
        add(model: RefreshToken.self, database: .psql)
        add(model: Record.self, database: .psql)
        
        add(model: Word.self, database: .psql)
        add(model: Idiom.self, database: .psql)
        add(model: SinWord.self, database: .psql)
        add(model: XieHouIdiom.self, database: .psql)
        add(model: Report.self, database: .psql)
        add(model: UserInfo.self, database: .psql)
        add(model: LGWork.self, database: .psql)
        add(model: CrawlerLog.self, database: .psql)
        add(model: ScreenShot.self, database: .psql)
        add(model: BookChapter.self, database: .psql)
        add(model: BookInfo.self, database: .psql)
        
        // job
        add(model: HKJob.self, database: .psql)
        add(model: HKJobApply.self, database: .psql)
        add(model: EnJob.self, database: .psql)
        add(model: EnJobDetail.self, database: .psql)
        add(model: EnJobApply.self, database: .psql)
        
        add(model: NoteLive.self, database: .psql)
        add(model: NoteBill.self, database: .psql)
        
        //test
        add(model: MyModel.self, database: .psql)
        
        
        
    }
    
}
