//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2021 Svyatoslav Popov (info@keyvar.com).
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
//  the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//
//  SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//
//  KvBonjourServer.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 11.01.2021.
//

#if canImport(Darwin)

import Foundation



// MARK: - KvBonjourServerDelegate

public protocol KvBonjourServerDelegate : AnyObject {

    func bonjourServer(_ server: KvBonjour.Server, didAccept client: KvBonjour.Client)

}



// MARK: - .Server

extension KvBonjour {

    open class Server : NSObject {

        public let serviceInfo: ServiceInfo


        public weak var delegate: KvBonjourServerDelegate?



        public init(with serviceInfo: ServiceInfo) {
            self.serviceInfo = serviceInfo

            netService = .init(domain: serviceInfo.domain, type: serviceInfo.name, name: "", port: 0)
            netService.includesPeerToPeer = serviceInfo.options.contains(.includesPeerToPeer)

            super.init()

            netService.delegate = self
        }



        deinit {
            stop()
        }



        private let netService: NetService



        // MARK: Start/Stop

        public func start() { netService.publish(options: .listenForConnections) }



        public func stop() { netService.stop() }

    }

}



// MARK: : NetServiceDelegate

extension KvBonjour.Server : NetServiceDelegate {

    public func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        let client = KvBonjour.Client(input: inputStream, output: outputStream)

        delegate?.bonjourServer(self, didAccept: client)
    }



    public func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        guard sender == netService else {
            return print("Internal inconsistency: unexpected network service \(sender)")
        }

        print("Error: unable to publist a network service")
    }

}

#endif // canImport(Darwin)
