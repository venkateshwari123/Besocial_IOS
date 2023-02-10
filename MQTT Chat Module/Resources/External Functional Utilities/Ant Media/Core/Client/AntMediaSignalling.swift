//
//  AntMediaSignalling.swift
//  AntMediaSDK
//
//  Created by Oğulcan on 27.05.2018.
//  Copyright © 2018 AntMedia. All rights reserved.
//

import Foundation

class AntMediaSignalling {
    
    private let mode: AntMediaClientMode!
    private let stream: String!
    private let token: String!
    
    private let COMMAND: String = "command"
    private let STREAM_ID: String = "streamId"
    private let TOKEN_ID: String = "token"

    public init(mode: AntMediaClientMode, stream: String, token: String = "") {
        self.mode = mode
        self.stream = stream
        self.token = token
    }
    
    func getHandshakeMessage() -> [String: String] {
        if (token.isEmpty) {
            return [COMMAND: mode.getName(), STREAM_ID: stream]
        } else {
            return [COMMAND: mode.getName(), STREAM_ID: stream, TOKEN_ID: token]
        }
    }

    func getLeaveMessage() -> [String: String] {
        return [COMMAND: mode.getLeaveMessage(), STREAM_ID: stream]
    }
}
