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
//  KvScreenKeyboardController.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 24.04.2019.
//

#if canImport(UIKit)



import UIKit



@available(iOS 11.0, *)
public class KvScreenKeyboardController : NSObject {

    public private(set) var keyboardFrame: CGRect? {
        didSet {
            guard keyboardFrame != oldValue else { return }

            scrollViews?.forEach { (scrollView) in
                adjustScrollView(scrollView)
            }
        }
    }


    public var scrollViews: Set<UIScrollView>? {
        didSet {
            scrollViews?.forEach { (scrollView) in
                guard oldValue?.contains(scrollView) != true else { return }

                adjustScrollView(scrollView)
            }
        }
    }



    public override init() {
        super.init()

        startObservationForScreenKeyboardEvents()
    }

}



// MARK: Auxiliary Methods

@available(iOS 11.0, *)
extension KvScreenKeyboardController {

    public func insertScrollView(_ scrollView: UIScrollView) {
        if scrollViews != nil {
            scrollViews!.insert(scrollView)
        } else {
            scrollViews = [ scrollView ]
        }
    }



    public func insertScrollViews<ScrollViews>(_ newScrollViews: ScrollViews) where ScrollViews : Sequence, ScrollViews.Element : UIScrollView {
        let castedNewScrollViews = newScrollViews.lazy.map { $0 as UIScrollView }

        scrollViews?.formUnion(castedNewScrollViews) ?? (scrollViews = .init(castedNewScrollViews))
    }



    /// Adds scroll view on first or second levels of *viewController*'s view heararchy.
    public func insertScrollViews(from viewController: UIViewController) {
        guard viewController.isViewLoaded else { return }

        let view = viewController.view

        if let rootScrollView = view as? UIScrollView {
            insertScrollView(rootScrollView)

        } else {
            guard let newScrollViews = view?.subviews.compactMap({ $0 as? UIScrollView }), !newScrollViews.isEmpty else { return }

            insertScrollViews(newScrollViews)
        }
    }

}



// MARK: Scroll View Management

@available(iOS 11.0, *)
extension KvScreenKeyboardController {

    private func adjustScrollView(_ scrollView: UIScrollView) {
        let bottomInset: CGFloat = {
            guard let keyboardFrame = keyboardFrame else { return 0 }

            let scrollViewBottomEdge = scrollView.frame.maxY - scrollView.safeAreaInsets.bottom
            let keyboardTopEdge = (scrollView.superview?.convert(keyboardFrame, from: nil) ?? keyboardFrame).minY

            return max(0, scrollViewBottomEdge - keyboardTopEdge)
        }()

        var contentInset = scrollView.contentInset
        var scrollIndicatorInsets = scrollView.scrollIndicatorInsets

        contentInset.bottom = bottomInset
        scrollIndicatorInsets.bottom = bottomInset

        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets =  scrollIndicatorInsets
    }

}



// MARK: Screen Keyboard Handling

@available(iOS 11.0, *)
extension KvScreenKeyboardController {

    private func startObservationForScreenKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }



    @objc private func keyboardWillChangeFrame(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let rawCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let curve = UIView.AnimationCurve(rawValue: rawCurve) else {
                self.keyboardFrame = .zero
                return
        }

        UIViewPropertyAnimator(duration: duration, curve: curve, animations: {
            self.keyboardFrame = keyboardFrame
        }).startAnimation()
    }

}



#endif // canImport(UIKit)
