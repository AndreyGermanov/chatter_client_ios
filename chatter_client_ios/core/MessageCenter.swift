//
//  MessageCenter.swift
//  chatter_client_ios
//
//  Service, used to communicate with WebSocket server: send commands and receive responses
//
//  Created by user on 20.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit
import Starscream

/**
 *   Wrapper of Web Socket client with queue support. When client wants to send
 *   message to server, it puts this message to queue. Each message must have unique "request_id"
 *   field and "sender" with link to object-receiver.
 *
 *   Service then sends messages from queue and awaiting for responses. When receive response,
 *   it find request by request_id and executes function "handleWebSocketResponse" of "sender" object.
 *   So, sender object must implement "MessageCenterResponseListener" protocol.
 */
class MessageCenter: NSObject, WebSocketDelegate {
    
    //MARK: Variables
    
    /*****************************
     * WebSocket server core vars
     ****************************/
    
    /// If message center works in testing mode, it will not create actual connection to server
    /// (Used for unit testing)
    var testingMode = false;
    
    /// WebSocket Server endpoint host
    var host = "localhost"
    
    /// WebSocket Server endpoint port
    var port = 80
    
    /// WebSocket Server endpoint path
    var endpoint = "/websocket"
    
    /// Link to WebSocket connection instance
    lazy  var ws: WebSocket = WebSocket(url:URL(string:"ws://localhost:80/websocket")!)
    
    /// Remote WebSocket endpoint instance
    var remoteSession: WebSocketClient?
    
    /// Last response from WebSocket server as text
    var lastResponseText = ""
    
    /// Last response from WebSocket server as object
    var lastResponseObject: [String:Any]? = nil
    
    /// Last request sent to WebSocket server as string
    var lastRequestText = ""
    
    /// Last received data block (or file) from WebSocket server
    var lastReceivedFile = Data()
    
    /// Timer used to run main message loop (process message queues)
    lazy var timer: Timer = Timer()

    /**************************
     * Message queue core vars
     *************************/
    
    /// Pending requests queue
    var pendingRequests = [String:Any]()
    
    /// Time period in seconds, after wchich request in queue outdates and becaeme as subject
    /// of garbage collector (seconds)
    var pendingRequestsQueueTimeout = 10
    
    /// Sent requests queue, which wait for response
    var requestsWaitingResponses = [String:Any]()
    
    /// Time period in seconds, after wchich request in queue outdates and becaeme as subject
    /// of garbage collector (seconds)
    var requestsWaitingResponsesQueueTimeout = 20
    
    /// Received files queue [checksum:[data:binary-data-of-file,timestamp:timestamp]
    var receivedFiles = [Int:Any]()
    
    /// Time period in seconds, after wchich request in queue outdates and becaeme as subject
    /// of garbage collector (seconds)
    var receivedFilesQueueTimeout = 120
    
    /// Pending waiting files requests queue. Responses for requests, which is waiting binary data
    /// to come to be finished
    var responsesWaitingFile = [Int:Any]()
    
    /// Time period in seconds, after wchich request in queue outdates and becaeme as subject
    /// of garbage collector (seconds)
    var responseWaitingFileQueueTimeout = 120
    
    //MARK: Core methods

    /***************************
     * Message center main loop
     **************************/
    
    /**
     * Class constructor
     *
     * - Parameter host: WebSocket server host
     * - Parameter port: WebSocket server port
     * - Parameter endpoint: WebSocket server endpoint URL
     */
    init(host:String="localhost",port:Int=80,endpoint:String = "") {
        super.init()
        self.host = host
        self.port = port
        self.endpoint = endpoint
    }
    
