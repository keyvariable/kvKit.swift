//
//  KvSwiftUiKit.swift
//  
//
//  Created by Svyatoslav Popov on 19.02.2021.
//

#if canImport(SwiftUI)

import SwiftUI



public class KvSwiftUiKit { }



// MARK: .NSWindowProvider

#if os(macOS)

extension KvSwiftUiKit {

    /// A view populating given binding with value of NSView's window property.
    ///
    /// Sometimes (Feb 2021) *NSWindow* is still required in SwiftUI macOS applications. E.g. presentation of *NSOpenPanel* as a window modal sheet.
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
