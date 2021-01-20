//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2021 Svyatoslav Popov.
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
//  KvBonjourBrowser.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 11.01.2021.
//

import Foundation



// MARK: - KvBonjourBrowserDelegate

public protocol KvBonjourBrowserDelegate : class {

    func bonjourBrowserDidStart(_ browser: KvBonjour.Browser)
    func bonjourBrowserDidStop(_ browser: KvBonjour.Browser)

    func bonjourBrowser(_ browser: KvBonjour.Browser, didFind service: NetService)

}



// MARK: - .Browser

extension KvBonjour {

    open class Browser : NSObject {

        public let serviceInfo: ServiceInfo

        public weak var delegate: KvBonjourBrowserDelegate?



        public init(with serviceInfo: ServiceInfo) {
            self.serviceInfo = serviceInfo

            netServiceBrowser = .init()
            netServiceBrowser.includesPeerToPeer = serviceInfo.options.contains(.includesPeerToPeer)

            super.init()

            netServiceBrowser.delegate = self
        }



        deinit {
            netServiceBrowser.stop()
            netServiceBrowser.delegate = nil
        }



        private let netServiceBrowser: NetServiceBrowser



        // MARK: Start/Stop

        public func start() {
            netServiceBrowser.searchForServices(ofType: serviceInfo.name, inDomain: serviceInfo.domain)
        }



        public func stop() { netServiceBrowser.stop() }

    }

}



// MARK: : NetServiceBrowserDelegate

extension KvBonjour.Browser : NetServiceBrowserDelegate {

    public func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        //NSLog("netServiceBrowserWillSearch")

        delegate?.bonjourBrowserDidStart(self)
    }



    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        //NSLog("netServiceBrowserDidStopSearch")

        delegate?.bonjourBrowserDidStop(self)
    }



    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        guard browser == netServiceBrowser else {
            fatalError("Internal inconsistency: unexpected browser")
        }

        NSLog("New net service has been found: \(service)")

        delegate?.bonjourBrowser(self, didFind: service)
    }



    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        NSLog("Net service has been removed: \(service)")
    }



    public func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        guard browser == netServiceBrowser else {
            fatalError("Internal inconsistency: unexpected browser")
        }

        NSLog("Error: the net service browser did fail search")
    }



    public func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        //NSLog("didFindDomain: \(domainString)")
    }



    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        //NSLog("didRemoveDomain: \(domainString)")
    }

}
