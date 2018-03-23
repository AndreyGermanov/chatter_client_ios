//
//  MessageCenterTests.swift
//  chatter_client_iosTests
//
//  Created by user on 22.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import XCTest
@testable import CryptoSwift
@testable import chatter_client_ios

class MessageCenterTests: XCTestCase {
    
    var messageCenter: MessageCenter = MessageCenter()
    var lastWebSocketResponse: [String:Any]? = nil
    lazy var expect: XCTestExpectation = XCTestExpectation()
    
    override func setUp() {
        super.setUp()
        messageCenter = MessageCenter.init(host:"192.168.0.184",port:8080,endpoint:"websocket")
        messageCenter.pendingRequests.removeAll()
        messageCenter.requestsWaitingResponses.removeAll()
        messageCenter.receivedFiles.removeAll()
        messageCenter.responsesWaitingFile.removeAll()
        self.lastWebSocketResponse = nil
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddToPendingRequests() {
        var request:[String:Any] = ["test":"boo"]
        var result:[String:Any]? = messageCenter.addToPendingRequests(request)
        XCTAssertNil(result, "Should return nil if add request without 'sender'")
        XCTAssertEqual(0, messageCenter.pendingRequests.count, "Should not add request without sender")
        request["sender"] = Date()
        result = messageCenter.addToPendingRequests(request)
        XCTAssertNil(result, "Should return nil if add request with incorrect sender")
        request["sender"] = self
        result = messageCenter.addToPendingRequests(request)
        XCTAssertTrue(result!["request_id"] is String,"Should return generated request_id as string after adding request to queue")
        XCTAssertTrue(result!["request_timestamp"] is Int,"Should return generated timestamp as Int after adding request to queue")
        XCTAssertEqual(1,messageCenter.pendingRequests.count,"Should add request to pendingRequests queue")
        XCTAssertNotNil(messageCenter.pendingRequests[result!["request_id"] as! String],
                        "Request should be added with request_id key to pendingRequests queue")
    }
    
    func testSendRequestToServerWithFailure() {
        self.messageCenter.connect()
        sleep(2)
        self.messageCenter.run()
        sleep(1)
        let request:[String:Any] = ["sender":self,"action":"register_user"]
        var result = messageCenter.addToPendingRequests(request)
        wait(for: [self.expect],timeout:5)
        XCTAssertEqual(self.lastWebSocketResponse!["request_id"]! as! String,result!["request_id"]! as! String,
                       "Response should contain the same request_id as sent request")
        XCTAssertNotNil(self.lastWebSocketResponse!["request"]!,"Should contain original request inside response")
    }
    
    
}
