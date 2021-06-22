//
//  Color.swift
//  Feeder
//
//  Created by Aritro Paul on 6/21/21.
//

import Foundation

struct ColorValue: Codable {
    let color: String?
}

typealias Color = [String: ColorValue]
