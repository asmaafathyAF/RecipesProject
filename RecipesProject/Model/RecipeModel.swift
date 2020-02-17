//
//  ProfessionModel.swift
//  CrystalRoseTask
//
//  Created by Tech Labs on 12/11/19.
//  Copyright © 2019 Tech Labs. All rights reserved.
//

import Foundation
struct RecipesModel: Codable{
    var recipe: Recipe
    struct Recipe: Codable {
        var image: String?
        var label:String?
        var source:String?
    }
    
}
