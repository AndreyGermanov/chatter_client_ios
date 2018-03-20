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
 *   Wrapper of Web Socket client with queue support. When client want to send
 *   message to server, it puts this message to queue. Each message must have unique "request_id"
 *   field and "sender" with link to object-receiver.
 *
 *   Service then sends messages from queue and awaiting for responses. When receive response,
 *   it find request by request_id and executes function "handleWebSocketResponse" of "sender" object.
 *   So, sender object must implement "MessageCenterResponseListener" protocol.
 */
class MessageCenter: NSObject, WebSocketDelegate {
    
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
    
    /// Timer used to run main message loop (process message queues)
    lazy var timer: Timer = Timer()

    /******************
     *  Message Queues
     *****************/
    
    /// Pending requests queue
    var pendingRequests = [String:Any]()
    
    /// Time period in seconds, after wchich request in queue outdates and becaeme as subject
    /// of garbage collector (seconds)
    var pendingRequestsQueueTimeout = 10
    
    /// Sent requests queue, which wait for response
    var requetsWaitingResponses = [String:Any]()
    
    /// Time period in seconds, after wchich request in queue outdates and becaeme as subject
    /// of garbage collector (seconds)
    var requestsWaitingResponsesQueueTimeout = 20
    
    /// Received files queue [checksum:binary-data-of-file]
    var receivedFilesQueue = [Int:Data]()
    
    /// Time period in seconds, after wchich request in queue outdates and becaeme as subject
    /// of garbage collector (seconds)
    var receivedFilesQueueTimeout = 120

    /**
     * Class constructor
     *
     * - Parameter host: WebSocket server host
     * - Parameter port: WebSocket server port
     * - Parameter endpoint: WebSocket server endpoint URL
     */
    init(host:String="localhost",port:Int=80,endpoint:String = "") {
        self.host = host
        self.port = port
        self.endpoint = endpoint
    }
    
    /***************************
     * WebSocket event handlers
     **************************/
    
    /**
     * Executes when connection to server established
     *
     * - Parameter socket: WebSocket server connection instance
     */
    func websocketDidConnect(socket: WebSocketClient) {
        self.remoteSession = socket
    }
    
    /**
     * Executes when connection to server closed
     *
     * - Parameter socket: WebSocket server connection instance
     * - Parameter error: Error, if disconnected due to error
     */
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if (!self.testingMode) {
            ws = WebSocket(url:URL(string:"ws://\(self.host):\(self.port)/\(self.endpoint)")!)
            ws.connect()
        }
    }
    
    /**
     * Executes when Message center receives text message from server. Accepts only messages in JSON format
     *
     * - Parameter socket: WebSocket server connection instance
     * - Parameter text: Received message
     */
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    /**
     * Executes when Message center receives binary file from server
     *
     * - Parameter socket: WebSocket server connection instance
     * - Parameter data: Binary data
     */
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        receivedFilesQueue[data.hashValue] = data
    }
}

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
    func handleWebSocketResponse(request_id:String, response:[String:Any]) -> Unit
 }
