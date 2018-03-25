//
//  MessageCenterTests.swift
//  chatter_client_ios
//
//  Created by user on 23.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation

class MessageCenterTests: MessageCenterResponseListener {

    var messageCenter:MessageCenter
    var lastWebSocketResponse:[String:Any]?
    
    init(msgCenter:MessageCenter) {
        self.messageCenter = msgCenter
    }
    
    func testTransferImage() {
        self.messageCenter.connect()
        sleep(2)
        
            //let bundle = Bundle.main
            //let path = bundle.path(forResource: "apple", ofType: "png")!
            //let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path, isDirectory: false))
            let request:[String:Any] = [
                "sender": self,
                "action": "login_user",
                "login": "andrey",
                "password": "123"
            ]
            _ = self.messageCenter.addToPendingRequests(request)
            self.messageCenter.processPendingRequests()
            sleep(2)
            print(self.messageCenter.requestsWaitingResponses)
            sleep(10)
            if let response = self.lastWebSocketResponse {
                Logger.log(level:LogLevel.DEBUG,message:"Received final response \(response)",
                    className:"MessageCenterTests",methodName: "testTransferImage")
            }
       
    }
    
    func handleWebSocketResponse(request_id: String, response: [String : Any]) {
        self.lastWebSocketResponse = response
        let request_id = response["request_id"] as! String
        let status = response["status"] as! String
        if (status == "ok") {
            Logger.log(level:LogLevel.DEBUG,message:"Beginning to execute hander for request with id \(request_id). Request body: \(response)",
                className:"MessageCenterTests",methodName:"handleWebSocketResponse")
            if response["checksum"] != nil {
                let checksumNumber = response["checksum"] as! String
                let checksum = Int(checksumNumber)!
                if self.messageCenter.receivedFiles[checksum] != nil {
                    Logger.log(level:LogLevel.DEBUG,message:"Found file with checksum \(checksum) in receivedFiles",
                        className:"MessageCenterTests",methodName:"handleWebSocketResponse")
                    var record = self.messageCenter.receivedFiles[checksum] as! [String:Any]
                    self.lastWebSocketResponse!["profile_image"] = record["data"] as! Data
                    Logger.log(level:LogLevel.DEBUG,message:"Received final response \(self.lastWebSocketResponse!)",
                        className:"MessageCenterTests",methodName: "testTransferImage")
                    _ = self.messageCenter.removeFromReceivedFiles(checksum)
                } else {
                    Logger.log(level:LogLevel.DEBUG,message:"Not Found file with checksum \(checksum) in receivedFiles",
                        className:"MessageCenterTests",methodName:"handleWebSocketResponse")
                    _ = self.messageCenter.addToResponsesWaitingFile(checksum: checksum, response: response)
                    _ = self.messageCenter.removeFromPendingRequests(request_id)
                }
            } else {
                Logger.log(level:LogLevel.DEBUG,message:"Could not get checksum in response handler for request \(request_id)",
                    className:"MessageCenterTests",methodName:"handleWebSocketResponse")
            }
        }
    }
    
}
