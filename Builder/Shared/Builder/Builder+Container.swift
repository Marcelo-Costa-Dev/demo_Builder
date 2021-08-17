//
//  Build+Container.swift
//  ViewBuilder
//
//  Created by Michael Long on 9/28/20.
//  Copyright © 2020 Michael Long. All rights reserved.
//

import UIKit
import RxSwift

class ContainerView: UIView, ViewBuilderPaddable {

    private var onAppearHandler: ((_ container: ContainerView) -> Void)?
    private var onDisappearHandler: ((_ container: ContainerView) -> Void)?
    
    private var views: ViewConvertable?
    private var padding: UIEdgeInsets?
    private var safeArea: Bool = false

    convenience public init(_ view: ViewBuilder?) {
        self.init(frame: .zero)
        self.views = view
    }

    convenience public init(@ViewResultBuilder _ builder: () -> ViewConvertable) {
        self.init(frame: .zero)
        self.views = builder()
    }
        
    override func didMoveToWindow() {
        // Note didMoveToWindow may be called more than once
        if subviews.isEmpty {
            views?.asViews().forEach { self.embed($0, padding: padding, safeArea: safeArea) }
        }
        if window == nil {
            onDisappearHandler?(self)
        } else if let vc = currentViewController, let nc = vc.navigationController, nc.topViewController == vc {
            onAppearHandler?(self)
        }
    }

    @discardableResult
    public func onAppear(_ handler: @escaping (_ container: ContainerView) -> Void) -> Self {
        onAppearHandler = handler
        return self
    }

    @discardableResult
    public func onDisappear(_ handler: @escaping (_ container: ContainerView) -> Void) -> Self {
        onDisappearHandler = handler
        return self
    }
    
    @discardableResult
    func padding(insets: UIEdgeInsets) -> Self {
        self.padding = insets
        return self
    }

    @discardableResult
    func safeArea(_ safeArea: Bool) -> Self {
        self.safeArea = safeArea
        return self
    }

    @discardableResult
    public func reference(_ reference: inout ContainerView?) -> Self {
        reference = self
        return self
    }

    @discardableResult
    public func with(_ configuration: (_ view: ContainerView) -> Void) -> Self {
        configuration(self)
        return self
    }

}

