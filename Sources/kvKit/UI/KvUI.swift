//
//  KvUI.swift
//  KvKit
//
//  Created by Святослав on 15.03.2018.
//  Copyright © 2018 Svyatoslav Popov. All rights reserved.
//

#if canImport(Cocoa) || canImport(UIKit)



#if canImport(Cocoa)
import Cocoa
#elseif canImport(UIKit)
import UIKit
#endif // canImport(UIKit)



public class KvUI { }



// MARK: .Color

extension KvUI {

    #if canImport(Cocoa)
    public typealias Color = NSColor
    #elseif canImport(UIKit)
    public typealias Color = UIColor
    #endif // iOS



    @inlinable
    public static func hexColor(_ hexValue: UInt, alpha: CGFloat = 1) -> Color {
        let components = (red: CGFloat((hexValue >> 16) & 0xFF) / 255,
                          green: CGFloat((hexValue >> 8) & 0xFF) / 255,
                          blue: CGFloat(hexValue & 0xFF) / 255)
        
        #if canImport(Cocoa)
        return Color(calibratedRed: components.red, green: components.green, blue: components.blue, alpha: alpha)
        #elseif canImport(UIKit)
        return Color(red: components.red, green: components.green, blue: components.blue, alpha: alpha)
        #endif // canImport(UIKit)
    }

}



// MARK: .Alert

extension KvUI {

    public struct Alert {

        #if canImport(Cocoa)
        public static func present(message: String, details: String? = nil, _ alertStyle: NSAlert.Style = .informational, in window: NSWindow? = nil, action: String = "Close", completion: (() -> Void)? = nil) {
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



        public static func present(confirmation message: String, in window: NSWindow? = nil, yes yesTitle: String = "Yes", no noTitle: String = "No", completion: @escaping (Bool) -> Void) {
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
            KvDebug.mainThreadCheck("⚠️ Attempt to present an alert on a nonmain thread")

            if window != nil {
                alert.beginSheetModal(for: window!, completionHandler: { modalResponse in
                    completion?(modalResponse)
                })
            } else {
                let modalResponse = alert.runModal()
                completion?(modalResponse)
            }
        }
        #endif // canImport(Cocoa)



        #if canImport(UIKit)
        @available (iOS 13.0, *)
        public static func present(message: String, title: String? = nil, in viewController: UIViewController? = nil, action: String = "Close", completion: (() -> Void)? = nil) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(.init(title: action, style: .default, handler: { _ in completion?() }))

            do { try present(alertController, in: viewController) }
            catch { completion?() }
        }



        @available (iOS 13.0, *) @inlinable
        public static func present(message error: Error, in viewController: UIViewController? = nil, completion: (() -> Void)? = nil) {
            present(message: "Error:\n\n\(error.localizedDescription)", in: viewController, completion: completion)
        }



        @available (iOS 13.0, *)
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



        @available (iOS 13.0, *)
        public static func present(_ alertController: UIAlertController, in viewController: UIViewController? = nil) throws {
            KvDebug.mainThreadCheck("⚠️ Attempt to present an alert controller on a nonmain thread")

            guard let viewController = viewController
                    ?? UIApplication.shared.connectedScenes.lazy.compactMap({ $0.delegate as? UIWindowSceneDelegate }).first?.window??.rootViewController
            else { throw KvError("Error: unable to obtain a view controller to present an alert in") }

            viewController.present(alertController, animated: true, completion: nil)
        }
        #endif // canImport(UIKit)

    }

}



#endif // canImport(Cocoa) || canImport(UIKit)
