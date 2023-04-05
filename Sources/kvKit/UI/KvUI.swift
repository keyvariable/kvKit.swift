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
//  KvUI.swift
//  KvKit
//
//  Created by Святослав on 15.03.2018.
//  Copyright © 2018 Svyatoslav Popov. All rights reserved.
//

#if canImport(AppKit) || canImport(UIKit)



#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif // AppKit

#if canImport(SwiftUI)
import SwiftUI
#endif // SwiftUI



public class KvUI { }



// MARK: Views and Windows

extension KvUI {

#if canImport(UIKit)
    public typealias View = UIView
    public typealias ViewController = UIViewController
    public typealias Window = UIWindow

    public typealias Responder = UIResponder
    public typealias Event = UIEvent

#if canImport(SwiftUI)
    @available(iOS 13.0, *)
    public typealias ViewRepresentable = UIViewRepresentable

    @available(iOS 13.0, *)
    public typealias ViewControllerRepresentable = UIViewControllerRepresentable
#endif // SwiftUI

#elseif canImport(AppKit)
    public typealias View = NSView
    public typealias ViewController = NSViewController
    public typealias Window = NSWindow

    public typealias Responder = NSResponder
    public typealias Event = NSEvent

#if canImport(SwiftUI)
    @available(macOS 10.15, *)
    public typealias ViewRepresentable = NSViewRepresentable

    @available(macOS 10.15, *)
    public typealias ViewControllerRepresentable = NSViewControllerRepresentable
#endif // SwiftUI
#endif // AppKit

}



// MARK: .Color

extension KvUI {

#if canImport(UIKit)
    /// Platform high level color type.
    public typealias Color = UIColor

#elseif canImport(AppKit)
    /// Platform high level color type.
    public typealias Color = NSColor
#endif // AppKit



    @inlinable
    public static func hexColor(_ hexValue: UInt, alpha: CGFloat = 1) -> Color {
        let components = (red: CGFloat((hexValue >> 16) & 0xFF) / 255,
                          green: CGFloat((hexValue >> 8) & 0xFF) / 255,
                          blue: CGFloat(hexValue & 0xFF) / 255)
        
#if canImport(UIKit)
        return Color(red: components.red, green: components.green, blue: components.blue, alpha: alpha)
#elseif canImport(AppKit)
        return Color(calibratedRed: components.red, green: components.green, blue: components.blue, alpha: alpha)
#endif // AppKit
    }

}



// MARK: .Image

extension KvUI {

#if canImport(UIKit)
    /// Platform high level image type.
    public typealias Image = UIImage

#elseif canImport(AppKit)
    /// Platform high level image type.
    public typealias Image = NSImage
#endif // AppKit

}



// MARK: .Alert

extension KvUI {

    public struct Alert {

#if canImport(AppKit)
        public static func present(message: String, details: String? = nil, _ alertStyle: NSAlert.Style = .informational,
                                   in window: NSWindow? = nil, action: String = "Close", completion: (() -> Void)? = nil)
        {
            let alert = NSAlert()

            alert.alertStyle = alertStyle
            alert.messageText = message

            if let details = details {
                alert.informativeText = details
            }

            alert.addButton(withTitle: action)

            present(alert, in: window, completion: { _ in completion?() })
        }



        @inlinable
        public static func present(message error: Error, in window: NSWindow? = nil, completion: (() -> Void)? = nil) {
            present(NSAlert(error: error), in: window, completion: { _ in completion?() })
        }



        public static func present(confirmation message: String, in window: NSWindow? = nil,
                                   yes yesTitle: String = "Yes", no noTitle: String = "No", completion: @escaping (Bool) -> Void)
        {
            let alert = NSAlert()

            alert.messageText = message

            alert.addButton(withTitle: yesTitle)
            alert.addButton(withTitle: noTitle)

            present(alert, in: window) { (modalResponse) in
                completion(modalResponse == .alertFirstButtonReturn)
            }
        }



