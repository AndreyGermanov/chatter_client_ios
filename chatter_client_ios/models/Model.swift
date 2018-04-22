//
//  Model.swift
//  chatter_client_ios
//
//  Abstract definitions for models
//
//  Created by user on 22.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation

/**
 * Base class for all models
 */
class Model {
    
    /// UUID of model
    var id: String
    
    /**
     * Method returns model from collection of type "T" by it ID
     *
     * - Parameter id: ID to find
     * - Parameter collection: Link to collection of models (array of models) to return item from
     * - Returns found model or nil, if nothing found
     */
    static func getModelById<T:Model>(id:String,collection:[T]?) -> T? {
        if collection == nil {
            Logger.log(level:LogLevel.WARNING,message:"Nil sent as a collection",
                       className:"Model",methodName:"getModelById")
            return nil
        }
        let models = collection!.filter { $0.id == id }
        return models.count > 0 ? models[0] : nil
    }
    
    /**
     * Class constructor
     *
     * - Parameter id: UUID of model
     */
    init(id:String) {
        self.id = id.isEmpty ? UUID().uuidString : id
    }
}