    /**
     * Message center starter
     */    
    @objc func run() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runCronjob), userInfo: nil, repeats: true)
    }
    
    /**
     * Function determines server connection status
     *
     * - Returns: true if connection active and false otherwise
     */
    func isConnected() -> Bool {
        return self.ws.isConnected
    }
    
    /**
     * Function used to connect to WebSocket server
     */
    func connect() {
        self.ws = WebSocket(url:URL(string:"ws://\(self.host):\(self.port)/\(self.endpoint)")!)
        self.ws.delegate = self
        self.ws.connect()
    }
    
    /**
     * Function runs every second and processes message queues
     */
    @objc func runCronjob() {
        if (!self.isConnected() && !self.testingMode) {
            self.connect()
        }
        self.processPendingRequests()
        self.cleanPendingRequests()
        self.cleanRequestsWaitingResponses()
        self.cleanReceivedFiles()
        self.cleanResponsesWaitingFile()
    }
    
    //MARK: Message queue management
    
    /***************************
     * Message queue management
     **************************/
    
    /**
     * Adds request to pendingRequests queue
     *
     * - Parameter request: Request
     * - Returns: request_id of added request
     */
    func addToPendingRequests(_ request:[String:Any]) -> [String:Any]? {
        var request = request
        if (request["sender"] == nil) {
            Logger.log(level:LogLevel.WARNING,message:"Could not add request to queue. No 'sender' object specified",
                       className:"MessageCenter",methodName:"addToPendingRequests")
            return nil
        } else if (!(request["sender"] is MessageCenterResponseListener)) {
            Logger.log(level:LogLevel.WARNING,message:"Could not add request to queue. Specified 'sender' object specified is incorrect",
                       className:"MessageCenter",methodName:"addToPendingRequests")
            return nil
        }
        var request_id = UUID().uuidString
        if request["request_id"] != nil {
            request_id = request["request_id"] as! String
        } else {
            request["request_id"] = request_id
        }
        let request_timestamp:Int = Int.init(NSDate().timeIntervalSince1970)
        if (request["request_timestamp"] != nil) {
            Logger.log(level:LogLevel.ERROR,message:"'request_timestamp' attribute already exists. Could not add this request.",
                       className:"MessageCenter",methodName:"addToPendingRequests")
            return nil
        } else {
            request["request_timestamp"] = request_timestamp
            self.pendingRequests[request_id] = request
            return request
        }
    }
    
    /**
     * Removes request from pendingRequests queue
     *
     * - Parameter request_id: request ID to remove
     * - Returns: removed request body if it really removed or nil if nothing removed
     */
    func removeFromPendingRequests(_ request_id:String) -> Any? {
        if let request = self.pendingRequests[request_id] {
            self.pendingRequests.removeValue(forKey: request_id)
            return request
        } else {
            return nil
        }
    }
    
    /**
     * Used to send all requests from pendingRequests queue to the server
     * and put them to requetsWaitingResponsesQueue queue
     */
    func processPendingRequests() {
        for (request_id,request) in self.pendingRequests {
            if let request = request as? [String:Any] {
                if let sender = request["sender"] as? MessageCenterResponseListener {
                    var message_to_send = [String:Any]()
                    var files_to_send = [Data]()
                    for (field_index,field) in request {
                        if (field_index != "sender") {
                            if (field is Data) {
                                files_to_send.append(field as! Data)
                            } else {
                                message_to_send[field_index] = field
                            }
                        }
                    }
                    var failed_to_send_message = false
                    if message_to_send.count>0 {
                        do {
                            self.lastRequestText = (try String(data:JSONSerialization.data(withJSONObject: message_to_send, options: .sortedKeys),encoding: .utf8))!
                            if self.isConnected() && !self.testingMode {
                                self.ws.write(string:self.lastRequestText)
                                Logger.log(level:LogLevel.DEBUG,message:"Sent request to WebSocketServer - "+self.lastRequestText,
                                           className:"MessageCenter",methodName:"processPendingRequests")
                            }
                        } catch {
                            Logger.log(level:LogLevel.WARNING,message:"Failed to send message. Failed to construct JSON from message",
                                       className:"MessageCenter",methodName:"processPendingRequests")
                            sender.handleWebSocketResponse(request_id: request_id, response: [
                                "status": "error",
                                "status_code": MessageCenterErrorCodes.RESULT_ERROR_REQUEST_PARSE_ERROR,
                                "request": request
                            ])
                            failed_to_send_message = true
                        }
                    }
                    if (files_to_send.count>0 && !failed_to_send_message) {
                        if (self.isConnected() && !self.testingMode) {
                            for binary in files_to_send {
                                self.ws.write(data: binary)
                            }
                        }
                    }
                    if (!failed_to_send_message) {
                        _ = self.addToRequestsWaitingResponses(request)
                        _ = self.removeFromPendingRequests(request_id)
                    } else {
                        Logger.log(level:LogLevel.WARNING,message:"Failed to send message. Message is empty",
                                   className:"MessageCenter",methodName:"processPendingRequests")
                    }
                }
            }
        }
    }

    /**
     * Cleans outdated records from pendingRequests queue, based on 'request_timestamp' attribute
     */
    func cleanPendingRequests() {
        for (request_id,request) in self.pendingRequests {
            if let request = request as? [String:Any] {
                if let timestamp = request["request_timestamp"] as? Int {
                    if Int.init(NSDate().timeIntervalSince1970) - timestamp >= self.pendingRequestsQueueTimeout {
                        _ = self.removeFromPendingRequests(request_id)
                    }
                } else {
                    _ = self.removeFromPendingRequests(request_id)
                }
            } else {
                _ = self.removeFromPendingRequests(request_id)
            }
        }
    }
    
    /**
     * Adds request to requestsWaitingResponsesQueue
     *
     * - Parameter request: Request
     * - Returns: request_id or empty string if impossible to add request to queue
     */
    func addToRequestsWaitingResponses(_ request:[String:Any]) -> String {
        var request = request
        if let request_id = request["request_id"] as? String {
            let request_timestamp:Int = Int.init(NSDate().timeIntervalSince1970)
            request["request_timestamp"] = request_timestamp
            self.requestsWaitingResponses[request_id] = request
            return request_id
        } else {
            return ""
        }
    }
    
    /**
     * Removes request from requestsWaitingResponses
     *
     * - Parameter: request_id: Request ID to remove or nil of nothing removed
     * - Returns: body of removed request
     */
    func removeFromRequestsWaitingResponses(_ request_id: String) -> [String:Any]? {
        if let request = self.requestsWaitingResponses[request_id] as? [String:Any] {
            self.requestsWaitingResponses.removeValue(forKey: request_id)
            return request
        } else {
            return nil
        }
    }
    
    /**
     * Removes outdated records from requestsWaitingResponses queue
     */
    func cleanRequestsWaitingResponses() {
        for (request_id,request) in self.requestsWaitingResponses {
            if let request = request as? [String:Any] {
                if let timestamp = request["request_timestamp"] as? Int {
                    if (Int.init(NSDate().timeIntervalSince1970)-timestamp >= self.requestsWaitingResponsesQueueTimeout) {
                        _ = self.removeFromRequestsWaitingResponses(request_id)
                    }
                } else {
                    _ = self.removeFromRequestsWaitingResponses(request_id)
                }
            } else {
                _ = self.removeFromRequestsWaitingResponses(request_id)
            }
        }
    }
    
    /**
     * Adds record to receivedFiles queue, keyed by checksum of file and marked by timestamp of
     * a moment when file was added
     *
     * - Parameter data: Binary data of file
     * - Returns: added record
     */
    func addToReceivedFiles(_ data: Data) -> [String:Any] {
        let checksum = Int(Adler32.crc(data:[UInt8](data)))
        let timestamp = Int.init(NSDate().timeIntervalSince1970)
        let record:[String:Any] = ["data":data,"timestamp":timestamp]
        self.receivedFiles[checksum] = record
        return record
    }
    
    /**
     * Removes record from receivedFiles queue
     *
     * - Parameter checksum: Checksum of file to remove
     * - Returns: record of removed file or nil if no record removed
     */
    func removeFromReceivedFiles(_ checksum:Int) -> [String:Any]? {
        if let record = self.receivedFiles[checksum] as? [String:Any] {
            self.receivedFiles.removeValue(forKey: checksum)
            return record
        } else {
            return nil
        }
    }
    
    /**
     * Removes outdated files from receivedFiles queue
     */
    func cleanReceivedFiles() {
        for (checksum,_) in self.receivedFiles {
            if let record = self.receivedFiles[checksum] as? [String:Any] {
                if let timestamp = record["timestamp"] as? Int {
                    if Int.init(NSDate().timeIntervalSince1970)-timestamp>=self.receivedFilesQueueTimeout {
                        _ = self.removeFromReceivedFiles(checksum)
                    }
                } else {
                    _ = self.removeFromReceivedFiles(checksum)
                }
            } else {
                _ = self.removeFromReceivedFiles(checksum)
            }
        }
    }
    
    /**
     * Function adds record to responsesWaitingFile queue
     *
     * - Parameter checksum: Checksum of file, which response is wating
     * - Parameter response: Body of response, which is waiting this file
     * - Returns: added record
     */
    func addToResponsesWaitingFile(checksum:Int,response:[String:Any]) -> [String:Any] {
        let timestamp = Int.init(NSDate().timeIntervalSince1970)
        let record:[String:Any] = ["response":response,"timestamp":timestamp]
        self.responsesWaitingFile[checksum] = record
        return record
    }
    
    /**
     * Function removes record from responsesWaitingFile queue
     *
     * - Parameter checksum: Checksum of record to remove
     * - Returns: removed record or nil if nothing removed
     */
    func removeFromResponsesWaitingFile(_ checksum:Int) -> [String:Any]? {
        if let record = self.responsesWaitingFile[checksum] as? [String:Any] {
            self.responsesWaitingFile.removeValue(forKey: checksum)
            return record
        } else {
            return nil
        }
    }
    
    /**
     * Function removes outdated records from responsesWaitingFile queue
     */
    func cleanResponsesWaitingFile() {
        for (checksum,_) in self.responsesWaitingFile {
            if let record = self.responsesWaitingFile[checksum] as? [String:Any] {
                if let timestamp = record["timestamp"] as? Int {
                    if Int.init(NSDate().timeIntervalSince1970)-timestamp>=self.receivedFilesQueueTimeout {
                        _ = self.removeFromResponsesWaitingFile(checksum)
                    }
                } else {
                    _ = self.removeFromResponsesWaitingFile(checksum)
                }
            } else {
                _ = self.removeFromResponsesWaitingFile(checksum)
            }
        }
    }
    
    //MARK: WebSocket event handlers

    /***************************
     * WebSocket event handlers
     **************************/
    
    /**
     * Executes when connection to server established
     *
     * - Parameter socket: WebSocket server connection instance
     */
    func websocketDidConnect(socket: WebSocketClient) {
        Logger.log(level:LogLevel.DEBUG,message:"Connected to WebSocket server",className:"MessageCenter",methodName:"websocketDidConnect")
        self.remoteSession = socket
    }
    
    /**
     * Executes when connection to server closed
     *
     * - Parameter socket: WebSocket server connection instance
     * - Parameter error: Error, if disconnected due to error
     */
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        Logger.log(level:LogLevel.DEBUG,message:"Disconnected from WebSocket server",className:"MessageCenter",methodName:"websocketDidConnect")
        if error != nil {
            Logger.log(level:LogLevel.ERROR,message:error.debugDescription,
                       className:"MessageCenter",methodName:"websocketDidDisconnect")
        }
    }
    
    /**
     * Executes when Message center receives text message from server. Accepts only messages in JSON format
     *
     * - Parameter socket: WebSocket server connection instance
     * - Parameter text: Received message
     */
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        self.lastResponseText = text
        if (text.count>0) {
            Logger.log(level:LogLevel.DEBUG,message:"Received response from WebSocketServer "+self.lastResponseText,
                       className:"MessageCenter",methodName:"websocketDidReceiveMessage")
            do {
                let result = try JSONSerialization.jsonObject(with: text.data(using: .utf8)!,
                                                              options: JSONSerialization.ReadingOptions.mutableContainers)
                if var response = result as? [String:Any] {
                    self.lastResponseObject = response
                    if response["request_id"] != nil {
                        let request_id = response["request_id"] as! String
                        if let request = self.requestsWaitingResponses[request_id] as? [String:Any] {
                            response["request"] = request
                            if let sender = request["sender"] as? MessageCenterResponseListener {
                                sender.handleWebSocketResponse(request_id: request_id, response: response)
                            } else {
                                Logger.log(level:LogLevel.WARNING,message:"Response with request_id \(request_id) does not have correct correct handler -"+self.lastResponseText,
                                           className:"MessageCenter",methodName:"websocketDidReceiveMessage")
                            }
                        } else {
                            Logger.log(level:LogLevel.WARNING,message:"Response with request_id \(request_id) not found in waiting requests queue -"+self.lastResponseText,
                                       className:"MessageCenter",methodName:"websocketDidReceiveMessage")
                        }
                    } else {
                        Logger.log(level:LogLevel.WARNING,message:"No request_id in received JSON response - "+self.lastResponseText,
                                   className:"MessageCenter", methodName:"websocketDidReceiveMessage")
                    }
                } else {
                    self.lastResponseObject = nil
                    Logger.log(level:LogLevel.WARNING,message:"Incorrect JSON in last response received - "+self.lastResponseText,
                               className:"MessageCenter", methodName:"websocketDidReceiveMessage")
                }
            } catch {
                Logger.log(level:LogLevel.WARNING,message:"Incorrect JSON in last response received - "+self.lastResponseText,
                           className:"MessageCenter", methodName:"websocketDidReceiveMessage")
            }
        } else {
            Logger.log(level:LogLevel.WARNING,message:"Empty WebSocket response received",
                       className:"MessageCenter", methodName:"websocketDidReceiveMessage")
        }
    }
    
    /**
     * Executes when Message center receives binary file from server
     *
     * - Parameter socket: WebSocket server connection instance
     * - Parameter data: Binary data
     */
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        let checksum = Int(Adler32.crc(data:[UInt8](data)))
        _ = self.addToReceivedFiles(data)
        Logger.log(level:LogLevel.DEBUG,message:"Received binary data with checksum \(checksum)",
            className:"MessageCenter",methodName:"websocketDidReceiveData")
        if let response = self.responsesWaitingFile[checksum] as? [String:Any] {
            if let request = response["request"] as? [String:Any] {
                if (request["request_id"] != nil) {
                    let request_id = String(describing:request["request_id"])
                    if let sender = request["sender"] as? MessageCenterResponseListener {
                        sender.handleWebSocketResponse(request_id: request_id, response: response)
                    } else {
                        Logger.log(level:LogLevel.WARNING,message:"Response with \(request_id) does not have correct handler",
                            className:"MessageCenter",methodName:"websocketDidReceiveData")
                    }
                } else {
                    Logger.log(level:LogLevel.WARNING,message:"Response for file \(checksum) does not have correct request_id",
                        className:"MessageCenter",methodName:"websocketDidReceiveData")
                }
            } else {
                Logger.log(level:LogLevel.WARNING,message:"Could not find link to request for file \(checksum)",
                    className:"MessageCenter",methodName:"websocketDidReceiveData")
            }
        }
    }
}

//MARK: MessageCenter Listener protocol

/**
 * Any object, which want to send messages and receive responses from MessageCenter
 * must implement this protocol
 */
protocol MessageCenterResponseListener {
    
    /// Link to MessageCenter
    var messageCenter: MessageCenter {get set}

    /**
     * MessageCenter call this function of object, when receive response to
     * request from WebSocket server
     *
     * - Parameter request_id: Request id
     * - Parameter response: Decoded from JSON response as a Dictionary
     */
    func handleWebSocketResponse(request_id:String, response:[String:Any])
    
}

//MARK: Utility enums

/**
 *  Message Center errors definitions
 */
enum MessageCenterErrorCodes:String {
    case RESULT_ERROR_REQUEST_PARSE_ERROR = "Could not encode request to send to server"
}
