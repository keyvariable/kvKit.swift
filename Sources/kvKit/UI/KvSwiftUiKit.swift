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
//  KvSwiftUiKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 19.02.2021.
//

#if canImport(SwiftUI)



import SwiftUI



public class KvSwiftUiKit { }



// MARK: Alerts

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension KvSwiftUiKit {

    public static func alert(error: Error, dismissButton: Alert.Button? = nil) -> Alert {
        let content = ErrorAlertContent(for: error)

        return Alert(title: content.titleText, message: content.messageText, dismissButton: dismissButton)
    }



    public static func alert(error: Error, primaryButton: Alert.Button, secondaryButton: Alert.Button) -> Alert {
        let content = ErrorAlertContent(for: error)

        return Alert(title: content.titleText, message: content.messageText, primaryButton: primaryButton, secondaryButton: secondaryButton)
    }



    @available(*, deprecated, message: "Use .ErrorAlertContent instead")
    public static func alertContent(for error: Error) -> (title: Text, message: Text?) {
        let message: Text? = {
            var message = KvStringKit.Accumulator(separator: "\n")

            if let error = error as? LocalizedError {
                message.append(error.failureReason ?? "")
                message.append(error.recoverySuggestion ?? "")
            }

            guard let string = message.string else { return nil }

            return Text(string)
        }()

        return (title: Text(error.localizedDescription), message: message)
    }



    // MARK: .ErrorAlertContent

    public struct ErrorAlertContent {

        public var title: String
        public var message: String?


        @inlinable
        public var titleText: Text { Text(title) }

        @inlinable
        public var messageText: Text? { message.map({ Text($0) }) }


        @inlinable
        public init(title: String, message: String? = nil) {
            self.title = title
            self.message = message
        }


        public init(for error: Error) {
            title = error.localizedDescription
            message = {
                var message = KvStringKit.Accumulator(separator: Constants.separator)

                if let error = error as? LocalizedError {
                    message.append(error.failureReason ?? "")
                    message.append(error.recoverySuggestion ?? "")
                }

                guard let string = message.string else { return nil }

                return string
            }()
        }


        // MARK: .Constants

        public enum Constants {

            public static let separator: String = "\n"

        }


        // MARK: Auxiliaries

        /// - Returns: Joined title and message if available. If the result is empty then *nil* is returned.
        @inlinable
        public func joined() -> String? {
            KvStringKit.Accumulator([ title, message ].compactMap({ $0 }), separator: Constants.separator).string
        }

    }

}



// MARK: AppKit Intergration

#if os(macOS)

extension KvSwiftUiKit {

    // MARK: .NSWindowProvider

    /// A view populating given binding with value of NSView's window property.
    ///
    /// Sometimes (Feb 2021) *NSWindow* is still required in SwiftUI macOS applications. E.g. presentation of *NSOpenPanel* as a window modal sheet or closing a window programmatically.
    ///
    /// Example:
    ///
    ///     struct SomeView : View {
    ///         var body: some View {
    ///             Content()
    ///                 .background(KvSwiftUiKit.NSWindowProvider(binding: $window))
    ///                 .onChange(of: window, perform: {
    ///                     let panel = NSOpenPanel()
    ///                     panel.beginSheetModal(for: window) { _ in print(panel.urls) }
    ///                 })
    ///         }
    ///
    ///         @State private var window: NSWindow?
    ///     }
    ///
    @available(macOS 10.15, *)
    public struct NSWindowProvider : NSViewRepresentable {

        public init(for binding: Binding<NSWindow?>) {
            self.binding = binding
        }



        private var binding: Binding<NSWindow?>



        // MARK: : NSViewRepresentable

        public func makeNSView(context: Context) -> NSView { WindowProvidingView(for: binding) }



        public func updateNSView(_ nsView: NSView, context: Context) {}



        // MARK: .WindowProvidingView

        private class WindowProvidingView : NSView {

            var binding: Binding<NSWindow?>


            init(for binding: Binding<NSWindow?>) {
                self.binding = binding

                super.init(frame: .zero)

                alphaValue = 0
            }


            required init?(coder: NSCoder) { fatalError("Not implemented") }


            override func viewDidMoveToWindow() {
                super.viewDidMoveToWindow()

                binding.wrappedValue = window
            }

        }

    }

}

#endif // os(macOS)



#endif // canImport(SwiftUI)
