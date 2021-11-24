//
//  Builder+View.swift
//  ViewBuilder
//
//  Created by Michael Long on 11/8/21.
//

import UIKit
import RxSwift

// Allows UIView to use basic view modifiers and integrate with view builders
extension UIView: ModifiableView {
    
    public var modifiableView: UIView {
        self
    }
    
    public func asUIView() -> UIView {
        self
    }
    
    public func asViews() -> [UIView] {
        [self]
    }
    
}


// Standard UIView modifiers for all view types
extension ModifiableView {
        
    @discardableResult
    public func accessibilityIdentifier(_ accessibilityIdentifier: String) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.accessibilityIdentifier, value: accessibilityIdentifier)
    }
    
    @discardableResult
    public func alpha(_ alpha: CGFloat) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.alpha, value: alpha)
    }

    @discardableResult
    public func backgroundColor(_ color: UIColor?) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.backgroundColor, value: color)
    }

    @discardableResult
    public func backgroundImage(_ image: UIImage?) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.backgroundImage(image) }
    }

    @discardableResult
    public func border(color: UIColor, lineWidth: CGFloat = 0.5) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.layer.borderColor = color.cgColor
            $0.layer.borderWidth = lineWidth
        }
    }

    @discardableResult
    public func clipsToBounds(_ clips: Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.clipsToBounds, value: clips)
    }

    @discardableResult
    public func contentCompressionResistancePriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.setContentCompressionResistancePriority(priority, for: axis)
        }
    }

    @discardableResult
    public func contentHuggingPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.setContentHuggingPriority(priority, for: axis)
        }
    }

    @discardableResult
    public func contentMode(_ contentMode: UIView.ContentMode) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.contentMode, value: contentMode)
    }

    @discardableResult
    public func cornerRadius(_ radius: CGFloat) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.layer.cornerRadius = radius
            $0.clipsToBounds = true
        }
    }

    @discardableResult
    public func frame(height: CGFloat? = nil, width: CGFloat? = nil) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            if let height = height {
                let c = $0.heightAnchor.constraint(equalToConstant: height)
                c.priority = UILayoutPriority(rawValue: 999)
                c.isActive = true
            }
            if let width = width {
                let c =  $0.widthAnchor.constraint(equalToConstant: width)
                c.priority = UILayoutPriority(rawValue: 999)
                c.isActive = true
            }
        }
    }

    @discardableResult
    public func height(_ height: CGFloat) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            let c = $0.heightAnchor.constraint(equalToConstant: height)
            c.priority = UILayoutPriority(rawValue: 999)
            c.isActive = true
        }
    }

    @discardableResult
    public func hidden(_ hidden: Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.isHidden, value: hidden)
    }
    
    @discardableResult
    public func roundedCorners(radius: CGFloat, corners: CACornerMask) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.layer.maskedCorners = corners
            $0.layer.cornerRadius = radius
        }
    }
    
    @discardableResult
    public func shadow(color: UIColor, radius: CGFloat, opacity: Float = 0.5, offset: CGSize = .zero) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            $0.layer.shadowColor = color.cgColor
            $0.layer.shadowOffset = offset
            $0.layer.shadowRadius = radius
            $0.layer.shadowOpacity = opacity
            $0.clipsToBounds = false
        }
    }

    @discardableResult
    public func tag(_ tag: Int) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.tag, value: tag)
    }

    @discardableResult
    public func tintColor(_ color: UIColor) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.tintColor, value: color)
    }

    @discardableResult
    public func translatesAutoresizingMaskIntoConstraints(_ translate: Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.translatesAutoresizingMaskIntoConstraints, value: translate)
    }

    @discardableResult
    public func userInteractionEnabled(_ enabled: Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.isUserInteractionEnabled, value: enabled)
    }

    @discardableResult
    public func width(_ width: CGFloat) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            let c = $0.widthAnchor.constraint(equalToConstant: width)
            c.priority = UILayoutPriority(rawValue: 999)
            c.isActive = true
        }
    }
    
}



extension ModifiableView {
    
    @discardableResult
    public func alpha<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == CGFloat {
        ViewModifier(modifiableView, binding: binding, keyPath: \.alpha)
    }
    
    @discardableResult
    public func hidden<Binding:RxBinding>(bind binding: Binding) -> ViewModifier<Base> where Binding.T == Bool {
        ViewModifier(modifiableView, binding: binding, keyPath: \.isHidden)
    }

}



public struct TapGestureContext<Base:UIView>: ViewBuilderContextProvider {
    public var view: Base
    public var gesture: UIGestureRecognizer
}

extension ModifiableView {
    
    @discardableResult
    public func onTapGesture(_ handler: @escaping (_ context: TapGestureContext<Base>) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) {
            let gesture = UITapGestureRecognizer()
            $0.addGestureRecognizer(gesture)
            let context = TapGestureContext(view: $0, gesture: gesture)
            gesture.rx.event
                .asControlEvent()
                .throttle(.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
                .subscribe { (e) in
                    handler(context)
                }
                .disposed(by: $0.rxDisposeBag)
        }
    }

}


class BuilderHostView: UIView {
    
    public init(_ view: View) {
        super.init(frame: .zero)
        self.embed(view)
    }

    public init(@ViewResultBuilder _ builder: () -> ViewConvertable) {
        super.init(frame: .zero)
        builder().asViews().forEach { self.embed($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
