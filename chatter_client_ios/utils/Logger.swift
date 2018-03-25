//
//  Logger.swift
//  chatter_client_ios
//
//  Created by user on 21.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation

/**
 * Class used to produce Log messages either on screen or in file, depending on used adapter
 */
class Logger {
    
    /// Which log levels to display
    static var displayLevels: [LogLevel] = [LogLevel.INFO,LogLevel.ERROR,LogLevel.WARNING,LogLevel.DEBUG,LogLevel.DEBUG_REDUX]
    
    /**
     * Function used to log message
     *
     * - Parameter level: Log level
     * - Parameter message: Message to log
     * - Parameter className: Which class produced this log message
     * - Parameter methodName: Which method of class produced this log message
     */
    static func log(level:LogLevel=LogLevel.INFO,message:String,className:String="",methodName:String="") {
        if message.count == 0 || !displayLevels.contains(level) {
            return
        }
        var result = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: Date())
        result  += dateString+" - "+level.rawValue+": "+message
        if className.count > 0 {
            result  += ","+className
        }
        if methodName.count > 0 {
            result += ","+methodName
        }
        print(result)
    }
}

/// Log levels for Logger
enum LogLevel:String {
    case WARNING = "WARNING"
    case INFO = "INFO"
    case ERROR = "ERROR"
    case DEBUG = "DEBUG"
    case DEBUG_REDUX = "DEBUG_REDUX"
}
