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
//  KvBonjourClient.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 11.01.2021.
//

#if canImport(Darwin)

import Foundation



// MARK: - KvBonjourClientDelegate

public protocol KvBonjourClientDelegate : AnyObject {

    func bonjourClientDidStart(_ client: KvBonjour.Client)
    func bonjourClientDidStop(_ client: KvBonjour.Client)

    /// - note: Use `take()` to access received data.
    func bonjourClientDidReceiveData(_ client: KvBonjour.Client)

    func bonjourClient(_ client: KvBonjour.Client, didSend data: Data)

    func bonjourClient(_ client: KvBonjour.Client, didFailToSend data: Data)

}



// MARK: - KvBonjourClientStreamsDelegate

fileprivate protocol KvBonjourClientStreamsDelegate : AnyObject {

    func streamsDidStart(_ streams: KvBonjour.Client.Streams)
    func streamsDidStop(_ streams: KvBonjour.Client.Streams)

}



// MARK: - .Client

extension KvBonjour {

    open class Client : NSObject {

        public var delegate: KvBonjourClientDelegate? {
            get { mutationLock.withLock { _delegate } }
            set { mutationLock.withLock { _delegate = newValue } }
        }



        public static func resolving(service: NetService, timeout: TimeInterval = 10, completion: @escaping (Client?) -> Void) {
            guard service.addresses == nil || service.addresses!.count <= 0 else {
                return completion(Client(for: service))
            }


            class NetServiceResolver : NSObject, NetServiceDelegate {

                typealias Completion = (Result<NetService, Error>) -> Void



                static func run(for service: NetService, timeout: TimeInterval, completion: @escaping Completion) {
                    let resolver = NetServiceResolver(for: service)

                    resolver.run(timeout: timeout, completion: completion)
                }



                init(for service: NetService) {
                    self.service = service

                    super.init()

                    service.delegate = self
                }



                deinit {
                    service.delegate = nil
                }



                private let service: NetService

                private var completion: Completion?

                private var selfReference: NetServiceResolver?     ///< A strong reference to `self` preventing the release while the service is being resolved.



                func run(timeout: TimeInterval, completion: @escaping Completion) {
                    selfReference = self

                    self.completion = completion

                    service.resolve(withTimeout: timeout)
                }



                private func stop(with result: Result<NetService, Error>) {
                    completion?(result)
                    completion = nil

                    service.delegate = nil

                    selfReference = nil
                }



                // MARK: NetServiceDelegate Protocol

                func netServiceDidResolveAddress(_ sender: NetService) {
                    assert(sender == service)

                    stop(with: .success(service))
                }



                func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
                    assert(sender == service)

                    let firstErrorInfo = errorDict.first!
                    let error = NSError(domain: firstErrorInfo.key, code: firstErrorInfo.value.intValue, userInfo: nil)

                    stop(with: .failure(error))
                }

            }


            NetServiceResolver.run(for: service, timeout: timeout) { (result) in
                let client: Client?

                switch result {
                case .success(let service):
                    client = Client(for: service)

                case .failure(let error):
                    print("Net service resolving error: \(error)")

                    client = nil
                }

                completion(client)
            }
        }



        convenience private init?(for service: NetService) {
            guard let addressCount = service.addresses?.count, addressCount > 0 else {
                KvDebug.pause("Error: \(service) network service has no addresses. Probably it has not been resolved")
                return nil
            }

            guard let streams = Streams(for: service) else { return nil }

            self.init(with: streams)
        }



        convenience internal init(input inputStream: InputStream, output outputStream: OutputStream) {
            self.init(with: .init(input: inputStream, output: outputStream))
        }



        private init(with streams: Streams?) {
            self.streams = streams

            inputBuffer = .allocate(capacity: inputBufferLength)

            super.init()

            if let streams = streams {
                streams.delegate = self

                streams.inputStream.delegate = self
                streams.outputStream.delegate = self
            }


            //NSLog("[KvBonjour.Client \(ObjectIdentifier(self))] did init()")
        }



        deinit {
            //NSLog("[KvBonjour.Client \(ObjectIdentifier(self))] will deinit()")


            stop()

            streams = nil
            inputBuffer.deallocate()

            service = nil
        }



        private weak var _delegate: KvBonjourClientDelegate?


        private var streams: Streams? {
            didSet {
                //NSLog("[KvBonjour.Client \(ObjectIdentifier(self))] did change streams to \(KvStringKit.withObjectID(of: streams)) from \(KvStringKit.withObjectID(of: oldValue))")


                if streams == nil {
                    delegate?.bonjourClientDidStop(self)
                }
            }
        }


        private var service: NetService? {
            didSet { oldValue?.delegate = nil }
        }


        private let inputBufferLength = 64 << 10
        private let inputBuffer: UnsafeMutablePointer<UInt8>

        private var inputQueueLock = NSRecursiveLock()
        private var inputQueue: [Data] = .init()


        private var canWriteToOutput = false

        private var outputQueueLock = NSRecursiveLock()
        private var outputQueue: [Data] = .init()

        private var pendingData: Data?
        private var pendingDataOffset = 0


        private let mutationLock = NSRecursiveLock()



        // MARK: Start/Stop

        public func start() { streams?.start() }



        public func stop() { streams?.stop() }

    }

}



// MARK: Input

extension KvBonjour.Client {

    /// - returns: First received data from the queue if avaialble.
    public func take() -> Data? {
        inputQueueLock.withLock {
            !inputQueue.isEmpty ? inputQueue.removeFirst() : nil
        }
    }



