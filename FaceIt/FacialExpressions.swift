//
//  FacialExpressions.swift
//  FaceIt
//
//  Created by user on 3/7/18.
//  Copyright © 2018 Varfolomeew. All rights reserved.
//

import Foundation

//UI-independent representation of a facial expression

struct FacialExpression
{
    enum Eyes: Int {
        case open
        case closed
        case squinting                  //косящиеся 
    }
    
    enum Mouth: Int {
        case frown                      //хмурый
        case smirk                      //ухмылка
        case neutral                    //нейтральный
        case grin                       //усмешка
        case smile                      //улыбка
        
        var sadder: Mouth {
            return Mouth(rawValue: rawValue - 1) ?? .frown
        }
        var happier: Mouth {
            return Mouth(rawValue: rawValue + 1) ?? .smile
        }
    }
    
    var sadder: FacialExpression {
        return FacialExpression(eyes: self.eyes, mouth: self.mouth.sadder)
    }
    var happier: FacialExpression {
        return FacialExpression(eyes: self.eyes, mouth: self.mouth.happier)
    }
    
    let eyes: Eyes      
    let mouth: Mouth
}
