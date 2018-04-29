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
class Model: Equatable {

    /// UUID of model
    var id: String

    /**
     * Class constructor
     *
     * - Parameter id: UUID of model
     */
    init(id: String) {
        self.id = id.isEmpty ? UUID().uuidString : id
    }

    /**
     * Method returns model from collection of type "T" by it ID
     *
     * - Parameter id: ID to find
     * - Parameter collection: Link to collection of models (array of models) to return item from
     * - Returns found model or nil, if nothing found
     */
    static func getModelById<T: Model>(id: String, collection: [T]?) -> T? {
        if collection == nil {
            Logger.log(level: LogLevel.WARNING, message: "Nil sent as a collection",
                       className: "Model", methodName: "getModelById")
            return nil
        }
        let models = collection!.filter { $0.id == id }
        return models.count > 0 ? models[0] : nil
    }

    /**
     * Method used to create and return copy of model
     *
     * - Returns: copy of current model
     */
    func copy() -> Model {
        return Model(id: id)
    }

    /**
     * Method converts object to HashMap
     *
     * - Returns: Dictionary with object properties
     */
    func toHashMap() -> [String: Any] {
        return ["id": self.id]
    }

    /**
     * Method which compares this model to model "obj".
     * It compares all fields of models except fields of type "Model".
     * Descendants should implement their own way of comparing these
     * kind of fields
     *
     * - Parameter obj: Object to compare
     * - Returns: true if models are equal and false otherwise
     */
    func equals<T: Model>(_ obj: T?) -> Bool {
        guard let model = obj else {
            return false
        }
        var result = true
        var selfMap = self.toHashMap()
        var modelMap = model.toHashMap()
        for (index, selfItem) in selfMap {
            if selfItem is Model {
                selfMap.removeValue(forKey: index)
            }
        }
        for (index, modelItem) in modelMap {
            if modelItem is Model {
                modelMap.removeValue(forKey: index)
            }
        }
        if selfMap.count != modelMap.count {
            result = false
        }
        return result && selfMap.isEqual(modelMap)
    }

    /**
     * Method which compares model1 to model2
     *
     * - Parameter model1: First model to compare
     * - Parameter model2: Second model to compare
     * - Returns: true if models are equal and false otherwise
     */
    static func compare<T: Model>(model1: T?, model2: T?) -> Bool {
        var result = true
        if model1 != nil {
            switch model1 {
            case is ChatMessage: result = (model1 as! ChatMessage).equals(model2 as? ChatMessage)
            case is ChatUser: result = (model1 as! ChatUser).equals(model2 as? ChatUser)
            case is ChatRoom: result = (model1 as! ChatRoom).equals(model2 as? ChatRoom)
            default: result = false
            }
        } else if model2 != nil {
            result = false
        }
        return result
    }

    /**
     * Method compares 2 collections of models and return true
     * if they are equal and have the same order of items. Otherwise false
     * returned
     *
     * - Parameter models1: First collection
     * - Parameter models2: Second collection
     * - Returns: True if collections are equal or false otherwise
     */
    static func compare<T: Model>(models1: [T]?, models2: [T]?) -> Bool {
        var result = true
        if (models1 == nil && models2 != nil) || (models2 == nil && models1 != nil) {
            return false
        }
        if models1 == nil && models2 == nil {
            return true
        }
        if models1!.count != models2!.count {
            return false
        }
        for i in 0...models1!.count-1 {
            let model1 = models1![i]
            if let model2 = models2?[i] {
                switch model1 {
                case is ChatMessage: result = result && (model1 as! ChatMessage).equals(model2 as? ChatMessage)
                case is ChatUser: result = result && (model1 as! ChatUser).equals(model2 as? ChatUser)
                case is ChatRoom: result = result && (model1 as! ChatRoom).equals(model2 as? ChatRoom)
                default: result = false
                }
            } else {
                return false
            }
        }
        return result
    }

    /**
     * Operator tests two values of this type to equality
     *
     * - Parameter lhs: Left side of == operator
     * - Parameter rhs: Right side of == operator
     * - Returns: true if equal and false otherwise
     */
    static func ==(lhs: Model, rhs: Model) -> Bool {
        return lhs.equals(rhs)
    }
}

/**
 * Extension functions for HashMaps
 */
extension Dictionary {
    /**
     * Operator used to compare two Dictionaries of type [String:Any]
     *
     * - Parameter dict: Dictionary to compare
     * - Returns: true if dict is equal to self and false otherwise
     */
    public func isEqual(_ dict: [String: Any]) -> Bool {
        return NSDictionary(dictionary: dict).isEqual(to: self)
    }
}

/**
 * Extension functions for Arrays
 */
extension Array {
    /**
     *  Method used to copy array of models
     *  to new array of models
     */
    func copy<T: Model>() -> [T] {
        var result = [T]()
        self.forEach { el in
            let model = el as! T
            result.append(model.copy() as! T)
        }
        return result
    }
}
