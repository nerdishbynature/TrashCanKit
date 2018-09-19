//
//  Page.swift
//  TrashCanKit
//
//  Created by Piet Brauer on 13.09.18.
//  Copyright © 2018 nerdishbynature. All rights reserved.
//

import Foundation

open class Page<T: Codable>: NSObject, Codable {
    open var next: URL?
    open var page: Int = 0
    open var pageLength: Int = 0
    open var values: [T] = []

    private enum CodingKeys: String, CodingKey {
        case next
        case page
        case pageLength = "pagelen"
        case values
    }

    public override init() {
        super.init()
    }
}
