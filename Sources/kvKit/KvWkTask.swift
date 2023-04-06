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
//  KvWkTask.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 26.01.2018.
//

#if canImport(WebKit)



import Foundation
import WebKit



/// - Note: `NSObject` is superclass to conform to `WKScriptMessageHandler`.
///
/// - Note: Use `window.webkit.messageHandlers[eventname].postMessage(payload);` to pass *payload* from a script to the native code.
/// Supprted *eventname* values: `done`, `error`, `warning`, `message`, `data`.
public class KvWkTask : NSObject {

    public typealias Callback = (Event, KvWkTask) -> Void



    public var userData: Any?



    @discardableResult
    public static func run<S>(with sources: S, injectionTime: WKUserScriptInjectionTime, at url: URL, userData: Any? = nil, callback: @escaping Callback) throws -> KvWkTask
        where S : Sequence, S.Element == Source
    {
        let sourceCode = try sources.lazy.map({ try $0.sourceCode() }).joined(separator: "\n")

        return .init(with: sourceCode, injectionTime: injectionTime, at: url, userData: userData, callback: callback)
    }



    private init(with sourceCode: String, injectionTime: WKUserScriptInjectionTime, at url: URL, userData: Any?, callback: @escaping Callback) {
        self.sourceCode = sourceCode
        self.callback = callback
        self.userData = userData

        super.init()

        selfRef = self


        let startScript = WKUserScript(source: "window.webkit.messageHandlers['\(KvWkTask.startEvent)'].postMessage(null);", injectionTime: injectionTime, forMainFrameOnly: true)


        let webViewConfiguration = WKWebViewConfiguration()

        ScriptMessage.allCases.forEach { webViewConfiguration.userContentController.add(self, name: $0.rawValue) }
        webViewConfiguration.userContentController.add(self, name: KvWkTask.startEvent)

        webViewConfiguration.userContentController.addUserScript(startScript)

        let frame: CGRect = {
            #if os(macOS)
            return .init(origin: .zero, size: .init(width: 1280, height: 720))
            #elseif os(iOS)
            return UIScreen.main.bounds
            #endif // iOS
        }()

        webView = WKWebView(frame: frame, configuration: webViewConfiguration)
        webView.uiDelegate = self

        webView.load(URLRequest(url: url))


        #if os(iOS)
        containerView = UIView()

        containerView.isHidden = true

        containerView.addSubview(webView)

        UIApplication.shared.keyWindow?.addSubview(containerView)
        #endif // iOS
    }



    private let sourceCode: String

    private let callback: Callback


    private var selfRef: Any?


    private var webView: WKWebView!

    private let mutationLock = NSRecursiveLock()


    #if os(iOS)
    /// A hidden view to install webView and then check if webView has been moved to another view.
    private var containerView: UIView!
    #endif // iOS

}



// MARK: Life Cycle

extension KvWkTask {

    public func cancel() {
        stop(with: .cancelled)
    }



    private func stop(with result: Event) {
        KvThreadKit.locking(mutationLock) {
            guard webView != nil else { return }


            webView.stopLoading()

            ScriptMessage.allCases.forEach { webView.configuration.userContentController.removeScriptMessageHandler(forName: $0.rawValue) }

            webView.configuration.userContentController.removeAllUserScripts()


            #if os(iOS)
            containerView.removeFromSuperview()
            containerView = nil
            #endif // iOS

            webView = nil


            selfRef = nil

            callback(result, self)
        }
    }

}



// MARK: Events

extension KvWkTask {

    private static let startEvent = "__KvWkTask_start"



    public enum Event {
        case done(Any), failure(Error), cancelled
        case data(Any)
    }

}



// MARK: Source

extension KvWkTask {

    public enum Source {

        case code(String)
        case resource(name: String?, extension: String?, bundle: Bundle, subdirectory: String?)
        case url(URL)



        public func sourceCode() throws -> String {
            switch self {
            case .code(let string):
                return string

            case let .resource(name, `extension`, bundle, subdirectory):
                guard let url = bundle.url(forResource: name, withExtension: `extension`, subdirectory: subdirectory) else {
                    throw KvError("Unable to find resuorce \(name != nil ? "«\(name!)»" : "`nil`") with \(`extension` != nil ? "«\(`extension`!)»" : "`nil`") extension in \(subdirectory != nil ? "«\(subdirectory!)»" : "`nil`") subdirectory of \(bundle) bundle")
                }

                return try .init(contentsOf: url)

            case .url(let url):
                return try .init(contentsOf: url)
            }
        }

    }

}



// MARK: : WKUIDelegate

extension KvWkTask: WKUIDelegate {

    public func webView(_ webView: WKWebView,
                        runJavaScriptAlertPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping () -> Void)
    {
        #if os(macOS)
        KvUI.Alert.present(message: message, in: webView.window, completion: completionHandler)

        #elseif os(iOS)
        if #available(iOS 13.0, *) {
            KvUI.Alert.present(message: message, in: webView.window?.rootViewController, completion: completionHandler)
        }
        #endif // os(iOS)
    }

}



// MARK: Script Messages

extension KvWkTask {

    public enum ScriptMessage : String, CaseIterable {

        case done, message, warning, error, data



        func log(with body: Any) {
            let prefix = "\(type(of: self)).\(self.rawValue) at \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium))"

            switch self {
            case .done, .data:
                print(prefix)

            case .message, .warning, .error:
                print("\(prefix): \(body)")
            }
        }

    }

}



// MARK: WKScriptMessageHandler Protocol

extension KvWkTask: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // The start message
        guard message.name != KvWkTask.startEvent else {
            // String refernce to prevent the web view destruction.
            var webView: WKWebView! = self.webView

            webView.configuration.userContentController.removeScriptMessageHandler(forName: KvWkTask.startEvent)
            webView.configuration.userContentController.removeAllUserScripts()

            return DispatchQueue.main.async {
                webView.evaluateJavaScript(self.sourceCode, completionHandler: { (_, error) in
                    if let error = error {
                        KvDebug.pause("KvWkTask did evaluate script with error: «\(error)»")
                    }

                    webView = nil
                })
            }
        }


        // User messages
        guard let scriptMessage = ScriptMessage(rawValue: message.name) else { return }

        scriptMessage.log(with: message.body)

        switch scriptMessage {
        case .done:
            stop(with: .done(message.body))

        case .error:
            stop(with: .failure(KvError((message.body as? String) ?? String(describing: message.body))))

        case .data:
            callback(.data(message.body), self)

        case .message, .warning:
            break
        }
    }

}



#endif // canImport(WebKit)
