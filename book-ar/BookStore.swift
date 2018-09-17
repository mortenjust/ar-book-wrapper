//
//  BookStore.swift
//  book-ar
//
//  Created by Morten Just Petersen on 8/14/18.
//  Copyright © 2018 Morten Just Petersen. All rights reserved.
//

import UIKit

let bookStore = BookStore()


struct BookUrl {
    var site : String
    var url : URL
}



struct Book  {
    var width: CGFloat // inches, that's what amazon gives us
    var depth: CGFloat
    var height: CGFloat
    var url: BookUrl
    var title : String
}


class BookStore: NSObject {
    var secondBatch = [
//        ("Understanding", "https://www.youtube.com/embed/fXYckRgsdjI?autoplay=true"),
        
        ("Understanding", "https://www.amazon.com/Understanding-Comics-Invisible-10-May-2001-Paperback/dp/B011T7TJRW/ref=mp_s_a_1_2?ie=UTF8&qid=1534319707&sr=8-2&pi=AC_SX236_SY340_QL65&keywords=understanding+comics&dpPl=1&dpID=61dFmSB8LqL&ref=plSrch"),
                       ("Shape",
                        "https://www.amazon.com/Content-Charles-Norton-Lectures-1956-1957/dp/0674805704/ref=mp_s_a_1_1?ie=UTF8&qid=1534319813&sr=8-1&pi=AC_SX236_SY340_QL65&keywords=The+Shape+Of+Content&dpPl=1&dpID=51PQf6BFt6L&ref=plSrch"),
                       ("Humane", "https://www.amazon.com/Humane-Interface-Directions-Designing-Interactive/dp/0201379376/ref=mp_s_a_1_1?ie=UTF8&qid=1534319852&sr=8-1&pi=AC_SX236_SY340_QL65&keywords=The+Humane+Interface&dpPl=1&dpID=41wqicWUyDL&ref=plSrch"),
                       ("Seeing", "https://www.amazon.com/Ways-Seeing-Based-Television-Penguin/dp/0140135154/ref=mp_s_a_1_1?ie=UTF8&qid=1534319900&sr=8-1&pi=AC_SX236_SY340_QL65&keywords=Ways+of+Seeing&dpPl=1&dpID=51kMdpKJjFL&ref=plSrch"),
                       ("Citizens", "https://www.amazon.com/Citizens-No-Place-Architectural-Graphic/dp/1616890622/ref=mp_s_a_1_1?ie=UTF8&qid=1534319941&sr=8-1&pi=AC_SX236_SY340_QL65&keywords=Citizens+of+no+Place&dpPl=1&dpID=41ONsNClOVL&ref=plSrch")
    ]
    
    
    var all = [Book]()
    
    override init() {
        super.init()

        all.append(
            Book(width: 6.0,
                 depth: 0.4,
                 height: 8.5,
                 url: BookUrl(
                    site: "Amazon",
                    url: URL(
                        string: "https://www.amazon.com/gp/aw/d/B0772D5CSP/ref=tmm_kin_title_0?ie=UTF8&qid=1534234478&sr=8-1-fkmr1")!),
                 title: "Shenzen")
        )
        
        all.append(
            Book(width: 7,
                 depth: 1,
                 height: 5,
                 url: BookUrl(
                    site: "Amazon",
                    url: URL(
                        string: "https://www.amazon.com/Things-Learned-Architecture-School-Press-ebook/dp/B002CQV4OQ/ref=mp_s_a_1_1?ie=UTF8&qid=1534238731&sr=8-1&pi=AC_SX236_SY340_QL65&keywords=things+I+learned+in+architecture")!),
                 title: "Architecture School")
        )
        
//        all.append(
//            Book(width: 7,
//                 depth: 1,
//                 height: 5,
//                 url: BookUrl(
//                    site: "Amazon",
//                    url: URL(
//                        string: "https://www.amazon.com/Acme-Novelty-Library-Chris-Ware/dp/1770460209/ref=mp_s_a_1_1?ie=UTF8&qid=1534241076&sr=8-1&pi=AC_SX236_SY340_QL65&keywords=Chris+ware+lint&dpPl=1&dpID=51vA%2By-Oj-L&ref=plSrch")!),
//                 title: "Lint")
//        )
        
        
        all.append(
            Book(width: 7,
                 depth: 1,
                 height: 5,
                 url: BookUrl(
                    site: "Amazon",
                    url: URL(
                        string: "https://www.amazon.com/Pyongyang-Journey-North-Korea-ebook/dp/B0763SD6FP/ref=mp_s_a_1_1?ie=UTF8&qid=1534241100&sr=8-1&pi=AC_SX236_SY340_QL65&keywords=delisle+pyongyang&dpPl=1&dpID=61eypc5HDmL&ref=plSrch")!),
                 title: "Korea")
        )
        
        
        for (name, url) in secondBatch {
            let u = BookUrl(site: "Amazon", url: URL(string: url)!)
            all.append(Book(width: 0, depth: 0, height: 0, url: u, title: name))
        }

        
        
        
    }
    
    func findBook(by title:String) -> Book {
        var foundBook = Book(width: 0, depth: 0, height: 0, url: BookUrl(site: "Google", url: URL(string: "http://google.com")!), title: "Google")
        
        for book in all {
            if book.title == title { foundBook = book  }
        }
        return foundBook
    }
}