    private func pushReceived(_ data: Data) {
        //NSLog("[KvBonjour.Client \(ObjectIdentifier(self))] Did receive \(data.count) bytes")

        inputQueueLock.withLock {
            inputQueue.append(data)
        }

        delegate?.bonjourClientDidReceiveData(self)
    }

}



// MARK: Output

extension KvBonjour.Client {

    public func send(_ data: Data) {
        guard !data.isEmpty else { return }

        outputQueueLock.withLock {
            outputQueue.append(data)

            sendPendingData()
        }
    }



    /// - Warning: outputQueueLock must be locked white this method is running.
    private func sendPendingData() {
        guard canWriteToOutput, let stream = streams?.outputStream else { return }

        var data = pendingData
        var dataOffset = pendingDataOffset

        if data == nil, !outputQueue.isEmpty {
            data = outputQueue.removeFirst()
            dataOffset = 0
        }


        guard data != nil else { return }

        repeat {
            let bytesSent: Int = data!.withUnsafeBytes {
                guard let bytePointer = $0.baseAddress?.bindMemory(to: UInt8.self, capacity: data!.count) else { return 0 }

                return stream.write(bytePointer + dataOffset, maxLength: data!.count - dataOffset)
            }

            guard bytesSent > 0 else {
                if bytesSent == 0 {
                    canWriteToOutput = false

                } else {
                    let dataToReport = data!

                    print("Error: failed to send \(dataToReport.count) bytes")

                    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                        self?.delegate?.bonjourClient(self!, didFailToSend: dataToReport)
                    }
                }

                break
            }

            //NSLog("[KvBonjour.Client \(ObjectIdentifier(self))] Did send \(bytesSent) of \(data!.count) bytes")


            dataOffset += bytesSent

            if dataOffset >= data!.count {
                let dataToReport = data!

                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.delegate?.bonjourClient(self!, didSend: dataToReport)
                }

                data = !outputQueue.isEmpty ? outputQueue.removeFirst() : nil
                dataOffset = 0
            }
        } while data != nil


        pendingData = data
        pendingDataOffset = dataOffset
    }

}



// MARK: .Streams

extension KvBonjour.Client {

    fileprivate class Streams {

        let inputStream: InputStream
        let outputStream: OutputStream

        let runLoop: RunLoop
        let runLoopMode: RunLoop.Mode


        weak var delegate: KvBonjourClientStreamsDelegate?



        convenience init?(for service: NetService, runLoop: RunLoop = .main, mode runLoopMode: RunLoop.Mode = .default) {
            var inputStream: InputStream?
            var outputStream: OutputStream?

            guard service.getInputStream(&inputStream, outputStream: &outputStream) else {
                print("Error: unable to obtain streams for service \(service)")
                return nil
            }
            guard inputStream != nil else {
                print("Internal inconsistency: the input stream is missing")
                return nil
            }
            guard outputStream != nil else {
                print("Internal inconsistency: the output stream is missing")
                return nil
            }

            self.init(input: inputStream!, output: outputStream!, runLoop: runLoop, mode: runLoopMode)
        }



        init(input inputStream: InputStream, output outputStream: OutputStream, runLoop: RunLoop = .main, mode runLoopMode: RunLoop.Mode = .default) {
            self.inputStream = inputStream
            self.outputStream = outputStream

            self.runLoop = runLoop
            self.runLoopMode = runLoopMode
        }



        deinit {
            stop()
        }



        // MARK: Start/Stop

        func start() {
            start(self.inputStream)
            start(self.outputStream)

            delegate?.streamsDidStart(self)
        }



        func stop() {
            stop(inputStream)
            stop(outputStream)

            delegate?.streamsDidStop(self)
        }



        private func start(_ stream: Stream) {
            stream.schedule(in: runLoop, forMode: runLoopMode)
            stream.open()
        }



        private func stop(_ stream: Stream) {
            stream.close()
            stream.remove(from: runLoop, forMode: runLoopMode)
        }

    }

}



// MARK: : KvBonjourClientStreamsDelegate

extension KvBonjour.Client : KvBonjourClientStreamsDelegate {

    fileprivate func streamsDidStart(_ streams: KvBonjour.Client.Streams) { delegate?.bonjourClientDidStart(self) }



    fileprivate func streamsDidStop(_ streams: KvBonjour.Client.Streams) { delegate?.bonjourClientDidStop(self) }

}



// MARK: : StreamDelegate

extension KvBonjour.Client : StreamDelegate {

    public func stream(_ stream: Stream, handle event: Stream.Event) {
        if let inputStream = streams?.inputStream, stream == inputStream {
            switch event {
            case .openCompleted:
                //                print("The input stream has been opened")
                break;

            case .hasBytesAvailable:
                let bytesRead = inputStream.read(inputBuffer, maxLength: inputBufferLength)
                guard bytesRead > 0 else { break }

                pushReceived(.init(bytes: inputBuffer, count: bytesRead))

            case .endEncountered:
                //                print("The input stream has ended")
                streams = nil

            case .errorOccurred:
                print("An error occured in the input stream")
                streams = nil

            default:
                break
            }


        } else if let outputStream = streams?.outputStream, stream == outputStream {
            switch event {
            case .openCompleted:
                //                print("The output stream has been opened")
                break

            case .hasSpaceAvailable:
                outputQueueLock.withLock {
                    canWriteToOutput = true

                    sendPendingData()
                }

            case .endEncountered:
                //                print("The output stream has ended")
                streams = nil

            case .errorOccurred:
                print("Error occured in the output stream")
                streams = nil

            default:
                break
            }


        } else {
            return print("Internal inconsistency: unexpected stream \(stream)")
        }
    }

}

#endif // canImport(Darwin)