        /// Presents *alert* as a modal sheet or as a modal message box whether *window* is provided.
        public static func present(_ alert: NSAlert, in window: NSWindow? = nil, completion: ((NSApplication.ModalResponse) -> Void)? = nil) {
            KvDebug.mainThreadCheck("⚠️ Attempt to present an alert on a non-main thread")

            if window != nil {
                alert.beginSheetModal(for: window!, completionHandler: { modalResponse in
                    completion?(modalResponse)
                })
            } else {
                let modalResponse = alert.runModal()
                completion?(modalResponse)
            }
        }
#endif // canImport(AppKit)



#if canImport(UIKit)
        @available(iOS 13.0, *)
        public static func present(message: String, title: String? = nil, in viewController: UIViewController? = nil,
                                   action: String = "Close", completion: (() -> Void)? = nil)
        {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(.init(title: action, style: .default, handler: { _ in completion?() }))

            do { try present(alertController, in: viewController) }
            catch { completion?() }
        }



        @available(iOS 13.0, *) @inlinable
        public static func present(message error: Error, title: String = "Error", in viewController: UIViewController? = nil, completion: (() -> Void)? = nil) {
            let message: String = {
                switch error {
                case let error as LocalizedError:
                    return [ error.localizedDescription, error.failureReason, error.recoverySuggestion ].lazy
                        .compactMap({ $0 }).joined(separator: "\n")
                default:
                    return error.localizedDescription
                }
            }()

            present(message: message, title: title, in: viewController, completion: completion)
        }



        @available(iOS 13.0, *)
        public static func present(confirmation message: String, title: String? = "Confirmation", in viewController: UIViewController? = nil,
                                   action: String = "Yes", actionStyle: UIAlertAction.Style = .default, cancel: String = "Cancel",
                                   completion: @escaping (Bool) -> Void)
        {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

            alertController.addAction(.init(title: action, style: actionStyle, handler: { _ in completion(true) }))
            alertController.addAction(.init(title: cancel, style: .cancel, handler: { _ in completion(false) }))

            do { try present(alertController, in: viewController) }
            catch { completion(false) }
        }



        @available(iOS 13.0, *)
        public static func present(_ alertController: UIAlertController, in viewController: UIViewController? = nil) throws {
            KvDebug.mainThreadCheck("⚠️ Attempt to present an alert controller on a non-main thread")

            guard let viewController = viewController
                    ?? UIApplication.shared.connectedScenes.lazy.compactMap({ $0.delegate as? UIWindowSceneDelegate }).first?.window??.rootViewController
            else { throw KvError("Error: unable to obtain a view controller to present an alert in") }

            viewController.present(alertController, animated: true, completion: nil)
        }
#endif // canImport(UIKit)

    }

}



// MARK: Open and Save Panels

#if canImport(AppKit)

extension KvUI {

    // MARK: .SavePanel

    public struct SavePanel {

        public static func begin<P>(_ panel: P, in window: NSWindow? = nil,
                                    customization customizationCallback: ((P) throws -> Void)? = nil,
                                    completion completionHandler: @escaping (P, NSApplication.ModalResponse) -> Void) rethrows
        where P : NSSavePanel
        {
            try customizationCallback?(panel)

            switch window {
            case .some(let window):
                panel.beginSheetModal(for: window, completionHandler: { response in completionHandler(panel, response) })
            case .none:
                panel.begin(completionHandler: { response in completionHandler(panel, response) })
            }
        }

    }



    // MARK: .OpenPanel

    public struct OpenPanel {

        public static func begin<P>(_ panel: P, in window: NSWindow? = nil,
                                    customization customizationCallback: ((P) throws -> Void)? = nil,
                                    completion completionHandler: @escaping (P, NSApplication.ModalResponse) -> Void) rethrows
        where P : NSOpenPanel
        {
            try SavePanel.begin(panel, in: window, customization: customizationCallback, completion: completionHandler)
        }

    }

}

#endif // canImport(AppKit)



#endif // canImport(AppKit) || canImport(UIKit)
