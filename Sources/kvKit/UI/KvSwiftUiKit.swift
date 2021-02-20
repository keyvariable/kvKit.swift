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
        let (title, message) = alertContent(for: error)

        return Alert(title: title, message: message, dismissButton: dismissButton)
    }



    public static func alert(error: Error, primaryButton: Alert.Button, secondaryButton: Alert.Button) -> Alert {
        let (title, message) = alertContent(for: error)

        return Alert(title: title, message: message, primaryButton: primaryButton, secondaryButton: secondaryButton)
    }



    private static func alertContent(for error: Error) -> (title: Text, message: Text?) {

        func Message(from error: Error) -> Text? {

            func Append(_ dest: inout [String], from error: Error) {

                func AppendIfPresent(_ item: String?) {
                    guard let item = item else { return }

                    dest.append(item)
                }


                switch error {
                case let nsError as NSError:
                    AppendIfPresent(nsError.localizedFailureReason)
                    AppendIfPresent(nsError.localizedRecoverySuggestion)

                default:
                    dest.append(error.localizedDescription)
                }
            }


            var components: [String] = .init()

            Append(&components, from: error)

            return !components.isEmpty ? Text(components.joined(separator: "\n")) : nil
        }


        return (title: Text((error as? KvError)?.message ?? error.localizedDescription),
                message: Message(from: error))
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
